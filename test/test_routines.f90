module test_routines
  use check_assertions

  implicit none

  public :: test_addition, test_boolean

  contains

  subroutine test_addition()
    call assert_equal(2.0, 1.0 + 1.0, "test_addition")
  end subroutine test_addition

  subroutine test_boolean()
    call assert_equal(.true., .true., "test_boolean")
  end subroutine test_boolean

end module test_routines
