{-# LANGUAGE OverloadedStrings #-}
module Worklog.ReaderSpec
  ( tests
  )
where

import Worklog.Reader

import Test.Tasty
import Test.Tasty.HUnit
-- import Data.Function ((&))
import Text.Pandoc.Builder
import Data.Text
import Worklog.Case
import Data.Time.Calendar (fromGregorian)
import Data.Validation (Validation(..))

emptyDoc :: Pandoc
emptyDoc = doc mempty

tests :: TestTree
tests =
  testGroup
    "Worklog.Reader"
    [ readerTests
    ]

readerTests :: TestTree
readerTests =
  testGroup
    "\tReader tests:"
    [
      testCase "Read title" $
        let
          pdoc = setTitle "testTitle" emptyDoc
        in
           extractTitleFromMeta (pdoc, "") @?= Success "testTitle",

      testCase "Parse status" $
        let
          pdocArchived = setMeta "closed" empty emptyDoc
          pdocDeferred = setMeta "deferred" (text "2026/08/1") emptyDoc
          pdocOnDesk = deleteMeta "closed" (deleteMeta "deferred" emptyDoc)
        in
           parseMetaForStatus <$>
            Prelude.zip [pdocArchived, pdocDeferred, pdocOnDesk] ["","",""]
            @?=
            Success <$> [Archived, Deferred $ fromGregorian 2026 8 1, OnDesk]
    ]


