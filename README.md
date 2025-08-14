# Fortify - Fortran Unit Testing Framework

## Overview

Fortify is a comprehensive unit testing framework for Fortran that strengthens your code through systematic testing. It provides a modern, easy-to-use interface for writing and executing unit tests with automatic test discovery, type-safe assertions, and colored output reporting.

## Key Features

- **Type-Generic Assertions**: Supports integers, real numbers (single/double precision), logical values, characters, and multi-dimensional arrays
- **Automatic Test Discovery**: Python script automatically finds and collects test files
- **Setup/Teardown Hooks**: Support for initialization and cleanup procedures
- **Colored Output**: Visual feedback with green/red colored test results
- **CMake Integration**: Modern build system with proper installation and packaging
- **Fypp Preprocessing**: Uses Fypp for generating type-specific assertion procedures

## Architecture

### Core Components

1. **`fortify.f90`** - Main wrapper module that re-exports all framework functionality
2. **`assert_equal.fypp`** - Fypp template file that generates type-specific assertion procedures
3. **`runner.f90`** - Test execution engine with hooks support and result reporting
4. **`generate_collect_tests.py`** - Python script for automatic test discovery and collection

### Build System

The framework uses CMake with the following structure:
- Root `CMakeLists.txt` handles project configuration and Fypp dependency
- `src/CMakeLists.txt` builds the Fortify library with generated assertion code
- Automatic generation of `assert_equal.f90` from the Fypp template during build

## Installation

### Prerequisites

- Modern Fortran compiler (supports Fortran 2008+)
- CMake (version 3.10 or higher)
- Python 3.x
- Fypp preprocessor (`pip install fypp`)

### Build Instructions

```bash
mkdir build && cd build
cmake ..
make
```

### Installation

```bash
make install
```

## Usage

### Writing Test Files

Test files should follow the naming convention `test_*.f90` and contain:

1. A module with test subroutines
2. Test subroutines starting with `test_`
3. Assertions using the provided assertion procedures

**Example test file (`test_math.f90`):**

```fortran
module test_math
  use fortify
  implicit none

contains

  subroutine test_addition()
    call assert_equal(4, 2 + 2, "Basic addition")
    call assert_equal(0, 5 - 5, "Subtraction to zero")
  end subroutine test_addition

  subroutine test_comparison()
    call assert_greater_than(5, 3, "Five greater than three")
    call assert_less_than_equal(2, 2, "Two less than or equal to two")
  end subroutine test_comparison

  subroutine test_array_operations()
    real(dp) :: array1(3) = [1.0_dp, 2.0_dp, 3.0_dp]
    real(dp) :: array2(3) = [1.0_dp, 2.0_dp, 3.0_dp]
    call assert_array_near(array1, array2, 1e-10_dp, "Array equality")
  end subroutine test_array_operations

end module test_math
```

### Generating Test Collection

Use the Python script to automatically discover and collect tests:

```bash
python generate_collect_tests.py /path/to/test/directory
```

This generates `collect_tests.f90` which:
- Discovers all `test_*.f90` files
- Extracts test subroutines (those starting with `test_`)
- Registers them with the test runner
- Optionally registers setup/teardown hooks

### Setup and Teardown Hooks

Create a `fortify_manager.f90` file for setup/teardown procedures:

```fortran
module fortify_manager
  implicit none
contains

  subroutine setup_tests()
    ! Initialize test environment
    print *, "Setting up test environment..."
  end subroutine setup_tests

  subroutine teardown_tests()
    ! Clean up after tests
    print *, "Cleaning up test environment..."
  end subroutine teardown_tests

end module fortify_manager
```

Enable hooks when generating the test collection:

```bash
python generate_collect_tests.py /path/to/test/directory --enable-setup-hooks
```

### Running Tests

Compile and run the generated test collection:

```bash
gfortran -o test_runner collect_tests.f90 -lFortify
./test_runner
```

## Assertion Reference

### Equality Assertions

