-- | Simple workfile managment application.
-- Features:
--      - List workfiles in working directory
--      - Sort them (status, dead-line, priority)
module Main where

-- import Data.Time.Calendar
import Worklog.Task

main :: IO ()
main = do
  let task = mkTask 1 "First task"
  print task
  print $ isOpen task
