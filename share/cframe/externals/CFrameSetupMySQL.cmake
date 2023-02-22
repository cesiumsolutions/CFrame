# --------------------------
# Set up MySQL dependency
# --------------------------

if ( LINUX )

  # TODO: Fix these so not using hardcoded paths
  set(
      MySQL_CONNECTOR_INCLUDE_DIR "/usr/include/mysql-cppconn-8/jdbc"
  )
  set(
      MySQL_CONNECTOR_LIBRARIES
      ## -lmysqlcppconn8-static -lmysqlcppconn-static -lssl -lcrypto -lresolv -lpthread -ldl
      -lmysqlcppconn-static -lssl -lcrypto -lresolv -lpthread -ldl
  )
  set(
      MySQL_LIBRARIES -lmysqlclient
  )
endif()

if ( WIN32 )

  find_package( MySQL-windows )

  # Setup Connector lib
  if ( MySQL_FOUND )

    # TODO: Fix these to be based on MySQL Server (version) installation
    set(
        MySQL_CONNECTOR_INCLUDE_DIR "C:/Program Files/MySQL/Connector C++ 8.0/include/jdbc"
    )

    set(
        MySQL_CONNECTOR_LIBRARIES
          "C:/Program Files/MySQL/Connector C++ 8.0/lib64/vs14/mysqlcppconn8.lib"
          "C:/Program Files/MySQL/Connector C++ 8.0/lib64/vs14/mysqlcppconn.lib"
    )

  endif()

endif()
