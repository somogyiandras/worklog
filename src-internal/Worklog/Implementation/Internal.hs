module Worklog.Implementation.Internal
(
  HasSummary(..),
  Summary,
  mkSummary,
  summaryText,
  emptySummary,
  mapSummary
)
where

class HasSummary a where
  getSummary :: a -> Summary
  setSummary :: a-> Summary -> a
  modifySummary :: (Summary -> Summary) -> a -> a
  modifySummary f a = setSummary a (f $ getSummary a)
  {-# MINIMAL setSummary, getSummary #-}

-- todo: Summary must be Monoid

newtype Summary = Summary String
  deriving (Eq, Show)

mkSummary :: String -> Summary
mkSummary = Summary

summaryText :: Summary -> String
summaryText (Summary s) = s

emptySummary :: Summary
emptySummary = mkSummary ""

mapSummary :: (String -> String) -> Summary -> Summary
mapSummary f (Summary s) = Summary (f s)
