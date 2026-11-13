module test_collect_b
  use fortify
  implicit none
contains

  subroutine test_second_file_collected()
    call assert_equal(1, 1, "Test in a second listed file")
  end subroutine test_second_file_collected

end module test_collect_b
