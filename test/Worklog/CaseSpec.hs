module Worklog.CaseSpec
  ( tests,
  )
where

import Worklog.Implementation.Internal
import Worklog.Case
import Worklog.Todo
import Worklog.Task

import Test.Tasty
import Test.Tasty.HUnit
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
      testFlag,
      testDays,
      testTodos,
      testTasks
    ]

initialization :: TestTree
initialization =
  testGroup
    "\tCase initialization tests:"
    [       testCase "is it open?" $
        isOnDesk (newCase "Test case") @?= True,
      testCase "has not it deadline?" $
        caseDeadline (newCase "Test case") @?= NoDeadline,
      testCase "has it empty summary?" $
        getSummary (newCase "Test case") @?= emptySummary
    ]

testOpenClose :: TestTree
testOpenClose =
  testGroup
    "\n\tTest open and close:"
    [ testCase "Try to close a new case" $
      isRight (closeCase $ newCase "Archived") @?= True,
      testCase "Is open . close = id?" $
      openCase
        ( case closeCase $ newCase "Test" of
            Right closed -> closed 
            Left warning -> newCase warning)
        == newCase "Test" @?= True
    ]

testStatus :: TestTree
testStatus =
    let (Right caseClosed) = closeCase $ newCase "Archived"
        caseOnDesk = newCase "OnDesk"
        caseDeferred = deferrCase (newCase "Deferred") (fromGregorian 2026 11 10)
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

testFlag :: TestTree
testFlag =
    let caseDoubleFlag =
          newCase "Outgoing is under approval but boss has to decide" &
          addFlag NeedsManager &
          addFlag ApprovalPending
        caseDoubleWaiting = 
          newCase "Add Waiting two times" &
          addFlag Waiting &
          addFlag Waiting
    in
    testGroup "\n\tFlag functions:"
        [ testCase "Has new case any flag?" $
            anyFlag (newCase "") @?= False,
          testCase "Add one..." $
            anyFlag (newCase "" & addFlag Waiting) @?= True,
          testCase "New case does not wait" $
            hasFlag Waiting (newCase "") @?= False,
          testCase "But this waits" $
            hasFlag Waiting (addFlag Waiting $ newCase "") @?= True,
          testCase "Two flag present" $
            hasFlag NeedsManager caseDoubleFlag && hasFlag ApprovalPending caseDoubleFlag @?= True,
          testCase "Is flag unique?" $
            (caseDoubleWaiting & removeFlag Waiting & hasFlag Waiting) @?= False
        ]

testDays :: TestTree
testDays =
    let caseDeferred = newCase "Case deffered until 2027-12-31" & deferrCase $ fromGregorian 2027 12 31
    in
    testGroup "\n\tDate related functions:"
        [ testCase "Case deferred?" $
            isDeferred caseDeferred @?= True,
          testCase "Deferred until 2027-12-31?" $
            getDefferedDay caseDeferred == Just (fromGregorian 2027 12 31) @?= True
        ]

testTodos :: TestTree
testTodos =
    let caseTodos = newCase "Has no todos"
        todo = newTodo NotSoUrgent  $ mkSummary "Todo"
    in
    testGroup "\n\tTodo related functions"
        [ testCase "New case has no todos" $
            null (listCaseTodos caseTodos) @?= True,
          testCase "Add a todo" $
            not (null (listCaseTodos (caseTodos & addTodo todo) )) @?= True
        ]

testTasks :: TestTree
testTasks =
    let caseTasks = newCase "Has no todos"
        todo = mkTask $ mkSummary "Task"
    in
    testGroup "\n\tTask related functions"
        [ testCase "New case has no todos" $
            null (listCaseTasks caseTasks) @?= True,
          testCase "Add a todo" $
            not (null (listCaseTasks (caseTasks & addTask todo) )) @?= True
        ]
