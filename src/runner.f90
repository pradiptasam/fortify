module fortify_runner
  use color_utils
  implicit none

  abstract interface
    subroutine test_procedure()
    end subroutine test_procedure
  end interface

  abstract interface
    subroutine hook_procedure()
    end subroutine hook_procedure
  end interface

  procedure(test_procedure), pointer :: test_function => null()

  ! Add hooks support
  procedure(hook_procedure), pointer :: setup_hook => null()
  procedure(hook_procedure), pointer :: teardown_hook => null()

  type :: test_case
    character(len=100) :: test_name
    procedure(test_procedure), pointer, nopass :: test_function => null()
  end type test_case

  type node
    type(test_case) :: test
    character(len=:), allocatable :: test_name
    type(node), pointer :: next => null()
  end type node

  type(node), pointer :: head => null(), tail => null()
  integer :: num_tests = 0
  integer :: num_failures = 0

contains

  ! Add hook registration subroutines
  subroutine register_setup_hook(hook_function)
    procedure(hook_procedure), pointer, intent(in) :: hook_function
    setup_hook => hook_function
  end subroutine register_setup_hook

  subroutine register_teardown_hook(hook_function)
    procedure(hook_procedure), pointer, intent(in) :: hook_function
    teardown_hook => hook_function
  end subroutine register_teardown_hook

  subroutine register_test(test_function, test_name)
    procedure(test_procedure), pointer, intent(in) :: test_function
    character(len=*), intent(in) :: test_name
    type(node), pointer :: new_node

    allocate(new_node)
    new_node%test%test_function => test_function
    new_node%test_name = test_name
    new_node%next => null()

    if (.not. associated(head)) then
      head => new_node
      tail => new_node
    else
      tail%next => new_node
      tail => new_node
    end if

  end subroutine register_test

  subroutine run_tests()
    type(node), pointer :: current
    character(len=20) :: ierr_str, total_tests_str

    ! Call setup hook if registered
    if (associated(setup_hook)) then
      write(*,*) "Running setup..."
      call setup_hook()
    end if

    current => head
    do while(associated(current))
      call current%test%test_function()
      current => current%next
    end do

    ! Call teardown hook if registered
    if (associated(teardown_hook)) then
      write(*,*) "Running teardown..."
      call teardown_hook()
    end if

    ! Convert integers to strings
    write(ierr_str, '(I0)') num_failures
    write(total_tests_str, '(I0)') num_tests

    write(*,*) "----------------------------------------"
    if (num_failures /= 0) then
      call print_colored(trim(ierr_str) // " tests failed out of " // trim(total_tests_str), RED)
      call exit(1)
    else
      call print_colored("All " // trim(total_tests_str) // " tests passed", GREEN)
    end if
    write(*,*) "----------------------------------------"

  end subroutine run_tests

end module fortify_runner
