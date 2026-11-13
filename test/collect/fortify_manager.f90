module fortify_manager
  use fortify
  implicit none
  logical :: setup_done = .false.
  integer :: tests_run = 0
contains

  subroutine setup_tests()
    setup_done = .true.
  end subroutine setup_tests

  ! Fails if the collector missed one of the three tests in the listed files.
  subroutine teardown_tests()
    call assert_equal(3, tests_run, "All tests of the listed files ran")
  end subroutine teardown_tests

end module fortify_manager
