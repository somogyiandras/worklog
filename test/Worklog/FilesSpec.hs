module Worklog.FilesSpec
  ( tests
  )
where


import Test.Tasty
import Test.Tasty.HUnit
import Worklog.FileManager
import System.IO.Temp (withSystemTempDirectory)
import Data.List (sort)
import System.FilePath
import System.Directory
import Data.Function ((&))

tests :: TestTree
tests =
  testGroup
    "Worklog.FileManager"
    [ filesTests
    ]

filesTests :: TestTree
filesTests =
  testGroup
    "\tFileManager tests:"
    [ testCase "Empty directory" $
        withSystemTempDirectory "empty-test" $ \dir -> do
          let subdir = dir </> "empty"
          createDirectory subdir

          result <- findWorkFiles defaultFileOptions

          let expected = []

          result @?= expected,

      testCase "finds workfiles recursively" $
        withSystemTempDirectory "workfiles-test" $ \dir -> do

            let subdir = dir </> "sub"

            createDirectory subdir

            writeFile (dir </> "first.wmd") ""
            writeFile (dir </> "ignore.txt") ""
            writeFile (subdir </> "second.wmd") ""
            writeFile (subdir </> "other.md") ""

            result <- findWorkFiles $ FileOptions dir "wmd"

            let expected =
                    [ dir </> "first.wmd"
                    , subdir </> "second.wmd"
                    ]

            sort result @?= sort expected,

        testCase "Find other files" $
          withSystemTempDirectory "others" $ \dir -> do

            writeFile (dir </> "first.wmd") ""
            writeFile (dir </> "ignore.txt") ""

            result <- findWorkFiles $ defaultFileOptions & addDirOpt dir & addExtOpt ".txt"

            let expected =
                    [ dir </> "ignore.txt"
                    ]

            sort result @?= sort expected

    ]


