module check_assertions
    implicit none

contains

    subroutine assert_equal(expected, actual, test_name)
        real, intent(in) :: expected, actual
        character(len=*), intent(in) :: test_name

        if (expected /= actual) then
            print *, "FAIL: ", test_name, " - Expected: ", expected, " but got: ", actual
        else
            print *, "PASS: ", test_name
        end if
    end subroutine assert_equal

    subroutine assert_true(condition, test_name)
        logical, intent(in) :: condition
        character(len=*), intent(in) :: test_name

        if (.not. condition) then
            print *, "FAIL: ", test_name, " - Condition is false."
        else
            print *, "PASS: ", test_name
        end if
    end subroutine assert_true

end module check_assertions
