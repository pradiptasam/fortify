import os
import re
import sys
import argparse

# Anchored at the start of a line, so that neither "END SUBROUTINE" without a
# name nor the words in a comment are taken for a declaration.
MODULE_PATTERN = re.compile(r'^[ \t]*module[ \t]+(?!procedure\b)(\w+)',
                            re.IGNORECASE | re.MULTILINE)
SUBROUTINE_PATTERN = re.compile(
    r'^[ \t]*(?:(?:pure|impure|elemental|recursive|module)[ \t]+)*'
    r'subroutine[ \t]+(\w+)',
    re.IGNORECASE | re.MULTILINE)

def find_test_routines(test_files, hooks_file, enable_hooks):
    test_modules = []
    test_routines = {}
    hook_functions = {}

    # Define hook patterns
    hook_patterns = ['setup_tests', 'teardown_tests']

    # Step 1: Find test routines in test files
    for filepath in test_files:
        filename = os.path.basename(filepath)
        routine_names = set()

        if filename.lower().startswith("test_") and filename.lower().endswith(".f90"):
            with open(filepath, "r") as f:
                content = f.read()
                # Find the module name (case insensitive)
                module_match = MODULE_PATTERN.search(content)
                if module_match:
                    module_name = module_match.group(1)
                else:
                    print(f"Warning: No module found in {filename}, skipping.")
                    continue

                # Find test subroutines only
                all_matches = SUBROUTINE_PATTERN.findall(content)
                for match in all_matches:
                    # Only look for test routines (not hooks)
                    if match.lower().startswith('test_'):
                        routine_names.add(match)

                if routine_names:
                    test_modules.append(module_name)
                    test_routines[module_name] = list(routine_names)

                print(f"Found module: {module_name}, test routines: {routine_names}")

    if enable_hooks:
        # Step 2: Find hook functions in fortify_manager.f90
        fortify_manager_path = hooks_file
        if fortify_manager_path and os.path.exists(fortify_manager_path):
            hook_names = set()
            
            with open(fortify_manager_path, "r") as f:
                content = f.read()
                # Find the module name
                module_match = MODULE_PATTERN.search(content)
                if module_match:
                    hook_module_name = module_match.group(1)
                    
                    # Find all subroutines
                    all_matches = SUBROUTINE_PATTERN.findall(content)
                    for match in all_matches:
                        # Check if it's a hook function
                        if any(hook in match.lower() for hook in hook_patterns):
                            hook_names.add(match)
 
                    if hook_names:
                        test_modules.append(hook_module_name)
                        hook_functions[hook_module_name] = list(hook_names)
                        print(f"Found hook module: {hook_module_name}, hook functions: {hook_names}")
                else:
                    print(f"Warning: No module found in fortify_manager.f90")
        else:
            print("Info: fortify_manager.f90 not found")

    return test_modules, test_routines, hook_functions

def generate_collect_tests(test_modules, test_routines, hook_functions, enable_hooks):

    collect_file = "collect_tests.f90"
    with open(collect_file, "w") as f:
        f.write("program collect_tests\n")
        f.write("  use fortify\n")

        for module in test_modules:
            f.write(f"  use {module}\n")

        f.write("  implicit none\n\n")

        f.write("  interface\n")
        f.write("    subroutine TestProcInterface()\n")
        f.write("    end subroutine TestProcInterface\n")
        f.write("  end interface\n\n")

        if enable_hooks:
            f.write("  interface\n")
            f.write("    subroutine HookProcInterface()\n")
            f.write("    end subroutine HookProcInterface\n")
            f.write("  end interface\n\n")


        # Declare test pointers
        for module, routines in test_routines.items():
            for routine in routines:
                f.write(f"  procedure(TestProcInterface), pointer :: ptr_{routine} => null()\n")

        # Declare hook pointers
        if enable_hooks:
            for module, hooks in hook_functions.items():
                for hook in hooks:
                    f.write(f"  procedure(HookProcInterface), pointer :: ptr_{hook} => null()\n")
            f.write("\n")

        # Register hooks first
        if enable_hooks:
            for module, hooks in hook_functions.items():
                for hook in hooks:
                    f.write(f"  ptr_{hook} => {hook}\n")
                    if 'setup' in hook.lower():
                        f.write(f"  call register_setup_hook(ptr_{hook})\n")
                    elif 'teardown' in hook.lower():
                        f.write(f"  call register_teardown_hook(ptr_{hook})\n")
            f  .write("\n")

        # Register tests
        for module, routines in test_routines.items():
            for routine in routines:
                f.write(f"  ptr_{routine} => {routine}\n")
                f.write(f"  call register_test(ptr_{routine}, \"{routine}\")\n")

        f.write("\n")
        f.write("  ! Run all tests\n")
        f.write("  call run_tests()\n\n")

        f.write("end program collect_tests\n")

def main():

    parser = argparse.ArgumentParser(description='Generate Fortran test collector')
    parser.add_argument('test_directory', nargs='?',
                       help='Directory containing test files')
    parser.add_argument('--files', nargs='+', metavar='FILE',
                       help='Test files to collect, instead of a directory')
    parser.add_argument('--hooks-file', metavar='FILE',
                       help='File with the setup and teardown hooks (default: '
                            'fortify_manager.f90 in the directory or among --files)')
    parser.add_argument('--enable-setup-hooks', action='store_true', 
                       help='Enable Kokkos or other test hooks')

    args = parser.parse_args()

    if (args.test_directory is None) == (args.files is None):
        parser.error('give either a test directory or --files')

    if args.files is not None:
        test_files = args.files
        default_hooks_file = next((f for f in test_files
                                   if os.path.basename(f) == "fortify_manager.f90"), None)
    else:
        test_files = [os.path.join(args.test_directory, f)
                      for f in sorted(os.listdir(args.test_directory))]
        default_hooks_file = os.path.join(args.test_directory, "fortify_manager.f90")
    hooks_file = args.hooks_file or default_hooks_file

    test_modules, test_routines, hook_functions = find_test_routines(test_files, hooks_file, args.enable_setup_hooks)
    generate_collect_tests(test_modules, test_routines, hook_functions, args.enable_setup_hooks)

if __name__ == "__main__":
    main()
