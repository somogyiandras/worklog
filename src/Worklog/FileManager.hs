-- | The file handling utilities of the Worklog.
-- This module will find, list, maybe change
-- the workfiles.
module Worklog.FileManager
  (
    listDirsRecursively,
    findWorkFiles,
    checkExtension,
    checkName,
    (.?), (??),
    FileOptions(..),
    defaultFileOptions,
    addDirOpt,
    addExtOpt,
    stripExtensionDot
  )
where

import System.Directory
import System.FilePath
import Control.Monad (filterM)

-- ToDo: [FilePath] and [[String]
data FileOptions = FileOptions
  {
    workingDirectory :: FilePath,
    workingFileExtension :: String
  }

defaultFileOptions :: FileOptions
defaultFileOptions =  FileOptions "." "wmd"

addDirOpt :: FilePath -> FileOptions -> FileOptions
addDirOpt dir opt = opt {workingDirectory = dir}

addExtOpt :: String -> FileOptions -> FileOptions
addExtOpt ext opt = opt {workingFileExtension = stripExtensionDot ext}

stripExtensionDot :: String -> String
stripExtensionDot ('.':ext) = ext
stripExtensionDot ext = ext



checkExtension :: FilePath -> String -> Bool
checkExtension path ext = ext == takeExtension path

(.?) :: FilePath -> String -> Bool
(.?) = checkExtension

checkName :: FilePath -> String -> Bool
checkName = (==)

(??) :: FilePath -> String -> Bool
(??) = checkName

-- ToDo: exlude filter
findWorkFiles :: FileOptions -> IO [FilePath]
findWorkFiles fileopt =
  do
    start <- absDirList $ workingDirectory fileopt
    go start []
  where
    go :: [FilePath] -> [FilePath] -> IO [FilePath]
    go [] acc = return acc
    go (path : paths) acc = do
      isDir <- doesDirectoryExist path
      isFile <- doesFileExist path
      if isDir
        then do
          downDirs <- absListDirs path
          downFiles <- absListFiles path
          go (downDirs ++ downFiles ++ paths) acc
        else
          if isFile && (path .? ('.':(workingFileExtension fileopt)))
            then
              let acc' = path : acc
               in go paths acc'
            else
              go paths acc


listDirsRecursively :: FilePath -> IO [FilePath]
listDirsRecursively dir =
  do
    wd <- absListDirs dir
    go wd where
      go :: [FilePath] -> IO [FilePath]
      go [] = return []
      go (path:paths) = do
        isDir <- doesDirectoryExist path
        if isDir
          then do 
            down <- absListDirs path
            paths' <- go down
            paths'' <- go paths
            return (path : paths' ++ paths'')
          else go paths



absListDirs :: FilePath -> IO [FilePath]
absListDirs wd = do
  awd <- makeAbsolute wd
  pathList <- listDirectory awd
  filterM doesDirectoryExist (map (awd </>) pathList)

absListFiles :: FilePath -> IO [FilePath]
absListFiles wd = do
  awd <- makeAbsolute wd
  pathList <- listDirectory awd
  filterM doesFileExist (map (awd </>) pathList)

absDirList :: FilePath -> IO [FilePath]
absDirList wd = do
  dirs <- absListDirs wd
  files <- absListFiles wd
  return $ dirs ++ files
