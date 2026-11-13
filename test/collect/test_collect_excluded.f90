! Not passed to generate_collect_tests.py and not compiled: if the script
! collected it anyway, collect_tests.f90 would fail to compile.
module test_collect_excluded
  use fortify
  implicit none
contains

  subroutine test_not_listed()
    call assert_equal(1, 2, "Test in a file that was not listed")
  end subroutine test_not_listed

end module test_collect_excluded
