{-# LANGUAGE OverloadedStrings #-}
-- | Read the workfile and collect all the information neccessary to create
-- Case.
-- 

module Worklog.Reader
  (

    Doc,
    -- * Workfile readers
    readFromMD,
    ReaderError,

    -- * Collecting informations from the workfile
    CollectedBlocks(..),

    -- ** from meta
    extractTitleFromMeta,
    parseMetaForStatus,
    extractKeyWordsFromMeta,

    -- ** from text
    extractFlagsFromText,

    -- ** from Pandoc AST
    collectFromAst,

    -- * Post-processing collected information
    validateDraft,

    -- * Utility functions
    textifyBlock,
    textifyBlocks,

    -- Interface to FileManager
    WorkfileResult,
    readWorkFile,
    readWorkFiles
  )
where

import Worklog.Case
import Worklog.Todo
import Worklog.Task
import Worklog.Implementation.Internal

import Text.Pandoc
import Text.Pandoc.Shared (stringify, stringifyInlines)
import Text.Pandoc.UTF8 qualified as U8
import Text.Pandoc.Walk
import Text.Parsec
import Data.Text qualified as T
import Data.Text (Text)
-- import Data.Text.IO qualified as TIO
import Data.Time.Calendar (fromGregorianValid, Day)
import Data.Set (Set, fromList)
-- import Data.Set qualified as Set
-- import Data.Maybe (maybe)
-- import Data.Functor (($>))
import Control.Monad (when)
import Data.Either (fromRight)
import Data.Validation (Validation(..))

type Doc = (Pandoc, Text)


-- From GHC.Utils.Misc, but flipped
filterByList :: [a] -> [Bool] -> [a]
filterByList (x : xs) (True : bs) = x : filterByList xs bs
filterByList (_ : xs) (False : bs) = filterByList xs bs
filterByList _ _ = []

pandocReaderOptions :: ReaderOptions
pandocReaderOptions = def { readerExtensions = pandocExtensions }

-- | Returns the title based on the meta values of the pandoc transformed workfile
-- There is no error if the title is empty
extractTitleFromMeta :: Doc -> Validation [ReaderError] String
extractTitleFromMeta (Pandoc meta _, _) =
  let
    title = T.unpack $ stringifyInlines $ docTitle meta
  in
    if title == ""
      then Failure [DocumentHasNoTitle]
      else Success title

-- | Status information is a metadata field.
-- If there is no "closed" or "deferred" key in metadata, then the 'Status' is 'OnCase'.
-- If there is "closed" key, then  the 'Status' value is 'Archived'. The key value has no meaning.
-- If there is "deferred" key, then  the 'Status' value is 'Deferred <date>'
-- where <date> is parsed from the key value.
-- Acceptable formats: "yyyy.mm.dd.", "yyyy/mm/dd" "yyyy-mm-dd"
-- There cannot be any text after the date. Please use yaml comments!
parseMetaForStatus :: Doc -> Validation [ReaderError] Status
parseMetaForStatus (Pandoc meta _, _)
  | Just _ <- lookupMeta "closed" meta = Success Archived
  | Just metaValue <- lookupMeta "deferred" meta =
    case metaValue of
      MetaInlines [deferredVal] -> 
        case parse dateParser "" $ stringify deferredVal of
          Left _ -> Failure [ErrorInDeferredDate]
          Right validday -> Success $ Deferred validday
      _ -> Failure [MetaValueError]
  | otherwise = Success OnDesk

number :: (Read b, Stream s m Char) => ParsecT s u m b
number = read <$> many1 digit

dateParser :: Stream s m Char => ParsecT s u m Day
dateParser =
  do
    year <- number
    sep <- oneOf ".-/"
    month <- number
    _ <- char sep
    day <- number
    when (sep == '.') $ optional (char '.')
    eof

    case fromGregorianValid year month day of
      Nothing -> fail "Invalid calendar date"
      Just validday -> pure validday

parseDeadLine :: Doc -> Validation [ReaderError] (Maybe Deadline)
parseDeadLine doc =
  let
    (_, spans) = collectFromAst doc
  in
    case collectedDeadline spans of
      [] -> Success Nothing
      [inl] -> case parse dateParser "" $ stringify inl of
        Left _ -> Failure [ErrorInDeadLine]
        Right day -> Success $ Just $ Deadline day
      _ -> Failure [MoreDeadlines]

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
data CollectedBlocks = CollectedBlocks
  { collectedTodos :: [[Block]]
  , collectedTasks :: [[Block]]
  , collectedSummary :: [[Block]]
  }
  deriving (Show)

data CollectedSpans = CollectedSpans
  { collectedDeadline :: [[Inline]]
  }
  deriving (Show)

instance Semigroup CollectedBlocks where
  (<>) (CollectedBlocks todos1 tasks1 sum1) (CollectedBlocks todos2 tasks2 sum2) = CollectedBlocks (todos1 <> todos2) (tasks1 <> tasks2) (sum1 <> sum2)

instance Monoid CollectedBlocks where
  mempty = CollectedBlocks [] [] []

instance Semigroup CollectedSpans where
  (<>) (CollectedSpans dl1) (CollectedSpans dl2) = CollectedSpans (dl1 <> dl2)

instance Monoid CollectedSpans where
  mempty = CollectedSpans []

-- | 'collectFromAst' walks the pandoc document and collects the blocks, inlines corresponding
-- the required information.
collectFromAst :: Doc -> (CollectedBlocks, CollectedSpans)
collectFromAst (Pandoc _ pd, _) =
  (query collectBlocks pd, query collectSpans pd)
  where
    collectBlocks :: Block -> CollectedBlocks
    collectBlocks (Div (_, cs, _) bs)
      | "todo" `elem` cs = CollectedBlocks [bs] [] []
      | "task" `elem` cs = CollectedBlocks [] [bs] []
      -- todo: there can be only one summary div
      | "summary" `elem` cs = CollectedBlocks [] [] [bs]
      | otherwise = mempty
    collectBlocks _                   = mempty

    collectSpans :: Inline -> CollectedSpans
    collectSpans (Span (_, cs, _) inl)
      -- deadline must be unique
      | "deadline" `elem` cs = CollectedSpans [inl]
      | otherwise = mempty
    collectSpans _ = mempty

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

taskFromPandoc :: [Block] -> Task
taskFromPandoc = newTask . mkSummary . T.unpack . textifyBlocks

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

data ReaderError
  = FileReadError String
  | MarkdownParseError PandocError
  | MetaValueError
  | ErrorInDeferredDate
  | ErrorInDeadLine
  | DocumentHasNoTitle
  | MoreSummaryBlocks
  | MoreDeadlines
  deriving (Show)

-- | Workfile „markdown reader”.
-- workfile.(w)md -> Pandoc AST
readFromMD :: FilePath -> IO (Either ReaderError Doc)
readFromMD path =
  do
    contents <- U8.readFile path
    result <- runIO $ readMarkdown pandocReaderOptions contents
    return $
      case result  of
        Left err -> Left $ MarkdownParseError err
        Right doc -> Right (doc, contents)

validateDraft :: Doc -> Validation [ReaderError] CaseDraft
validateDraft doc =
  let
    draftTitle = extractTitleFromMeta doc
    draftStatus = parseMetaForStatus doc
    (collectedBlocks, _) = collectFromAst doc
    draftTodos = map todoFromPandoc (collectedTodos collectedBlocks)
    draftTasks = map taskFromPandoc (collectedTodos collectedBlocks)
    
    draftSummary =
      case collectedSummary collectedBlocks of
        [] -> Success emptySummary
        [summary] -> Success $ mkSummary $ T.unpack $ textifyBlocks summary
        _ -> Failure [MoreSummaryBlocks]

    draftDeadline = parseDeadLine doc
    draftKeywords = extractKeyWordsFromMeta doc
    draftFlags = extractFlagsFromText doc

  in
    Draft
    <$> draftTitle
    <*> draftStatus
    <*> draftDeadline
    <*>  draftSummary
    <*>  pure draftFlags
    <*>  pure draftTodos
    <*>  pure draftTasks
    <*>  pure []
    <*>  pure draftKeywords

type WorkfileResult = (FilePath, Validation [ReaderError] Case)

readWorkFile :: FilePath -> IO WorkfileResult
readWorkFile path =
  do
    pandocProcess <- readFromMD path 
    case pandocProcess of
      Left pandocFailed -> pure (path, Failure [pandocFailed])
      Right doc -> 
        case validateDraft doc of
          Success draft -> pure (path, Success $ fromRight (newCase "ERROR!") (makeCase draft))
          Failure errors -> pure (path, Failure errors)

readWorkFiles :: [FilePath] -> IO [WorkfileResult]
readWorkFiles = traverse readWorkFile

{-
main :: IO ()
main = do
  doc <- readFromMD "examples/workfile.wmd"
  print $ validateDraft doc
-}
