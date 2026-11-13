module test_collect_a
  use fortify
  use fortify_manager, only: setup_done, tests_run
  implicit none
contains

  subroutine test_setup_hook_ran()
    tests_run = tests_run + 1
    call assert_equal(setup_done, .true., "Setup hook ran before the tests")
  end subroutine test_setup_hook_ran

end module test_collect_a
