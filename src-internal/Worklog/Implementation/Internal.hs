-- | Shared internal abstractions used by the Worklog domain modules.
--
module Worklog.Implementation.Internal
( 
  -- * Summary type
  Summary,
  mkSummary,
  summaryText,
  emptySummary,
  mapSummary,
  -- * HasSummary type class
  HasSummary(..)
)
where

-- | The HasSummary is the type class of the types which want to use
-- the Summary type. Because the Summary must be hidden to them, there
-- must be the class methods to read, set and modify the parameter.
class HasSummary a where
  getSummary :: a -> Summary
  setSummary :: a-> Summary -> a
  modifySummary :: a -> (Summary -> Summary) -> a
  modifySummary a f = a `setSummary` f (getSummary a)
  appendSummary :: a -> Summary -> a
  appendSummary a s = a `setSummary` (getSummary a <> s) 
  {-# MINIMAL setSummary, getSummary #-}

-- | Shared summary text whose implementation is hidden from callers.
-- Parser and renderer modules use these operations without depending
-- on the representation.
--
-- The current implementation uses 'String'. Future versions may use
-- 'Text' or Pandoc blocks.
newtype Summary = Summary String
  deriving (Eq, Show, Semigroup, Monoid)

mkSummary :: String -> Summary
mkSummary = Summary

summaryText :: Summary -> String
summaryText (Summary s) = s

emptySummary :: Summary
emptySummary = mempty

mapSummary :: (String -> String) -> Summary -> Summary
mapSummary f (Summary s) = Summary (f s)
