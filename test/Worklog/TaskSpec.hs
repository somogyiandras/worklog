module Worklog.TaskSpec
  ( tests,
  )
where

import Test.Tasty
import Test.Tasty.HUnit
import Worklog.Task

taskClosed = Task 1 "Closed task" Normal Closed NoDeadline

taskOpen = Task 2 "Open task" Normal Open NoDeadline

taskReviewed = Task 3 "Reviewed task" Normal Reviewed NoDeadline

taskImportant = Task 4 "Important task" Important Open NoDeadline

tests :: TestTree
tests =
  testGroup
    "Worklog.Task"
    [ initialization
    -- , testStatus
    -- , testPriority
    ]

initialization :: TestTree
initialization =
  testGroup
    "Task initialization and setting functions"
    [ testCase "Is taskId zero?" $
        taskId initTask @?= 0,
      testCase "is it open?" $
        taskStatus initTask @?= Open,
      testCase "is it normal priority?" $
        taskPriority initTask @?= Normal,
      testCase "has not it deadline?" $
        taskDeadline initTask @?= NoDeadline,
      testCase "has it empty summary?" $
        taskSummary initTask @?= emptySummary,
      testCase "Can I close?" $
        taskStatus (closeTask initTask) @?= Closed,
      testCase "Does opening and closing is id?" $
        openTask (closeTask initTask) @?= initTask
    ]

{-
testStatus :: TestTree
testStatus =
    testGroup "\tStatus functions:"
        [ testCase "isFinished Closed" $
            isFinished taskClosed @?= True

        , testCase "isFinished Open" $
            isFinished taskOpen @?= False

        , testCase "isOpen Open" $
            isOpen taskOpen @?= True

        , testCase "isOpen Closed" $
            isOpen taskClosed @?= False

        , testCase "isOpen Reviewed" $
            isOpen taskReviewed @?= False
        ]

testPriority :: TestTree
testPriority =
    testGroup "\tPriority functions:"
        [ testCase "isImportant Normal" $
            isImportant taskOpen @?= False

        , testCase "checking compare:" $
            (taskPriority taskImportant >= taskPriority taskOpen) @?= True
        ]
-}
