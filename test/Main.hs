module Main where

import Test.Tasty
import qualified Worklog.CaseSpec as Task

main :: IO ()
main =
    defaultMain $
        testGroup "worklog"
            [ Task.tests
            ]
