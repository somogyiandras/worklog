-- | Task logic
module Worklog.Task
  ( -- * Task and its attributes
    Task,
    taskId, taskTitle, taskPriority, taskStatus, taskDeadline,
    mkTask,

    -- ** Status of task
    Status (..),
    isOnDesk,
    isArchived,

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

    -- ** Flags
    TaskFlag (..),
    hasFlag, addFlag, removeFlag,

    -- * Functions
    closeTask, openTask,
    mkSummary,
    summaryText,
    emptySummary,
    getSummary, setSummary
  )
where

import Data.Time.Calendar
import Data.Set (Set)
import qualified Data.Set as Set

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
needsAttention task = not (isArchived task) && isImportant task

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
  = -- | task is on the desk, we work on it
    OnDesk
  | -- | task is in the cabinet, waiting for the deadline to come back on desk
    Deferred Day
  | -- | task is closed, it is in the archives, hoppefully never comes back
    Archived
  deriving (Eq, Show)

isOnDesk :: Task -> Bool
isOnDesk task = taskStatus task == OnDesk

-- | Checks for finished task
isArchived :: Task -> Bool
isArchived task = taskStatus task == Archived

-- Close the task, file, document, and send it to the archives
closeTask :: Task -> Task
closeTask task = task {taskStatus = Archived}

-- Put the task on the desk, open it and start working on it.
openTask :: Task -> Task
openTask task = task {taskStatus = OnDesk}

-- | the deadline of the task
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

-- | Flags are attributes of the task.
data TaskFlag
    = Waiting
    -- ^ The task is waiting for someone, something.
    -- Work cannot continue, until it has not arrived.
    | NeedsManager
    -- ^ The task needs decision from the boss.
    | ApprovalPending
    -- There is at least one outgoing document under approval.
    -- Sometimes it needs attention, whether it has finished, or
    -- fixes are neccessary
    deriving (Eq, Ord, Show)

hasFlag :: TaskFlag -> Task -> Bool
hasFlag flag = Set.member flag . taskFlags

addFlag :: TaskFlag -> Task -> Task
addFlag flag task = task {taskFlags = Set.insert flag (taskFlags task)}

removeFlag :: TaskFlag -> Task -> Task
removeFlag flag task = task {taskFlags = Set.delete flag (taskFlags task)}



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
    taskSummary :: Summary,
    taskFlags :: Set TaskFlag
  }
  deriving (Eq, Show)

-- | mkTask id title creates an open task with normal priority,
-- no deadline and empty summary.
mkTask :: Int -> String -> Task
mkTask iD title = Task
  { taskId = iD,
    taskTitle = title,
    taskPriority = Normal,
    taskStatus = OnDesk,
    taskDeadline = NoDeadline,
    taskSummary = emptySummary,
    taskFlags = Set.empty
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
getSummary = taskSummary 
