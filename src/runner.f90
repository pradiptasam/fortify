module fortify_runner
  use color_utils
  implicit none

  abstract interface
  subroutine test_procedure(ierr)
    integer, intent(inout) :: ierr
  end subroutine test_procedure
  end interface
  procedure(test_procedure), pointer :: test_function => null()

  type :: test_case
    character(len=100) :: test_name
    ! contains
    procedure(test_procedure), pointer, nopass :: test_function => null()
  end type test_case

  type node
    type(test_case) :: test
    character(len=:), allocatable :: test_name
    type(node), pointer :: next => null()
  end type node

  type(node), pointer :: head => null(), tail => null()
  integer :: num_tests = 0
  integer :: num_failed = 0

  contains

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

  subroutine run_tests(ierr)
    integer, intent(inout) :: ierr
    type(node), pointer :: current
    character(len=20) :: ierr_str, total_tests_str

    current => head
    do while(associated(current))
      call current%test%test_function(ierr)
      current => current%next
    end do

    ! Convert integers to strings
    write(ierr_str, '(I0)') num_failed
    write(total_tests_str, '(I0)') num_tests

    write(*,*) "----------------------------------------"
    if (ierr /= 0) then
      call print_colored(trim(ierr_str) // " tests failed out of " // trim(total_tests_str), RED)
    else
      call print_colored("All " // trim(total_tests_str) // " tests passed", GREEN)
    end if
    write(*,*) "----------------------------------------"

  end subroutine run_tests

end module fortify_runner
