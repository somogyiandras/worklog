module Main where

import Test.Tasty
import qualified Worklog.ImplementationSpec as I

main :: IO ()
main =
    defaultMain $
        testGroup "Internals"
            [ I.tests
            ]
