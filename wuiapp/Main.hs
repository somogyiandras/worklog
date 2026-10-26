-- | Command-line entry point for discovering workfiles and displaying
-- their parsed titles.
module Main where

-- import Data.Time.Calendar
import Worklog.FileManager
import Worklog.Case
import Data.Maybe (fromMaybe)
import Data.Text qualified as T

main :: IO ()
main = do
  let cas = newCase "First case"
  print cas
  print $ isOnDesk cas


