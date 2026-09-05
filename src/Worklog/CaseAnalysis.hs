module Worklog.CaseAnalysis
(
    onDesk,
    inDeferred
--    countByPriority
--  , countActiveByPriority
)
where

import           Worklog.Case
--import           Data.Map.Strict (Map)
--import qualified Data.Map.Strict as M

{-
countByPriority :: [Case] -> Map Priority Int
countByPriority = foldr count M.empty
    where
      count cas = M.insertWith (+) (casePriority cas) 1

countActiveByPriority :: [Case] -> Map Priority Int
countActiveByPriority = countByPriority . filter (not . isArchived)
-}

onDesk :: [Case] -> [Case]
onDesk = filter  isOnDesk

inDeferred :: [Case] -> [Case]
inDeferred = filter isDeferred
