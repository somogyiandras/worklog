module Main where

import Test.Tasty
import qualified Worklog.CaseSpec as Case
import qualified Worklog.TodoSpec as Todo

main :: IO ()
main =
    defaultMain $
        testGroup "worklog"
            [ Case.tests,
              Todo.tests
            ]
