-- | Simple workfile managment application.
-- Features:
--      - List workfiles in working directory
--      - Sort them (status, dead-line, priority)
module Main where

import Data.Time.Calendar
import Worklog.Task

main :: IO ()
main = do
  let task = Task 1 "ÜKK dokumentum ellenőrzése" ForgetIt Open (Deadline (fromGregorian 2026 8 23)) $ mkSummary "Summary"
  print task
  print $ isOpen task
