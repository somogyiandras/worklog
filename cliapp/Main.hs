-- | Command-line entry point for discovering workfiles and displaying
-- their parsed titles.
module Main where

-- import Data.Time.Calendar
import Worklog.FileManager
import Worklog.Case
import Worklog.Reader
import Options.Applicative
import Data.Text qualified as T

main :: IO ()
main = do
  let cas = newCase "First case"
  print cas
  print $ isOnDesk cas

  options <- execParser opts
  files <- findWorkFiles options
  docs <- traverse readFromMD files
  let
    titles = map (either (const "No title!") id . getTitleFromDoc) docs 
    statuses = map (either (const "No Status") show . getStatusFromDoc) docs 
  mapM_ putStrLn titles
  mapM_ putStrLn statuses

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
