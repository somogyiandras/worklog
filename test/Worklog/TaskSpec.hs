module Worklog.TaskSpec
(
    tests
) where

import Test.Tasty
import Test.Tasty.HUnit

import Worklog.Task

taskClosed = Task 1 "Closed task" Normal Closed NoDeadline
taskOpen = Task 2 "Open task" Normal Open NoDeadline
taskReviewed = Task 3 "Reviewed task" Normal Reviewed NoDeadline
taskImportant = Task 4 "Important task" Important Open NoDeadline

tests :: TestTree
tests =
    testGroup "Worklog.Task" [testStatus, testPriority]

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

