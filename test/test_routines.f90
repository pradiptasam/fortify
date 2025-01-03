program test_fortify
  use check_assertions
  USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY: sp => real32, &
    &                                      dp => real64
  implicit none

  ! Test cases for assert_equal
  call assert_equal(42, 42, "Integer Equal Test")
  call assert_equal(3.14_dp, 3.14_dp, "Real_dp Equal Test")
  call assert_equal(3.14_sp, 3.14_sp, "Real_sp Equal Test")
  call assert_equal(.true., .true., "Logical Equal Test")
  call assert_equal("hello", "hello", "Character Equal Test")

  ! Test cases for assert_not_equal
  call assert_not_equal(42, 43, "Integer Not Equal Test")
  call assert_not_equal(3.1401_dp, 3.14_dp, "Real_dp Not Equal Test")
  call assert_not_equal(3.1401_sp, 3.14_sp, "Real_sp Not Equal Test")
  call assert_not_equal(.true., .false., "Logical Not Equal Test")
  call assert_not_equal("hello", "world", "Character Not Equal Test")

  ! Test cases for assert_less_than
  call assert_less_than(42, 43, "Integer Less Than Test")
  call assert_less_than(3.1401_dp, 3.1402_dp, "Real_dp Less Than Test")
  call assert_less_than(3.1401_sp, 3.1402_sp, "Real_sp Less Than Test")

  ! Test cases for assert_greater_than
  call assert_greater_than(43, 42, "Integer Greater Than Test")
  call assert_greater_than(3.1402_dp, 3.1401_dp, "Real_dp Greater Than Test")
  call assert_greater_than(3.1402_sp, 3.1401_sp, "Real_sp Greater Than Test")

  ! Test cases for assert_less_than_equal
  call assert_less_than_equal(42, 43, "Integer Less Than Test")
  call assert_less_than_equal(3.1401_dp, 3.1401_dp, "Real_dp Less Than Test")
  call assert_less_than_equal(3.1401_sp, 3.1401_sp, "Real_sp Less Than Test")

  ! Test cases for assert_greater_than_equal
  call assert_greater_than_equal(43, 42, "Integer Greater Than Test")
  call assert_greater_than_equal(3.1402_dp, 3.1401_dp, "Real_dp Greater Than Test")
  call assert_greater_than_equal(3.1402_sp, 3.1401_sp, "Real_sp Greater Than Test")

  call assert_true(.true., "Logical True Test")
  call assert_false(.false., "Logical False Test")

  print *, "All tests completed!"

end program test_fortify
