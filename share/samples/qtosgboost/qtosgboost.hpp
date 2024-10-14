
#ifndef qtosgboost_hpp
#define qtosgboost_hpp

#include <qtosgboost/qtosgboostapi.h>

#include <osg/GraphicsContext>
#include <osg/Group>
#include <osgViewer/Viewer>

#include <QtWidgets/QMainWindow>

#include <boost/signals2.hpp>

#include <string>

class QTimer;

namespace osgViewer {
class Viewer;
} // namespace osgViewer

namespace qtosgboost {

class QTOSGBOOST_API QOSGWindow : public QMainWindow
{
public:
  explicit QOSGWindow( QWidget * parent = nullptr );
  ~QOSGWindow();

  boost::signals2::signal<void( bool                success,
                                std::string const & filename,
                                std::string const & dateTme )>
      modelLoaded;

private:
  void setupGUI();
  void openModel();
  void setupGraphics();

  osg::ref_ptr<osg::GraphicsContext::Traits> mTraits;
  osg::ref_ptr<osg::GraphicsContext>         mGraphicsContext;
  osg::ref_ptr<osgViewer::Viewer>            mViewer;
  osg::ref_ptr<osg::Group>                   mRootNode;

  QTimer * mTimer;

}; // class QOSGWindow

} // namespace qtosgboost

#endif // qtosgboost_hpp
