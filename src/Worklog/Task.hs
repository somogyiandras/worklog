-- | Task logic
module Worklog.Task
(
    -- * Types
    Status (..),
    Priority (..),
    Deadline (..),
    Task,
    taskId, taskTitle, taskPriority, taskStatus, taskDeadline,
    mkSummary, summaryText, setSummary,
    -- * Functions
    isOpen,
    isFinished,
    hasDeadline,
    isImportant,
    needsAttention
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
    = Open      -- ^ task is under work
    | Reviewed  -- ^ task is reviewed by others, it is ready to
                -- make the decision
    | Closed    -- ^ task is closed, there is no work with it
    deriving (Eq, Show)

-- | Very important attribute.
data Deadline
    = NoDeadline -- ^ For tasks without deadline
    | Deadline Day -- ^ Deadline
    deriving (Eq, Show)

data Task = Task
    { taskId        :: Int
    , taskTitle     :: String
    , taskPriority  :: Priority
    , taskStatus    :: Status
    , taskDeadline  :: Deadline
    , taskSummary   :: Summary
    }
    deriving (Eq, Show)

isOpen :: Task -> Bool
isOpen task = taskStatus task == Open

-- | Checks for finished task
isFinished :: Task -> Bool
isFinished (Task _ _ _ Closed _)  = True
isFinished _                      = False

hasDeadline :: Task -> Bool
hasDeadline task =
    case taskDeadline task of
        NoDeadline -> False
        Deadline _ -> True

isImportant :: Task -> Bool
isImportant task = taskPriority task >= Important

-- | Not closed and high priority task?
needsAttention :: Task -> Bool
needsAttention task = not (isFinished task) && isImportant task

mkSummary :: String -> Summary
mkSummary = Summary

summaryText :: Summary -> String
summaryText (Summary s) = s

setSummary :: Summary -> Task -> Task
setSummary su (Task id title priority status deadline _) = Task id title priority status deadline su

