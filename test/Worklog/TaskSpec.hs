module Worklog.TaskSpec
  ( tests,
  )
where

import Test.Tasty
import Test.Tasty.HUnit
import Worklog.Task


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
        taskId (mkTask 0 "Test task") @?= 0,
      testCase "is it open?" $
        taskStatus (mkTask 0 "Test task") @?= Open,
      testCase "is it normal priority?" $
        taskPriority (mkTask 0 "Test task") @?= Normal,
      testCase "has not it deadline?" $
        taskDeadline (mkTask 0 "Test task") @?= NoDeadline,
      testCase "has it empty summary?" $
        getSummary (mkTask 0 "Test task") @?= emptySummary,
      testCase "Can I close?" $
        taskStatus (closeTask (mkTask 0 "Test task")) @?= Closed,
      testCase "Does opening and closing is id?" $
        openTask (closeTask (mkTask 0 "Test task")) @?= mkTask 0 "Test task"
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
