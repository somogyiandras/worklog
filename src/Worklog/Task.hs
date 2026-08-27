-- | Task logic
module Worklog.Task
  ( -- * Task and its attributes
    Task,
    taskId, taskTitle, taskPriority, taskStatus, taskDeadline,
    mkTask,

    -- ** Status of task
    Status (..),
    isOpen,
    isFinished,

    -- ** Priority
    Priority (..),
    isImportant,
    needsAttention,
    setTaskPriority,
    promoteTask,
    demoteTask,

    -- ** Deadlines
    Deadline (..),
    hasDeadline,
    setDeadline,

    -- * Functions
    closeTask, openTask,
    mkSummary,
    summaryText,
    emptySummary,
    getSummary, setSummary
  )
where

import Data.Time.Calendar

newtype Summary = Summary String
  deriving (Eq, Show)

data Priority
  = ForgetIt
  | Postpone
  | Normal
  | Important
  | VeryImportant
  deriving (Eq, Ord, Show, Enum, Bounded)

isImportant :: Task -> Bool
isImportant task = taskPriority task >= Important

-- | Not closed and high priority task
needsAttention :: Task -> Bool
needsAttention task = not (isFinished task) && isImportant task

setTaskPriority :: Priority -> Task -> Task
setTaskPriority p task = task {taskPriority = p}

promoteTask :: Task -> Task
promoteTask task
  | taskPriority task == maxBound = task
  | otherwise = task {taskPriority = succ $ taskPriority task}

demoteTask :: Task -> Task
demoteTask task
  | taskPriority task == minBound = task
  | otherwise = task {taskPriority = pred $ taskPriority task}

data Status
  = -- | task is under work
    Open
  | -- | task is reviewed by others, it is ready to
    -- make the decision
    Reviewed
  | -- | task is closed, there is no work with it
    Closed
  deriving (Eq, Show)

isOpen :: Task -> Bool
isOpen task = taskStatus task == Open

-- | Checks for finished task
isFinished :: Task -> Bool
isFinished task = taskStatus task == Closed

closeTask :: Task -> Task
closeTask task = task {taskStatus = Closed}

openTask :: Task -> Task
openTask task = task {taskStatus = Open}

-- | Very important attribute.
data Deadline
  = -- | For tasks without deadline
    NoDeadline
  | -- | Deadline
    Deadline Day
  deriving (Eq, Show)

hasDeadline :: Task -> Bool
hasDeadline task =
  case taskDeadline task of
    NoDeadline -> False
    Deadline _ -> True

setDeadline :: Deadline -> Task -> Task
setDeadline day task = task {taskDeadline = day}

-- | The Task data type contains the parameters of the case
-- correspondent to the workfile. Some title, a longer summary,
-- priority and status, and of course deadline.
--
-- The summary field currently implemented as Pandoc Block.
--
-- The task has an ID.
data Task = Task
  { taskId :: Int,
    taskTitle :: String,
    taskPriority :: Priority,
    taskStatus :: Status,
    taskDeadline :: Deadline,
    taskSummary :: Summary
  }
  deriving (Eq, Show)

-- | mkTask id title creates an open task with normal priority,
-- no deadline and empty summary.
mkTask :: Int -> String -> Task
mkTask iD title = Task
  { taskId = iD,
    taskTitle = title,
    taskPriority = Normal,
    taskStatus = Open,
    taskDeadline = NoDeadline,
    taskSummary = emptySummary
  }


mkSummary :: String -> Summary
mkSummary = Summary

summaryText :: Summary -> String
summaryText (Summary s) = s

emptySummary :: Summary
emptySummary = mkSummary ""

setSummary :: Summary -> Task -> Task
setSummary s task = task {taskSummary = s}

getSummary :: Task -> Summary
getSummary task = taskSummary task
