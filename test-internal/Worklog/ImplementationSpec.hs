module Worklog.ImplementationSpec
  ( tests
  )
where

import Worklog.Implementation.Internal

import Test.Tasty
import Test.Tasty.HUnit
import Data.Char (toUpper)

tests :: TestTree
tests =
  testGroup
    "Worklog.Implementation"
    [ implementationTests
    ]

implementationTests:: TestTree
implementationTests =
  testGroup
    "\tImplementation tests:"
    [ testCase "Get summary?" $
        summaryText (mkSummary "Hello") @?= "Hello",
      testCase "Modify summary?" $
        summaryText (mapSummary (map toUpper) (mkSummary "Hello")) @?= "HELLO"
    ]
