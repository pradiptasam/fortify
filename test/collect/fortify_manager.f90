module fortify_manager
  implicit none
  logical :: setup_done = .false.
contains

  subroutine setup_tests()
    setup_done = .true.
  end subroutine setup_tests

  subroutine teardown_tests()
  end subroutine teardown_tests

end module fortify_manager
