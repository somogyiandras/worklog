-- | Command-line entry point for discovering workfiles and displaying
-- their parsed titles.
module Main where

-- import Data.Time.Calendar
import Worklog.FileManager
import Worklog.Case
import Worklog.Reader
import Options.Applicative
import Data.Text qualified as T
import Data.Either

main :: IO ()
main = do

  options <- execParser opts
  paths <- findWorkFiles options
  results <- readWorkFiles paths

  print results


fileOptions :: Parser FileOptions
fileOptions =
  FileOptions
  <$> strOption
    (  long "dir"
    <> metavar "DIRECTORY"
    <> value "."
    <> help "Starting directory for workfile search" )
  <*> (stripExtensionDot <$> strOption
    (  long "ext"
    <> short 'e'
    <> value "wmd"
    <> metavar "EXT"
    <> help "Workfile extension" ))

opts :: ParserInfo FileOptions
opts = info (fileOptions <**> helper)
  ( fullDesc
  <> progDesc "Working with workfiles: list, report."
  <> header "Worklog - a CLI application for working with custom workfiles" )
