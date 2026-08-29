module Worklog.TaskAnalysis
(
    countByPriority
  , countActiveByPriority
)
where

import           Worklog.Task
import           Data.Map.Strict (Map)
import qualified Data.Map.Strict as M

countByPriority :: [Task] -> Map Priority Int
countByPriority = foldr count M.empty
    where
      count task = M.insertWith (+) (taskPriority task) 1

countActiveByPriority :: [Task] -> Map Priority Int
countActiveByPriority = countByPriority . filter (not . isArchived)
