SET(abs_top_srcdir ${CMAKE_CURRENT_SOURCE_DIR})

remove_definitions(-DDLL_EXPORT)
add_definitions(-D"TOPSRCDIR=${CMAKE_SOURCE_DIR}")

FILE(GLOB COPY_FILES ${CMAKE_CURRENT_SOURCE_DIR}/*.sh)

FILE(COPY ${COPY_FILES} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/ FILE_PERMISSIONS OWNER_WRITE OWNER_READ OWNER_EXECUTE)

IF(ENABLE_TESTS)

  INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/libdap4)

  # Base tests
  # The tests are set up as a combination of shell scripts and executables that
  # must be run in a particular order. It is painful but will use macros to help
  # keep it from being too bad.

  add_executable(test_ncuri test_ncuri.c)
  add_executable(test_parse test_parse.c)
  add_executable(test_meta test_meta.c)
  add_executable(test_data test_data.c)

  target_link_libraries(test_ncuri netcdf)
  target_link_libraries(test_parse netcdf)
  target_link_libraries(test_meta netcdf)
  target_link_libraries(test_data netcdf)

  add_sh_test(dap4_test test_parse.sh)
  add_sh_test(dap4_test test_meta.sh)
  add_sh_test(dap4_test test_data.sh)
  add_sh_test(dap4_test test_raw.sh)

#  build_bin_test(test_ncuri)
#  build_bin_test(test_parse)
#  build_bin_test(test_meta)
#  build_bin_test(test_data)

  # Change name (add '4') to avoid cmake
  # complaint about duplicate targets.
  BUILD_BIN_TEST(test_environment4)

  IF(ENABLE_DAP4_REMOTE_TESTS)

    # Change name (add '4') to avoid cmake
    # complaint about duplicate targets.
    BUILD_BIN_TEST(findtestserver4)

    IF(BUILD_UTILITIES)
      add_sh_test(dap4_test test_remote.sh)
    ENDIF(BUILD_UTILTIES)
  ENDIF()
ENDIF()

FILE(COPY ./baseline DESTINATION ${CMAKE_CURRENT_SOURCE_DIR})
FILE(COPY ./baselineraw DESTINATION ${CMAKE_CURRENT_SOURCE_DIR})
FILE(COPY ./cdltestfiles DESTINATION ${CMAKE_CURRENT_SOURCE_DIR})
FILE(COPY ./daptestfiles DESTINATION ${CMAKE_CURRENT_SOURCE_DIR})
FILE(COPY ./dmrtestfiles DESTINATION ${CMAKE_CURRENT_SOURCE_DIR})

## Specify files to be distributed by 'make dist'
FILE(GLOB CUR_EXTRA_DIST RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/*.c ${CMAKE_CURRENT_SOURCE_DIR}/*.h ${CMAKE_CURRENT_SOURCE_DIR}/*.sh
${CMAKE_CURRENT_SOURCE_DIR}/daptestfiles
${CMAKE_CURRENT_SOURCE_DIR}/dmrtestfiles
${CMAKE_CURRENT_SOURCE_DIR}/cdltestfiles
${CMAKE_CURRENT_SOURCE_DIR}/baseline
${CMAKE_CURRENT_SOURCE_DIR}/baselineraw
)
SET(CUR_EXTRA_DIST ${CUR_EXTRA_DIST} CMakeLists.txt Makefile.am)
ADD_EXTRA_DIST("${CUR_EXTRA_DIST}")
