module Worklog.Implementation.Internal
(
  Summary,
  mkSummary,
  summaryText,
  emptySummary
)
where

newtype Summary = Summary String
  deriving (Eq, Show)

mkSummary :: String -> Summary
mkSummary = Summary

summaryText :: Summary -> String
summaryText (Summary s) = s

emptySummary :: Summary
emptySummary = mkSummary ""
