module Worklog.TaskSpec
  ( tests
  )
where

import Worklog.Implementation.Internal

import Test.Tasty
import Test.Tasty.HUnit
import Worklog.Task

testTask :: Task
testTask = newTask (mkSummary "Task")

tests :: TestTree
tests =
  testGroup
    "Worklog.Task"
    [ taskTests
    ]

taskTests :: TestTree
taskTests =
  testGroup
    "\tTask tests:"
    [ testCase "HasSummary instance - get Summary" $
        summaryText (getSummary testTask) @?= "Task",
      testCase "HasSummary instance - set Summary" $
        summaryText (getSummary (testTask `setSummary` mkSummary "TODO")) @?= "TODO"
    ]
