-- | Simple workfile managment application.
-- Features:
--      - List workfiles in working directory
--      - Sort them (status, dead-line, priority)
module Main where

import           Worklog.Task

main :: IO ()
main = do
    let task = Task 1 "ÜKK dokumentum ellenőrzése" Open
    print task
    print $ isOpen task