| Function | Description | Supported Types |
|----------|-------------|-----------------|
| `assert_equal(expected, actual, test_name)` | Tests for equality | integer, real(sp), real(dp), logical, character |
| `assert_not_equal(expected, actual, test_name)` | Tests for inequality | integer, real(sp), real(dp), logical, character |

### Comparison Assertions

| Function | Description | Supported Types |
|----------|-------------|-----------------|
| `assert_less_than(val1, val2, test_name)` | Tests val1 < val2 | integer, real(sp), real(dp) |
| `assert_greater_than(val1, val2, test_name)` | Tests val1 > val2 | integer, real(sp), real(dp) |
| `assert_less_than_equal(val1, val2, test_name)` | Tests val1 <= val2 | integer, real(sp), real(dp) |
| `assert_greater_than_equal(val1, val2, test_name)` | Tests val1 >= val2 | integer, real(sp), real(dp) |

### Floating-Point Assertions

| Function | Description | Supported Types |
|----------|-------------|-----------------|
| `assert_almost_equal(val1, val2, tolerance, test_name)` | Tests approximate equality | real(sp), real(dp) |

### Logical Assertions

| Function | Description |
|----------|-------------|
| `assert_true(condition, test_name)` | Tests that condition is .true. |
| `assert_false(condition, test_name)` | Tests that condition is .false. |

### Array Assertions

| Function | Description | Supported Dimensions |
|----------|-------------|---------------------|
| `assert_array_near(array1, array2, tolerance, test_name)` | Tests arrays are approximately equal | 1D, 2D, 3D, 4D |

Arrays must have the same dimensions and all elements must be within the specified tolerance.

## Data Types

The framework supports the following data types:

- **`integer`** - Standard Fortran integers
- **`real(sp)`** - Single precision reals (32-bit)
- **`real(dp)`** - Double precision reals (64-bit)
- **`logical`** - Logical values (.true./.false.)
- **`character(len=*)`** - Variable-length character strings

Precision types are defined using ISO_FORTRAN_ENV:
```fortran
USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY: sp => real32, dp => real64
```

## Output Format

The framework provides colored output showing:

- **PASS/FAIL** status for each test
- Detailed failure messages with expected vs actual values
- Summary statistics with total tests and failures
- **Green** text for successful test runs
- **Red** text for failed tests or error conditions

Example output:
```
PASS: Basic addition
FAIL: Division test - Expected: 2 but got: 3
----------------------------------------
1 tests failed out of 2
----------------------------------------
```

## Integration with CMake

To use Fortify in your project, add it as a dependency:

```cmake
find_package(Fortify REQUIRED)
target_link_libraries(your_target Fortify)
```

The framework installs proper CMake configuration files for easy integration.

## Advanced Features

### Custom Hook Registration

The framework supports custom setup and teardown procedures:

```fortran
! Register hooks programmatically
call register_setup_hook(my_setup_procedure)
call register_teardown_hook(my_cleanup_procedure)
```

### Test Organization

Tests are organized using a linked list structure that allows:
- Dynamic registration of test procedures
- Proper memory management
- Sequential execution of all registered tests

### Error Handling

The framework tracks:
- Total number of tests executed (`num_tests`)
- Number of failed tests (`num_failures`)
- Automatic exit with error code 1 if any tests fail

## Best Practices

1. **Naming Convention**: Use `test_*.f90` for test files and `test_*` for test subroutines
2. **Descriptive Names**: Use meaningful test names that describe what is being tested
3. **Tolerance Values**: For floating-point comparisons, choose appropriate tolerance values
4. **Array Testing**: Ensure arrays have consistent dimensions before testing
5. **Setup/Teardown**: Use hooks for common initialization and cleanup tasks
6. **Modular Tests**: Keep tests focused and test one concept per subroutine

This framework provides a robust foundation for implementing Test-Driven Development (TDD) practices in Fortran projects, helping ensure code reliability and maintainability.
