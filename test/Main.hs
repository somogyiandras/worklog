module Main where

import Test.Tasty
import qualified Worklog.CaseSpec as Case
import qualified Worklog.TodoSpec as Todo
import qualified Worklog.TaskSpec as Task

main :: IO ()
main =
    defaultMain $
        testGroup "worklog"
            [ Case.tests,
              Todo.tests,
              Task.tests
            ]
