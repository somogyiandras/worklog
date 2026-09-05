module Worklog.TodoSpec
  ( tests
  )
where

import Worklog.Implementation.Internal

import Test.Tasty
import Test.Tasty.HUnit
import Worklog.Todo

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
    [ testCase "Get summary?" $
        summaryText (getSummary (mkTodo NotSoUrgent (mkSummary "Todo?"))) == "Todo?" @?= True
    ]
