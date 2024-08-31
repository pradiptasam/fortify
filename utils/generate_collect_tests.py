import os
import re
import sys

def find_test_routines(directory):
    test_modules = []
    test_routines = {}

    for filename in os.listdir(directory):
        routine_names = set()
        if filename.startswith("test_") and filename.endswith(".f90"):
            module_name = filename[:-4]
            with open(os.path.join(directory, filename), "r") as f:
                content = f.read()
                matches = re.findall(r'\bsubroutine\s+(test_\w+)', content)
                unique_matches = [match for match in matches if match not in routine_names]
                if unique_matches:
                    test_modules.append(module_name)
                    # test_routines[module_name] = unique_matches
                    routine_names.update(unique_matches)
                    # Set to array
                    test_routines[module_name] = list(routine_names)

    return test_modules, test_routines

def generate_collect_tests(directory, test_modules, test_routines):
    # collect_file = os.path.join(directory, "collect_tests.f90")
    collect_file = "collect_tests.f90"
    with open(collect_file, "w") as f:
        f.write("program collect_tests\n")
        f.write("  use fortify_runner\n")

        for module in test_modules:
            f.write(f"  use {module}\n")

        f.write("  implicit none\n\n")

        f.write("  interface\n")
        f.write("    subroutine TestProcInterface()\n")
        f.write("    end subroutine TestProcInterface\n")
        f.write("  end interface\n\n")

        for module, routines in test_routines.items():
            for routine in routines:
                f.write(f"  procedure(TestProcInterface), pointer :: ptr_{routine} => null()\n")

        f.write("\n")

        for module, routines in test_routines.items():
            for routine in routines:
                f.write(f"  ptr_{routine} => {routine}\n")
                f.write(f"  call register_test(ptr_{routine}, \"{routine}\")\n")

        f.write("\n")
        f.write("  ! Run all tests\n")
        f.write("  call run_tests()\n\n")

        f.write("end program collect_tests\n")

def main():

    if len(sys.argv) != 2:
        print("Usage: python3 generate_collect_tests.py <test_directory>")
        sys.exit(1)

    test_directory = sys.argv[1]

    if not os.path.isdir(test_directory):
        print(f"Error: Directory '{test_directory}' does not exist.")
        sys.exit(1)

    test_modules, test_routines = find_test_routines(test_directory)
    generate_collect_tests(test_directory, test_modules, test_routines)

if __name__ == "__main__":
    main()
