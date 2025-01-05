module color_utils
    implicit none
    character(len=*), parameter :: RESET = char(27) // "[0m"
    character(len=*), parameter :: RED = char(27) // "[31m"
    character(len=*), parameter :: GREEN = char(27) // "[32m"
contains
    subroutine print_colored(text, color)
        character(len=*), intent(in) :: text, color
        print *, color, text, RESET
    end subroutine print_colored
end module color_utils
