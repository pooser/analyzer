# Fetch EVIO archive (currently from our GitHub mirror) and prepare for building the C-library

message(STATUS "Will build local copy of EVIO")

set(EVIO_VERSION 5.2)
set(repo hallac_evio)
set(release hallac-evio-${EVIO_VERSION})
set(tarfile ${release}.tar.gz)
set(EVIO_HASH d7fc44ce1ddc1d9e0011307621a6f3b5)

set(EVIO_SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/evio/src)
set(EVIO_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/evio/build)
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${EVIO_SOURCE_DIR} ${EVIO_BINARY_DIR})
set(EVIO_TARFILE ${EVIO_SOURCE_DIR}/${tarfile})
file(DOWNLOAD https://github.com/JeffersonLab/${repo}/archive/${tarfile}
  ${EVIO_TARFILE}
  EXPECTED_HASH MD5=${EVIO_HASH}
  STATUS _status
  )
list(GET _status 0 _errval)
if(_errval)
  list(GET _status 1 _errmsg)
  message(FATAL_ERROR "Failed to download EVIO archive: ${_errmsg}")
else()
  message(STATUS "Successfully downloaded EVIO archive version ${EVIO_VERSION}")
endif()
unset(_status)
unset(_errval)

# This command is system dependent. It requires GNU tar or macOS BSD tar in PATH.
# cmake -E tar does not support --strip-components and extracting a filename glob.
if(UNIX AND NOT APPLE)
  set(TAR_WILDCARDS_FLAG "--wildcards")
endif()
execute_process(COMMAND tar -x --strip-components=3 -f ${EVIO_TARFILE} ${TAR_WILDCARDS_FLAG} "*/libsrc"
  WORKING_DIRECTORY ${EVIO_SOURCE_DIR})
configure_file(evio/CMakeLists.txt.in ${EVIO_SOURCE_DIR}/CMakeLists.txt @ONLY)
file(COPY evio/EVIOConfig.cmake.in DESTINATION ${EVIO_SOURCE_DIR})

add_subdirectory(${EVIO_SOURCE_DIR} ${EVIO_BINARY_DIR})
