module Main (main) where

import Worklog.Task

main :: IO ()
main =
    if isFinished $ Task 1 "Teszt" Normal Closed NoDeadline
        then putStrLn "OK"
        else error "isFinished test failed"
