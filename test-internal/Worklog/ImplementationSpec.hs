module Worklog.ImplementationSpec
  ( tests
  )
where

import Worklog.Implementation.Internal

import Test.Tasty
import Test.Tasty.HUnit
import Data.Char (toUpper)

data TestHasSummary = T Int Summary
  deriving (Eq, Show)

instance HasSummary TestHasSummary where
  getSummary (T _ s) = s
  setSummary (T i _) s = T i s


testHasSummary :: TestHasSummary
testHasSummary = T 1 (mkSummary "Test")

testSummary :: Summary
testSummary = mkSummary "Test"

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
    [ testCase "Read from summary" $
        summaryText testSummary @?= "Test",
      testCase "Modify summary" $
        summaryText (mapSummary (map toUpper) testSummary) @?= "TEST",
      testCase "Type class HasSummary - get summary" $
        getSummary testHasSummary @?= testSummary,
      testCase "Type class HasSummary - set summary" $
        getSummary (testHasSummary `setSummary` emptySummary) @?= emptySummary,
      testCase "Type class HasSummary - append summary" $
        getSummary (testHasSummary `appendSummary` testSummary) @?= mkSummary "TestTest",
      testCase "Type class HasSummary - modify summary" $
        getSummary (testHasSummary `modifySummary` mapSummary (map toUpper)) @?= mkSummary "TEST"
    ]
