cmake_minimum_required(VERSION 3.10)
project(Fortify LANGUAGES Fortran)

# Set the output directories
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Add the source directory
add_subdirectory(src)

# Add the test directory
enable_testing()
add_subdirectory(test)
