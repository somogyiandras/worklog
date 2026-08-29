module Worklog.TaskSpec
  ( tests,
  )
where

import Test.Tasty
import Test.Tasty.HUnit
import Worklog.Case
import Data.Time.Calendar (fromGregorian)


tests :: TestTree
tests =
  testGroup
    "Worklog.Task"
    [ initialization
     , testStatus
     , testPriority
    ]

initialization :: TestTree
initialization =
  testGroup
    "Task initialization and setting functions"
    [ testCase "Is caseId zero?" $
        caseId (newCase 0 "Test case") @?= 0,
      testCase "is it open?" $
        caseStatus (newCase 0 "Test case") @?= OnDesk,
      testCase "is it normal priority?" $
        casePriority (newCase 0 "Test case") @?= Normal,
      testCase "has not it deadline?" $
        caseDeadline (newCase 0 "Test case") @?= NoDeadline,
      testCase "has it empty summary?" $
        getSummary (newCase 0 "Test case") @?= emptySummary,
      testCase "Can I close?" $
        caseStatus (closeCase (newCase 0 "Test case")) @?= Archived,
      testCase "Does opening and closing is id?" $
        openCase (closeCase (newCase 0 "Test case")) @?= newCase 0 "Test case"
    ]

testStatus :: TestTree
testStatus =
    let caseClosed = closeCase $ newCase 1 "Archived"
        caseOnDesk = newCase 2 "OnDesk"
        caseDeferred = (newCase 3 "Deferred") { caseStatus = Deferred (fromGregorian 2026 11 10)}
    in
    testGroup "\tStatus functions:"
        [ testCase "isArchived Archived" $
            isArchived caseClosed @?= True

        , testCase "isArchived OnDesk" $
            isArchived caseOnDesk @?= False

        , testCase "isOnDesk OnDesk" $
            isOnDesk caseOnDesk @?= True

        , testCase "isOnDesk Archived" $
            isOnDesk caseClosed @?= False

        , testCase "isOnDesk Reviewed" $
            isOnDesk caseDeferred @?= False
        ]

testPriority :: TestTree
testPriority =
    let caseImportant = promoteCase $ newCase 1 "Important"
        caseOnDesk = newCase 2 "OnDesk"
    in
    testGroup "\tPriority functions:"
        [ testCase "isImportant Normal" $
            isImportant caseOnDesk @?= False

        , testCase "checking compare:" $
            (casePriority caseImportant >= casePriority caseOnDesk) @?= True
        ]
