module Main where

import Test.Tasty
import qualified Worklog.TaskSpec as Task

main :: IO ()
main =
    defaultMain $
        testGroup "worklog"
            [ Task.tests
            ]
