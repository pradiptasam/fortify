cmake_minimum_required(VERSION 3.10)
project(Fortify LANGUAGES Fortran)

# Set the output directories
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Set the Fortran standard to 2008
# set(CMAKE_Fortran_STANDARD 2008)
message(STATUS "Fortran standard: ${CMAKE_Fortran_STANDARD}")
#set(CMAKE_Fortran_STANDARD_REQUIRED OFF)
# set(CMAKE_Fortran_EXTENSIONS OFF)

include(FetchContent)

# # Fetch Fypp
FetchContent_Declare(
  fypp
  GIT_REPOSITORY https://github.com/aradi/fypp.git
  GIT_TAG 3.2  # Use the appropriate tag or branch
)

FetchContent_MakeAvailable(fypp)

set(FYPP_EXECUTABLE ${fypp_SOURCE_DIR}/bin/fypp)

include(GNUInstallDirs)

# Add the source directory
add_subdirectory(src)

# Add the test directory
enable_testing()
if(ENABLE_TESTING)
  add_subdirectory(test)
endif()

include(CMakePackageConfigHelpers)
configure_package_config_file(
  "${PROJECT_SOURCE_DIR}/cmake/config.cmake.in"
  "${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config.cmake"
  INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake"
  NO_SET_AND_CHECK_MACRO NO_CHECK_REQUIRED_COMPONENTS_MACRO)

export(EXPORT "${PROJECT_NAME}-targets"
       FILE "${PROJECT_BINARY_DIR}/${PROJECT_NAME}-targets.cmake")

write_basic_package_version_file(
  "${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake"
  VERSION "${${PROJECT_NAME}_VERSION_MAJOR}.${${PROJECT_NAME}_VERSION_MINOR}"
  COMPATIBILITY AnyNewerVersion)

install(EXPORT "${PROJECT_NAME}-targets"
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/${PROJECT_NAME}/cmake")

install(FILES "${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config.cmake"
              "${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake"
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/${PROJECT_NAME}/cmake")

