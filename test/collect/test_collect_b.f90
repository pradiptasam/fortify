! The words module and subroutine in this comment, and the END SUBROUTINE
! statements without a name below, must not hide the tests from the collector.
MODULE test_collect_b
  USE fortify
  USE fortify_manager, ONLY: tests_run
  IMPLICIT NONE
CONTAINS

  SUBROUTINE TEST_SECOND_FILE_COLLECTED
    tests_run = tests_run + 1
    CALL assert_equal(1, 1, "Test in a second listed file")
  END SUBROUTINE

  SUBROUTINE TEST_AFTER_UNNAMED_END
    tests_run = tests_run + 1
    CALL assert_equal(1, 1, "Test after an END SUBROUTINE without a name")
  END SUBROUTINE

END MODULE test_collect_b
