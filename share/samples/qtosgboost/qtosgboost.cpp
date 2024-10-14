#include "qtosgboost.hpp"

#if !defined QT_NO_KEYWORDS
#  define QT_NO_KEYWORDS
#endif

// Qt Includes
#include <QtWidgets/QAction>
#include <QtWidgets/QApplication>
#include <QtWidgets/QFileDialog>
#include <QtWidgets/QMenu>
#include <QtWidgets/QMenuBar>
#include <QtWidgets/QMessageBox>

#include <QtGui/QResizeEvent>

#include <QtCore/QTimer>

// OpenSceneGraph Includes
// NOTE: Make sure to include GraphicsWindowX11 **AFTER** Qt on Linux
#include <osgDB/ReadFile>
#include <osgGA/StateSetManipulator>
#include <osgGA/TrackballManipulator>

#include <osgViewer/ViewerEventHandlers>

#if defined( WIN32 ) && !defined( __CYGWIN__ )
#  include <osgViewer/api/Win32/GraphicsWindowWin32>
typedef HWND                                       WindowHandle;
typedef osgViewer::GraphicsWindowWin32::WindowData WindowData;
#elif defined( __APPLE__ ) // Assume using Carbon on Mac.
#  include <osgViewer/api/Cocoa/GraphicsWindowCocoa>
typedef void *                                     WindowHandle; // TEMPORARY
typedef osgViewer::GraphicsWindowCocoa::WindowData WindowData;
#else // all other unix
#  include <osgViewer/api/X11/GraphicsWindowX11>
typedef Window                                   WindowHandle;
typedef osgViewer::GraphicsWindowX11::WindowData WindowData;
#endif

#include <boost/date_time/c_local_time_adjustor.hpp>
#include <boost/date_time/local_time_adjustor.hpp>
#include <boost/date_time/posix_time/posix_time.hpp>
#include <boost/filesystem.hpp>

namespace qtosgboost {

QOSGWindow::QOSGWindow( QWidget * parent )
    : QMainWindow( parent )
    , mTraits()
    , mGraphicsContext()
    , mViewer()
    , mRootNode()
    , mTimer( nullptr )
{
  setupGUI();
  setupGraphics();
} // QOSGWindow::QOSGWindow

QOSGWindow::~QOSGWindow()
{
} // QOSGWindow::~QOSGWindow

class ResizeHandler : public QObject
{
public:
  ResizeHandler( QObject * parent ) : QObject( parent )
  {
  }

  boost::signals2::signal<void( int, int )> resized;

private:
  bool eventFilter( QObject * object, QEvent * event ) override
  {
    if ( event->type() == QEvent::Resize ) {
      auto   resizeEvent = dynamic_cast<QResizeEvent *>( event );
      auto & size        = resizeEvent->size();
      resized( size.width(), size.height() );
    }

    return false;
  }

}; // class ResizeHandler

void
QOSGWindow::setupGUI()
{
  auto mb = menuBar();

  auto fileMenu = menuBar()->addMenu( tr( "File" ) );

  auto openAction = fileMenu->addAction( tr( "&Open" ) );
  QObject::connect(
      openAction, &QAction::triggered, this, &QOSGWindow::openModel );

  fileMenu->addSeparator();

  auto exitAction = fileMenu->addAction( tr( "E&xit" ) );
  QObject::connect(
      exitAction, &QAction::triggered, qApp, &QApplication::exit );

  auto centralWidget = new QWidget( this );
  setCentralWidget( centralWidget );
} // ::setupGUI

void
QOSGWindow::openModel()
{
  auto filename = QFileDialog::getOpenFileName(
      this,
      tr( "Open 3D Model File" ),
      QString(),
      tr( "3D Models (*.obj *.flt *.osg);;All Files (*.*)" ) );

  if ( filename.isEmpty() ) {
    return;
  }

  using boost::gregorian::day_clock;
  using boost::posix_time::ptime;
  using boost::posix_time::second_clock;
  using boost::posix_time::to_simple_string;

  ptime todayUtc( day_clock::universal_day(),
                  second_clock::universal_time().time_of_day() );
  auto  timestamp = to_simple_string( todayUtc );

  if ( !boost::filesystem::exists( filename.toStdString() ) ) {
    QMessageBox::warning( this,
                          tr( "Load Model" ),
                          tr( "%1: Non-existing file: %2" )
                              .arg( QString::fromStdString( timestamp ) )
                              .arg( filename ) );
    return;
  }

  auto model = osgDB::readNodeFile( filename.toStdString() );
  if ( !model ) {
    modelLoaded( false, filename.toStdString(), timestamp );
    return;
  }

  mRootNode->addChild( model );

  mViewer->getCamera();
  auto manip = mViewer->getCameraManipulator();
  manip->home( 1.0 );

  modelLoaded( true, filename.toStdString(), timestamp );
} // QOSGWindow::openModel

void
QOSGWindow::setupGraphics()
{
  auto size = centralWidget()->size();

  auto displaySettings = osg::DisplaySettings::instance();

  mTraits = new osg::GraphicsContext::Traits;
  mTraits->readDISPLAY();
  mTraits->windowName       = "qtosgboost";
  mTraits->screenNum        = 0;
  mTraits->x                = 0;
  mTraits->y                = 0;
  mTraits->width            = size.width();
  mTraits->height           = size.height();
  mTraits->alpha            = displaySettings->getMinimumNumAlphaBits();
  mTraits->stencil          = displaySettings->getMinimumNumStencilBits();
  mTraits->windowDecoration = false;
  mTraits->doubleBuffer     = true;
  mTraits->sharedContext    = 0;
  mTraits->sampleBuffers    = displaySettings->getMultiSamples();
  mTraits->samples          = displaySettings->getNumMultiSamples();
  mTraits->setUndefinedScreenDetailsToDefaultScreen();

  mTraits->inheritedWindowData =
      new WindowData( (WindowHandle)centralWidget()->winId() );
  mGraphicsContext =
      osg::GraphicsContext::createGraphicsContext( mTraits.get() );

  mViewer = new osgViewer::Viewer;
  mViewer->setThreadingModel( osgViewer::ViewerBase::SingleThreaded );

  auto camera = mViewer->getCamera();
  camera->setViewport( 0, 0, size.width(), size.height() );
  camera->setClearColor( osg::Vec4( 0.08, 0.08, 0.5, 1.0 ) );
  camera->setGraphicsContext( mGraphicsContext );

  mRootNode = new osg::Group;
  mViewer->setSceneData( mRootNode );
  auto manip = new osgGA::TrackballManipulator;
  manip->setAutoComputeHomePosition( true );
  mViewer->setCameraManipulator( manip );
  mViewer->addEventHandler(
      new osgGA::StateSetManipulator( camera->getOrCreateStateSet() ) );
  mViewer->addEventHandler( new osgViewer::ThreadingHandler );
  mViewer->addEventHandler( new osgViewer::WindowSizeHandler );
  mViewer->addEventHandler( new osgViewer::StatsHandler );

  mViewer->realize();

  mTimer = new QTimer( this );
  QObject::connect( mTimer, &QTimer::timeout, [this]() {
    mViewer->frame( USE_REFERENCE_TIME );
  } );
  mTimer->start( 10 );

  auto resizeHandler = new ResizeHandler( centralWidget() );
  centralWidget()->installEventFilter( resizeHandler );
  resizeHandler->resized.connect( [this]( int width, int height ) {
    mGraphicsContext->resizedImplementation( 0, 0, width, height );
  } );

} // QOSGWindow::setupGraphics

} // namespace qtosgboost
