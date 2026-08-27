-- | Task logic
module Worklog.Task
  ( -- * Types
    Status (..),
    Priority (..),
    Deadline (..),
    Task (..),

    -- * Functions
    initTask,
    isOpen,
    isFinished,
    hasDeadline,
    isImportant,
    needsAttention,
    closeTask, openTask,
    mkSummary,
    summaryText,
    emptySummary,
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
  deriving (Eq, Ord, Show)

data Status
  = -- | task is under work
    Open
  | -- | task is reviewed by others, it is ready to
    -- make the decision
    Reviewed
  | -- | task is closed, there is no work with it
    Closed
  deriving (Eq, Show)

-- | Very important attribute.
data Deadline
  = -- | For tasks without deadline
    NoDeadline
  | -- | Deadline
    Deadline Day
  deriving (Eq, Show)

data Task = Task
  { taskId :: Int,
    taskTitle :: String,
    taskPriority :: Priority,
    taskStatus :: Status,
    taskDeadline :: Deadline,
    taskSummary :: Summary
  }
  deriving (Eq, Show)

initTask :: Task
initTask = Task 0 "TaskTitle" Normal Open NoDeadline emptySummary

isOpen :: Task -> Bool
isOpen task = taskStatus task == Open

-- | Checks for finished task
isFinished :: Task -> Bool
isFinished task = taskStatus task == Closed

closeTask :: Task -> Task
closeTask (Task i t p _ d s) = Task i t p Closed d s

openTask :: Task -> Task
openTask (Task i t p _ d s) = Task i t p Open d s


hasDeadline :: Task -> Bool
hasDeadline task =
  case taskDeadline task of
    NoDeadline -> False
    Deadline _ -> True

isImportant :: Task -> Bool
isImportant task = taskPriority task >= Important

-- | Not closed and high priority task
needsAttention :: Task -> Bool
needsAttention task = not (isFinished task) && isImportant task

mkSummary :: String -> Summary
mkSummary = Summary

summaryText :: Summary -> String
summaryText (Summary s) = s

emptySummary :: Summary
emptySummary = mkSummary ""
