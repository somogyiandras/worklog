-- | Simple workfile managment application.
-- Features:
--      - List workfiles in working directory
--      - Sort them (status, dead-line, priority)
module Main where

-- import Data.Time.Calendar
import Worklog.Case

main :: IO ()
main = do
  let cas = newCase 1 "First case"
  print cas
  print $ isOnDesk cas
