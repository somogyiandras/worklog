-- | The Task type introduce a task which is not part of the case.
-- It is connected,  for example the review of the case assigned a task.
-- The task can initiate a new case, or it can assist a decision-makig
-- process in another case. Or it can be a deferred task, something
-- which needs attention in the future.
--
-- The case can be archived, the task remains in the case.
-- The task will be „closed”, if it does not require acticity from .
-- The closeing condition and time is recorded in the Task.
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


