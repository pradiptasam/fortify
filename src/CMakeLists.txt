file(GLOB SRC_FILES *.f90)

# Create the library from the source files
# add_library(Fortify STATIC ${SRC_FILES})

add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/assert_equal.f90
  COMMAND ${Python3_EXECUTABLE} ${FYPP_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/assert_equal.fypp ${CMAKE_CURRENT_BINARY_DIR}/assert_equal.f90
  MAIN_DEPENDENCY ${CMAKE_CURRENT_SOURCE_DIR}/assert_equal.fypp
  COMMENT "Generating Fortran assert_equal routines with Fypp"
)

# Include the generated file in the library
add_library(Fortify
  ${CMAKE_CURRENT_BINARY_DIR}/assert_equal.f90
  ${CMAKE_CURRENT_SOURCE_DIR}/../utils/color_utils.f90
  ${CMAKE_CURRENT_SOURCE_DIR}/runner.f90
)

# Optionally, specify the properties of the library
set(Fortran_MODULE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/mod")
set_target_properties(Fortify PROPERTIES
  Fortran_MODULE_DIRECTORY "${Fortran_MODULE_DIRECTORY}"
)

target_include_directories(Fortify PUBLIC
    $<BUILD_INTERFACE:$<$<COMPILE_LANGUAGE:Fortran>:${Fortran_MODULE_DIRECTORY}>>
    # $<INSTALL_INTERFACE:include>
    $<INSTALL_INTERFACE:$<$<COMPILE_LANGUAGE:Fortran>:${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR}>>
)

install(TARGETS Fortify EXPORT "${PROJECT_NAME}-targets")

install(DIRECTORY "${Fortran_MODULE_DIRECTORY}/" TYPE INCLUDE)
