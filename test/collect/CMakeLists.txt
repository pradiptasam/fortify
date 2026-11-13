# Checks the --files mode of generate_collect_tests.py: only the listed files
# are collected, and the hooks are taken from the fortify_manager.f90 among them.
set(COLLECT_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/fortify_manager.f90
    ${CMAKE_CURRENT_SOURCE_DIR}/test_collect_a.f90
    ${CMAKE_CURRENT_SOURCE_DIR}/test_collect_b.f90)

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/collect_tests.f90
    COMMAND python3 ${PROJECT_SOURCE_DIR}/utils/generate_collect_tests.py
            --files ${COLLECT_FILES} --enable-setup-hooks
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS ${PROJECT_SOURCE_DIR}/utils/generate_collect_tests.py ${COLLECT_FILES}
    COMMENT "Generating collect_tests.f90 from a list of files"
)

add_executable(test_collect_files ${COLLECT_FILES} ${CMAKE_CURRENT_BINARY_DIR}/collect_tests.f90)
set_target_properties(test_collect_files PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/mod
)
target_link_libraries(test_collect_files Fortify)

add_test(NAME CollectFilesTest COMMAND test_collect_files)
