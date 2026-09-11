module Worklog.TodoSpec
  ( tests
  )
where

import Worklog.Implementation.Internal

import Test.Tasty
import Test.Tasty.HUnit
import Worklog.Todo

testTodo :: Todo
testTodo = newTodo NotSoUrgent (mkSummary "Todo")

tests :: TestTree
tests =
  testGroup
    "Worklog.Todo"
    [ todoTests
    ]

todoTests :: TestTree
todoTests =
  testGroup
    "\tTodo tests:"
    [ testCase "HasSummary instance - get Summary" $
        summaryText (getSummary testTodo) @?= "Todo",
      testCase "HasSummary instance - set Summary" $
        summaryText (getSummary (testTodo `setSummary` mkSummary "TODO")) @?= "TODO"
    ]
