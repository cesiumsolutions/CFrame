# -----------------------------------------------------------------------------
#
# Boost specialized setup
#
# -----------------------------------------------------------------------------

find_package( Boost REQUIRED
	${CFRAME_EXTERNAL_Boost_COMPONENTS}
)
add_definitions( -DBOOST_ALL_DYN_LINK )
include_directories( ${Boost_INCLUDE_DIR} )
link_directories( ${Boost_LIBRARY_DIRS} )

cframe_message( INFO 2 "Boost_LIBRARIES = ${Boost_LIBRARIES}" )
