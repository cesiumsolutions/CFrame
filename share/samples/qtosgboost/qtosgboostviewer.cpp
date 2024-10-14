
#include <qtosgboost/qtosgboost.hpp>

#include <QtWidgets/QApplication>
#include <QtWidgets/QMessageBox>

int
main( int argc, char ** argv )
{
  QApplication qapp( argc, argv );

  qtosgboost::QOSGWindow window;
  window.resize( 800, 600 );
  window.modelLoaded.connect( [win = &window]( bool                success,
                                               std::string const & filename,
                                               std::string const & timestamp ) {
    auto qfilename = QString::fromStdString( filename );
    if ( success ) {
      QMessageBox::information( win,
                                QObject::tr( "Model load" ),
                                QObject::tr( "%1: Loaded model: %2" )
                                    .arg( QString::fromStdString( timestamp ) )
                                    .arg( qfilename ) );
    }
    else {
      QMessageBox::warning( win,
                            QObject::tr( "Model load" ),
                            QObject::tr( "%1: Error trying to load model: %2" )
                                .arg( QString::fromStdString( timestamp ) )
                                .arg( qfilename ) );
    }
  } );
  window.show();

  return qapp.exec();

} // main
