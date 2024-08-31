file(GLOB SRC_FILES *.f90)

set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -std=f2003")

# Create the library from the source files
add_library(Fortify STATIC ${SRC_FILES})

# Optionally, specify the properties of the library
set_target_properties(Fortify PROPERTIES
    Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules
)

target_include_directories(Fortify PUBLIC
    $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/modules>
    $<INSTALL_INTERFACE:include>
)
