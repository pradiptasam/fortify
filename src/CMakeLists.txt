file(GLOB SRC_FILES *.f90)

set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -std=f2003")

# Create the library from the source files
add_library(Fortify STATIC ${SRC_FILES})

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
