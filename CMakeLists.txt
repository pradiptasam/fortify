cmake_minimum_required(VERSION 3.10)
project(Fortify LANGUAGES Fortran)

# Set the output directories
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# include(FetchContent)
#
# # Fetch Fypp
# FetchContent_Declare(
#   fypp
#   GIT_REPOSITORY https://github.com/aradi/fypp.git
#   GIT_TAG 3.2  # Use the appropriate tag or branch
# )
#
# FetchContent_MakeAvailable(fypp)

# Try to find the Fypp executable
find_program(FYPP_EXECUTABLE fypp)

# Check if it was found
if(NOT FYPP_EXECUTABLE)
    message(FATAL_ERROR "Fypp not found. Please install Fypp or provide the path to the executable.")
else()
    message(STATUS "Found Fypp: ${FYPP_EXECUTABLE}")
endif()

# Make the Fypp executable available to the parent scope
set(FYPP_EXECUTABLE ${FYPP_EXECUTABLE} CACHE STRING "Path to the Fypp executable")

include(GNUInstallDirs)

# Add the source directory
add_subdirectory(src)

# Add the test directory
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

