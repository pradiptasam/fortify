import os
import re
import sys

def find_test_routines(directory, files):
    test_modules = []
    test_routines = {}
    hook_functions = {}  # Add this to track hooks

    # Define hook patterns
    hook_patterns = ['setup_tests', 'teardown_tests']

    # if files is not Empty, then only consider those files
    if files:
        filenames = files
    else:
        filenames = os.listdir(directory)

    print(f"Files: {filenames}")
    for filepath in filenames:
        filename=os.path.basename(filepath)
        routine_names = set()
        hook_names = set()

        if filename.lower().startswith("test_") and filename.lower().endswith(".f90"):
            # module_name = filename[:-4]
            with open(os.path.join(directory, filename), "r") as f:
                content = f.read()
                # Find the module name (case insensitive)
                module_match = re.search(r'\bmodule\s+(\w+)', content, re.IGNORECASE)
                if module_match:
                    module_name = module_match.group(1)
                else:
                    print(f"Warning: No module found in {filename}, skipping.")
                    continue

                # Find all subroutines
                all_matches = re.findall(r'\bsubroutine\s+(\w+)', content, re.IGNORECASE)

                for match in all_matches:
                    # Check if it's a hook function
                    if any(hook in match.lower() for hook in hook_patterns):
                        hook_names.add(match)
                    # Otherwise, if it starts with test_, it's a test
                    elif match.lower().startswith('test_'):
                        routine_names.add(match)

                if routine_names or hook_names:
                    test_modules.append(module_name)
                    test_routines[module_name] = list(routine_names)
                    hook_functions[module_name] = list(hook_names)

    return test_modules, test_routines, hook_functions

def generate_collect_tests(directory, test_modules, test_routines, hook_functions):

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

        f.write("  interface\n")
        f.write("    subroutine HookProcInterface()\n")
        f.write("    end subroutine HookProcInterface\n")
        f.write("  end interface\n\n")

        # Declare test pointers
        for module, routines in test_routines.items():
            for routine in routines:
                f.write(f"  procedure(TestProcInterface), pointer :: ptr_{routine} => null()\n")

        # Declare hook pointers
        for module, hooks in hook_functions.items():
            for hook in hooks:
                f.write(f"  procedure(HookProcInterface), pointer :: ptr_{hook} => null()\n")
        f.write("\n")

        # Register hooks first
        for module, hooks in hook_functions.items():
            for hook in hooks:
                f.write(f"  ptr_{hook} => {hook}\n")
                if 'setup' in hook.lower():
                    f.write(f"  call register_setup_hook(ptr_{hook})\n")
                elif 'teardown' in hook.lower():
                    f.write(f"  call register_teardown_hook(ptr_{hook})\n")
        f.write("\n")

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

    if len(sys.argv) == 1:
        print("Usage: python3 generate_collect_tests.py <test_directory>")
        sys.exit(1)

    test_directory = sys.argv[1]
    test_files = []
    if len(sys.argv) > 2:
        # test_files = sys.argv[2].split()
        test_files = sys.argv[2:]

    if not os.path.isdir(test_directory):
        print(f"Error: Directory '{test_directory}' does not exist.")
        sys.exit(1)

    test_modules, test_routines, hook_functions = find_test_routines(test_directory, test_files)
    generate_collect_tests(test_directory, test_modules, test_routines, hook_functions)

if __name__ == "__main__":
    main()
