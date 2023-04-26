
function( cframe_process_git_return OUTVAR )

  if ( NOT ${OUTVAR} )
    set( ${OUTVAR} OUTVAR_UNDEFINED PARENT_SCOPE )
    return()
  endif()

  set( OUTVAR_TEMP ${${OUTVAR}} )
  set( OUTVAR_LENGTH 0 )

  # Strip off the leading and trailing quotation marks
  string( LENGTH ${OUTVAR_TEMP} OUTVAR_LENGTH )
  if ( ${OUTVAR_LENGTH} GREATER 2 )
    math( EXPR OUTVAR_LENGTH ${OUTVAR_LENGTH}-2 )
    string( SUBSTRING ${OUTVAR_TEMP} 1 ${OUTVAR_LENGTH} ${OUTVAR_TEMP} )
  else()
    set( ${OUTVAR_TEMP} OUTVAR_INVALID )
  endif()

  set( ${OUTVAR} ${OUTVAR_TEMP} PARENT_SCOPE )

endfunction() # cframe_process_git_return

#
# Get the last git commit id in the current source directory
#
function( cframe_git_commitid OUTVAR )

  find_package( Git )
  if ( NOT GIT_FOUND )
    set( ${OUTVAR} OUTVAR_GIT_NOT_FOUND PARENT_SCOPE )
    return()
  endif()

  set( OUTVAR_TEMP "" )
  execute_process(
      COMMAND ${GIT_EXECUTABLE} log -1 --pretty=format:"%H"
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      OUTPUT_VARIABLE OUTVAR_TEMP
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
  )

  cframe_process_git_return( OUTVAR_TEMP )
  set( ${OUTVAR} ${OUTVAR_TEMP} PARENT_SCOPE )

endfunction() # cframe_git_commitid

#
# Get the current git branch in the current source directory
#
function( cframe_git_branchid OUTVAR )

  find_package( Git )
  if ( NOT GIT_FOUND )
    set( ${OUTVAR} OUTVAR_GIT_NOT_FOUND PARENT_SCOPE )
    return()
  endif()

  set( OUTVAR_TEMP "" )
  execute_process(
      COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      OUTPUT_VARIABLE OUTVAR_TEMP
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
  )

  cframe_process_git_return( OUTVAR_TEMP )
  set( ${OUTVAR} ${OUTVAR_TEMP} PARENT_SCOPE )

endfunction() # cframe_git_branchid

set(
    CFRAME_GIT_REMOTE_NAMES origin
    CACHE STRING
    "List or remote repository names to check for repository names."
)

#
# Get the git remote name for specified branch.
#
function( cframe_git_remotename BRANCHID OUTVAR )

  find_package( Git )
  if ( NOT GIT_FOUND )
    set( ${OUTVAR} OUTVAR_GIT_NOT_FOUND PARENT_SCOPE )
    return()
  endif()

  set( OUTVAR_TEMP "" )
  execute_process(
      COMMAND ${GIT_EXECUTABLE} config --get branch.${BRANCHID}.remote
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      OUTPUT_VARIABLE OUTVAR_TEMP
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
  )

  cframe_process_git_return( OUTVAR_TEMP )
  set( ${OUTVAR} ${OUTVAR_TEMP} PARENT_SCOPE )

endfunction() # cframe_git_remotename

#
# Get the git repository url for the specified Remote Name.
#
function( cframe_git_remoteurl REMOTENAME OUTVAR )

  find_package( Git )
  if ( NOT GIT_FOUND )
    set( ${OUTVAR} OUTVAR_GIT_NOT_FOUND PARENT_SCOPE )
    return()
  endif()

  set( OUTVAR_TEMP "" )
  execute_process(
      COMMAND ${GIT_EXECUTABLE} config --get remote.${REMOTENAME}.url
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      OUTPUT_VARIABLE OUTVAR_TEMP
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
  )

  cframe_process_git_return( OUTVAR_TEMP )
  set( ${OUTVAR} ${OUTVAR_TEMP} PARENT_SCOPE )

endfunction() # cframe_git_remoteurl
