{-# LANGUAGE OverloadedStrings #-}
-- | Read the workfile and collect all the information neccessary to create
-- Case.
-- 

module Worklog.Reader
  (

    Doc,
    -- * Workfile readers
    readFromMD,

    -- * Collecting informations from the workfile
    CollectedBlocks(..),

    -- ** - from meta
    extractTitleFromMeta,
    parseMetaForStatus,
    extractKeyWordsFromMeta,

    -- ** - from text
    extractFlagsFromText,

    -- ** from Pandoc AST
    collectFromAst,

    -- * Post-processing collected information
    validateDraft,

    -- * Utility functions
    textifyBlock,
    textifyBlocks,
  )
where

import Worklog.Case
import Worklog.Todo
-- import Worklog.Task
import Worklog.Implementation.Internal

import Text.Pandoc
import Text.Pandoc.Shared (stringify, stringifyInlines)
import Text.Pandoc.UTF8 qualified as U8
import Text.Pandoc.Walk
import Control.Monad.IO.Class (liftIO)
import Text.Parsec
import Data.Text qualified as T
import Data.Text (Text)
-- import Data.Text.IO qualified as TIO
import Data.Time.Calendar
import Data.Set (Set, fromList, empty)
import Data.Either (fromRight)
-- import Data.Set qualified as Set
-- import Data.Maybe (maybe)
-- import Data.Functor (($>))
-- import Control.Arrow (arr, (&&&))

type Doc = (Pandoc, Text)

data ParsingErrors =
    DocumentHasNoTitle
  | ErrorInDeferredDate
  deriving (Eq, Show)

-- From GHC.Utils.Misc, but flipped
filterByList :: [a] -> [Bool] -> [a]
filterByList (x : xs) (True : bs) = x : filterByList xs bs
filterByList (_ : xs) (False : bs) = filterByList xs bs
filterByList _ _ = []

pandocReaderOptions :: ReaderOptions
pandocReaderOptions = def { readerExtensions = pandocExtensions }

-- | Returns the title based on the meta values of the pandoc transformed workfile
-- There is no error if the title is empty
extractTitleFromMeta :: Doc -> Text
extractTitleFromMeta (Pandoc meta _, _) = stringifyInlines $ docTitle meta

-- | Status information is metadata field.
-- key = "closed" value = _ means Archived 'Status' value, the case is closed
-- key = "deferred" value = date in yyyy.mm.dd. format, where the separator
-- can be '.', '/' or '-'. The last separator is optional. Then the case is deferred
-- untill the given date.
-- If there is no key values of the above, then the 'Status' is OnDesk
-- There can be parsing error in the date, then return Left ParsingError
parseMetaForStatus :: Doc -> Either ParsingErrors Status
parseMetaForStatus (Pandoc meta _, _)
  | Just _ <- lookupMeta "closed" meta = Right Archived
  | Just (MetaInlines (dateString:_)) <- lookupMeta "deferred" meta =
    case parse dateParser "" $ stringify dateString of
      Left _ -> Left ErrorInDeferredDate
      Right (year, month, day) -> Right $ Deferred $ fromGregorian year month day
  | otherwise = Right OnDesk
  where
    number :: (Read b, Stream s m Char) => ParsecT s u m b
    number = read <$> many1 digit

    dateParser :: Stream s m Char => ParsecT s u m (Integer, Int, Int)
    dateParser =
      (,,) <$> (number <* oneOf ".-/")
           <*> (number <* oneOf ".-/")
           <*> (number <* optional (oneOf ".-/"))
           <* eof

-- | Flag information is boolean. Flag is true, if the raw text of the workfile
-- contains the corresponding text at least once. There is no error, flags can be empty.
extractFlagsFromText :: Doc -> Set CaseFlag
extractFlagsFromText doc =
  let
    scansResult = map ( $ doc) [scanWaiting, scanManager, scanPending]
    flagsFound = [Waiting, NeedsManager, ApprovalPending] `filterByList` scansResult
  in fromList flagsFound
  where
    scanWaiting (_, text) = "WAIT!" `T.isInfixOf` text
    scanManager (_, text) = "BOSS!" `T.isInfixOf` text
    scanPending (_, text) = "SIGN!" `T.isInfixOf` text

-- | The metadata block can contain a keywords key, with an array value.
-- Theese are the case keywords.
extractKeyWordsFromMeta :: Doc -> [Text]
extractKeyWordsFromMeta (Pandoc meta _, _) =
  maybe
    []
    getKeyWords $
    lookupMeta "keywords" meta
    where
      getKeyWords (MetaList ks) = map stringify ks
      getKeyWords _             = []


-- | The structure holds the collectable items (normally classified Para, Div).
-- To use it as a result in Text.Pandoc.Walk.query it is an instance of Monoid.
data CollectedBlocks = Collected
  { collectedTodos :: [[Block]]
  , collectedTasks :: [[Block]]
  }
  deriving (Show)

instance Semigroup CollectedBlocks where
  (<>) (Collected todos1 tasks1) (Collected todos2 tasks2) = Collected (todos1 <> todos2) (tasks1 <> tasks2)

instance Monoid CollectedBlocks where
  mempty = Collected [] []

-- | 'collectFromAst' walks the pandoc document and collects the blocks, inlines corresponding
-- the required information.
collectFromAst :: Doc -> CollectedBlocks
collectFromAst (Pandoc _ pd, _) = query collectBlocks pd
  where
    collectBlocks :: Block -> CollectedBlocks
    collectBlocks (Div (_, cs, _) bs)
      | "todo" `elem` cs = Collected [bs] []
      | "task" `elem` cs = Collected [] [bs]
      | otherwise = mempty
    collectBlocks _                   = mempty

todoFromPandoc :: [Block] -> Todo
todoFromPandoc blocks =
  let
    urgency = parseUrgency $ textifyBlocks blocks
  in
    newTodo urgency (mkSummary $ T.unpack $ textifyBlocks blocks)

parseUrgency :: Text -> Urgency
parseUrgency blocks =
  case parse (string "Todo!") "" blocks of
    Left _ -> NotSoUrgent
    Right _ -> Urgent


-- | Utility function. stringifyInlines of Block.
textifyBlocks :: [Block] -> Text
textifyBlocks = T.unlines . concatMap textifyBlock

-- | Utility function. stringify of Block.
textifyBlock :: Block -> [Text]
textifyBlock (Para inlines) = [stringifyInlines inlines]
textifyBlock (Plain inlines) = [stringifyInlines inlines]
textifyBlock (CodeBlock _ text) = [text]
textifyBlock (RawBlock _ text) = [text]
{-
 - todo: if requires then handle the other Block constructors
textifyBlock (LineBlock inliness) = [concatMap (stringifyInlines) inliness]
textifyBlock (BlockQuote bl) = map extractBlockText bl
-}
textifyBlock  _ = []

-- | Workfile „markdown reader”.
-- workfile.(w)md -> Pandoc AST
readFromMD :: FilePath -> IO Doc
readFromMD path =
  do
    contents <- U8.readFile path
    case runPure $ readMarkdown pandocReaderOptions contents of
      Left _ -> mempty
      Right doc -> return (doc, contents)


validateDraft :: Doc -> CaseDraft
validateDraft doc =
  let
    draftTitle = T.unpack (extractTitleFromMeta doc)
    draftStatus = case parseMetaForStatus doc of
      Right s -> s
      -- todo: handle errors
      Left _ -> OnDesk
    collected = collectFromAst doc
    draftTodos = map todoFromPandoc (collectedTodos collected)
    draftKeywords = extractKeyWordsFromMeta doc
    draftFlags = extractFlagsFromText doc

  in
    Draft
      draftTitle
      draftStatus
      NoDeadline
      emptySummary
      draftFlags
      draftTodos
      []
      []
      draftKeywords

main :: IO ()
main = do
  doc <- readFromMD "examples/workfile.wmd"
  print $ validateDraft doc

