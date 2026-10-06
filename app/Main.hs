-- | Simple workfile managment application.
-- Features:
--      - List workfiles in working directory
--      - Sort them (status, dead-line, priority)
module Main where

-- import Data.Time.Calendar
import Worklog.FileManager
import Worklog.Case
import Options.Applicative
import System.Directory (makeRelativeToCurrentDirectory)

main :: IO ()
main = do
  let cas = newCase "First case"
  print cas
  print $ isOnDesk cas
  options <- execParser opts
  files <- findWorkFiles options
  files' <- traverse makeRelativeToCurrentDirectory files
  mapM_ putStrLn files'

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
