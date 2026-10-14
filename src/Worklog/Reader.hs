module Worklog.Reader
  (
    getTitle,
    getDoc
  )
where

import Worklog.Case
import Text.Pandoc
import Text.Pandoc.Shared (stringifyInlines)
import Control.Monad.IO.Class
import Data.Text qualified as T
import Data.Text.IO qualified as TIO

pandocOptions :: ReaderOptions
pandocOptions = def { readerExtensions = pandocExtensions }


getTitle :: Pandoc -> Maybe String
getTitle (Pandoc meta _) =
  case  docTitle meta of
    []  -> Nothing
    inlines -> Just $ T.unpack $ stringifyInlines inlines

getDoc :: FilePath -> IO Pandoc
getDoc path =
  do
    contents <- readFile path
    case runPure $ readMarkdown pandocOptions (T.pack contents) of
      Left _ -> mempty
      Right doc -> return doc

{-
main :: IO ()
main = do
  result <- runIO $ do
    t <- liftIO $ readFile "examples/workfile.wmd"
    doc <- readMarkdown pandocOptions (T.pack t)
    writeNative def doc
  rst <- handleError result
  TIO.putStrLn rst
-}
