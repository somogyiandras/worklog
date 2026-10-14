-- | Defines tasks associated with cases but distinct from immediate
-- case-specific to-do items. A task may represent a review, support a
-- decision, initiate another case, or be deferred for later attention.
-- Tasks may remain associated with a case after it has been archived.
module Worklog.Task
(
  Task(..),
  newTask,
)
where

import Worklog.Implementation.Internal

import Data.Time.Calendar

data TaskStatus = Active | Inactive | Deferred Day
    deriving (Eq, Show)

data Task = Task
  {
    taskStatus :: TaskStatus,
    taskSummary :: Summary
  }
  deriving (Eq, Show)

instance HasSummary Task where
  getSummary = taskSummary
  setSummary task s = task {taskSummary = s}

-- ToDo: change to Maybe Task. Cannot create Task
-- with emptySummary
newTask :: Summary -> Task
newTask = Task Active


