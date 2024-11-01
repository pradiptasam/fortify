add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/collect_tests.f90
    COMMAND ${CMAKE_COMMAND} -E env python3 ${CMAKE_SOURCE_DIR}/utils/generate_collect_tests.py ${CMAKE_SOURCE_DIR}/test
    DEPENDS ${CMAKE_SOURCE_DIR}/test/test_*.f90
    COMMENT "Generating collect_tests.f90"
)

file(GLOB TEST_FILES *.f90)

# Create the executable for testing
add_executable(test_fortify ${TEST_FILES} collect_tests.f90)

# Set the runtime output directory for the test executable to be within the test folder
set_target_properties(test_fortify PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)

# Link the Fortify library with the test executable
target_link_libraries(test_fortify Fortify)

# Add the test
add_test(NAME FortifyTest COMMAND test_fortify)
