module fortify_runner
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

  ! type(test_case), allocatable :: tests(:)
  ! integer :: num_tests = 0
  !
  type node
    type(test_case) :: test
    character(len=:), allocatable :: test_name
    type(node), pointer :: next => null()
  end type node

  type(node), pointer :: head => null(), tail => null()
  integer :: num_tests = 0

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

    num_tests = num_tests + 1

  end subroutine register_test

  subroutine run_tests(ierr)
    integer, intent(inout) :: ierr
    type(node), pointer :: current
    integer :: total_tests = 0

    character(len=*), parameter :: RESET = char(27) // "[0m"
    character(len=*), parameter :: RED = char(27) // "[31m"
    character(len=*), parameter :: GREEN = char(27) // "[32m"

    current => head
    do while(associated(current))
      call current%test%test_function(ierr)
      current => current%next
      total_tests = total_tests + 1
    end do

    if (ierr /= 0) then
         print *, RED, ierr, " tests failed out of ", total_tests, RESET
     else
         print *, GREEN, "All tests passed", RESET
     end if

  end subroutine run_tests

end module fortify_runner
