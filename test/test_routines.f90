program test_fortify
  use check_assertions
  USE, INTRINSIC :: ISO_FORTRAN_ENV, ONLY: sp => real32, &
    &                                      dp => real64
  implicit none

  integer :: num_failures=0
  real(sp), dimension(3) :: array1_sp, array2_sp
  real(dp), dimension(3) :: array1_dp, array2_dp
  real(sp), dimension(2, 2) :: array2d1_sp, array2d2_sp
  real(dp), dimension(2, 2) :: array2d1_dp, array2d2_dp
  ! Tolerance values
  real(sp) :: tolerance_sp = 0.01_sp
  real(dp) :: tolerance_dp = 1.0e-6_dp

  ! Test cases for assert_equal
  call assert_equal(42, 42, "Integer Equal Test", num_failures)
  call assert_equal(3.14_dp, 3.14_dp, "Real_dp Equal Test", num_failures)
  call assert_equal(3.14_sp, 3.14_sp, "Real_sp Equal Test", num_failures)
  call assert_equal(.true., .true., "Logical Equal Test", num_failures)
  call assert_equal("hello", "hello", "Character Equal Test", num_failures)

  ! Test cases for assert_not_equal
  call assert_not_equal(42, 43, "Integer Not Equal Test", num_failures)
  call assert_not_equal(3.1401_dp, 3.14_dp, "Real_dp Not Equal Test", num_failures)
  call assert_not_equal(3.1401_sp, 3.14_sp, "Real_sp Not Equal Test", num_failures)
  call assert_not_equal(.true., .false., "Logical Not Equal Test", num_failures)
  call assert_not_equal("hello", "world", "Character Not Equal Test", num_failures)

  ! Test cases for assert_less_than
  call assert_less_than(42, 43, "Integer Less Than Test", num_failures)
  call assert_less_than(3.1401_dp, 3.1402_dp, "Real_dp Less Than Test", num_failures)
  call assert_less_than(3.1401_sp, 3.1402_sp, "Real_sp Less Than Test", num_failures)

  ! Test cases for assert_greater_than
  call assert_greater_than(43, 42, "Integer Greater Than Test", num_failures)
  call assert_greater_than(3.1402_dp, 3.1401_dp, "Real_dp Greater Than Test", num_failures)
  call assert_greater_than(3.1402_sp, 3.1401_sp, "Real_sp Greater Than Test", num_failures)

  ! Test cases for assert_less_than_equal
  call assert_less_than_equal(42, 43, "Integer Less Than Test", num_failures)
  call assert_less_than_equal(3.1401_dp, 3.1401_dp, "Real_dp Less Than Test", num_failures)
  call assert_less_than_equal(3.1401_sp, 3.1401_sp, "Real_sp Less Than Test", num_failures)

  ! Test cases for assert_greater_than_equal
  call assert_greater_than_equal(43, 42, "Integer Greater Than Test", num_failures)
  call assert_greater_than_equal(3.1402_dp, 3.1401_dp, "Real_dp Greater Than Test", num_failures)
  call assert_greater_than_equal(3.1402_sp, 3.1401_sp, "Real_sp Greater Than Test", num_failures)

  call assert_true(.true., "Logical True Test", num_failures)
  call assert_false(.false., "Logical False Test", num_failures)

  ! Initialize single-precision 1D arrays
  array1_sp = [1.0_sp, 2.0_sp, 3.0_sp]
  array2_sp = [1.0_sp, 2.001_sp, 3.0_sp]

  ! Initialize double-precision 1D arrays
  array1_dp = [1.0_dp, 2.0_dp, 3.0_dp]
  array2_dp = [1.0_dp, 2.0000001_dp, 3.0_dp]

  ! Initialize single-precision 2D arrays
  array2d1_sp = reshape([1.0_sp, 2.0_sp, 3.0_sp, 4.0_sp], shape=[2, 2])
  array2d2_sp = reshape([1.0_sp, 2.001_sp, 3.0_sp, 4.0_sp], shape=[2, 2])

  ! Initialize double-precision 2D arrays
  array2d1_dp = reshape([1.0_dp, 2.0_dp, 3.0_dp, 4.0_dp], shape=[2, 2])
  array2d2_dp = reshape([1.0_dp, 2.0000001_dp, 3.0_dp, 4.0_dp], shape=[2, 2])

  ! Test 1D single-precision arrays
  call assert_array_near(array1_sp, array2_sp, tolerance_sp, "1D SP Array Near Test", num_failures)

  ! Test 1D double-precision arrays
  call assert_array_near(array1_dp, array2_dp, tolerance_dp, "1D DP Array Near Test", num_failures)

  ! Test 2D single-precision arrays
  call assert_array_near(array2d1_sp, array2d2_sp, tolerance_sp, "2D SP Array Near Test", num_failures)

  ! Test 2D double-precision arrays
  call assert_array_near(array2d1_dp, array2d2_dp, tolerance_dp, "2D DP Array Near Test", num_failures)


  print *, "All tests completed!"

    ! Print summary and exit with failure code if needed
  if (num_failures > 0) then
      print *, "Test failed. Number of failures:", num_failures
      call exit(1)  ! Non-zero exit code signals failure
  else
      print *, "All tests passed successfully!"
      call exit(0)  ! Zero exit code signals success
  end if

end program test_fortify
