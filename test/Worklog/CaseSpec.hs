module Worklog.CaseSpec
  ( tests,
  )
where

import Worklog.Implementation.Internal

import Test.Tasty
import Test.Tasty.HUnit
import Worklog.Case
import Data.Time.Calendar (fromGregorian)
import Data.Function ((&))
import Data.Either (isRight)


tests :: TestTree
tests =
  testGroup
    "Worklog.Case"
    [ initialization,
      testOpenClose,
      testStatus,
      testPriority,
      testFlag,
      testDays
    ]

initialization :: TestTree
initialization =
  testGroup
    "\tCase initialization tests:"
    [ testCase "Is caseId zero?" $
        caseId (newCase 0 "Test case") @?= 0,
      testCase "is it open?" $
        isOnDesk (newCase 0 "Test case") @?= True,
      testCase "is it normal priority?" $
        casePriority (newCase 0 "Test case") @?= Normal,
      testCase "has not it deadline?" $
        caseDeadline (newCase 0 "Test case") @?= NoDeadline,
      testCase "has it empty summary?" $
        getSummary (newCase 0 "Test case") @?= emptySummary
    ]

testOpenClose :: TestTree
testOpenClose =
  testGroup
    "\n\tTest open and close:"
    [ testCase "Try to close a new case" $
      isRight (closeCase $ newCase 1 "Archived") @?= True,
      testCase "Is open . close = id?" $
      openCase
        ( case closeCase $ newCase 1 "Test" of
            Right closed -> closed 
            Left warning -> newCase 2 warning)
        == newCase 1 "Test" @?= True
    ]

testStatus :: TestTree
testStatus =
    let (Right caseClosed) = closeCase $ newCase 1 "Archived"
        caseOnDesk = newCase 2 "OnDesk"
        caseDeferred = deferrCase (newCase 3 "Deferred") (fromGregorian 2026 11 10)
    in
    testGroup "\n\tStatus functions:"
        [ testCase "isArchived Archived" $
            isArchived caseClosed @?= True

        , testCase "not isArchived OnDesk" $
            isArchived caseOnDesk @?= False

        , testCase "isOnDesk OnDesk" $
            isOnDesk caseOnDesk @?= True

        , testCase "not isOnDesk Archived" $
            isOnDesk caseClosed @?= False

        , testCase "not isOnDesk Deferred" $
            isOnDesk caseDeferred @?= False
        ]

testPriority :: TestTree
testPriority =
  let caseImportant = promoteCase $ newCase 1 "Important"
      caseOnDesk = newCase 2 "OnDesk"
   in testGroup
        "\n\tPriority functions:"
        [ testCase "isImportant Normal" $
            isImportant caseOnDesk @?= False,
          testCase "checking compare:" $
            (casePriority caseImportant >= casePriority caseOnDesk) @?= True
        ]

testFlag :: TestTree
testFlag =
    let caseDoubleFlag =
          newCase 1 "Outgoing is under approval but boss has to decide" &
          addFlag NeedsManager &
          addFlag ApprovalPending
        caseDoubleWaiting = 
          newCase 2 "Add Waiting two times" &
          addFlag Waiting &
          addFlag Waiting
    in
    testGroup "\n\tFlag functions:"
        [ testCase "Has new case any flag?" $
            anyFlag (newCase 3 "") @?= False,
          testCase "Add one..." $
            anyFlag (newCase 3 "" & addFlag Waiting) @?= True,
          testCase "New case does not wait" $
            hasFlag Waiting (newCase 2 "") @?= False,
          testCase "But this waits" $
            hasFlag Waiting (addFlag Waiting $ newCase 3 "") @?= True,
          testCase "Two flag present" $
            hasFlag NeedsManager caseDoubleFlag && hasFlag ApprovalPending caseDoubleFlag @?= True,
          testCase "Is flag unique?" $
            (caseDoubleWaiting & removeFlag Waiting & hasFlag Waiting) @?= False
        ]

testDays :: TestTree
testDays =
    let caseDeferred = newCase 1 "Case deffered until 2027-12-31" & deferrCase $ fromGregorian 2027 12 31
    in
    testGroup "\n\tDate related functions:"
        [ testCase "Case deferred?" $
            isDeferred caseDeferred @?= True,
          testCase "Deferred until 2027-12-31?" $
            getDefferedDay caseDeferred == Just (fromGregorian 2027 12 31) @?= True
        ]
