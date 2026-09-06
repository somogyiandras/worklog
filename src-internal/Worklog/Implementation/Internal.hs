-- | The internal implementations
-- This modul exports the types and functions to handle the
-- hidden implementations.
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

-- | The Summary type is used by more types in the application.
-- It is a placeholder of a longer text attribute of the types.
-- Its internal implementation is hidden from the types. Generally
-- the parser and the renderer types need the functions to handle
-- the Summary values.
--
-- Currently the internal representation is String.
-- Todo: Use Text or Pandoc [Block]
-- Todo: This module can contain some usefull functions
-- to work with Summary in a modul which cannot use the
-- internal representation.
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
