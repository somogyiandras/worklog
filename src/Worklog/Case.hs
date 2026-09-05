-- | Domain logic for the individual cases.
module Worklog.Case
  ( -- * Task and its attributes
    Case,
    caseId, caseTitle, casePriority, caseDeadline,
    newCase,

    -- ** Status of task
    Status (..),
    isOnDesk,
    isArchived,
    isDeferred,
    getDefferedDay,
    deferrCase,

    -- ** Priority
    Priority (..),
    isImportant,
    needsAttention,
    setCasePriority,
    promoteCase,
    demoteCase,

    -- ** Deadlines
    Deadline (..),
    hasDeadline,
    setDeadline,

    -- ** Flags
    CaseFlag (..),
    anyFlag, hasFlag, addFlag, removeFlag,

    -- * Other types
    Warning,
    -- * Functions
    closeCase, openCase,
    mkSummary,
    summaryText,
    emptySummary,
    getSummary, setSummary
  )
where

import Worklog.Implementation.Internal
import Data.Time.Calendar
import Data.Set (Set)
import qualified Data.Set as Set


data Priority
  = ForgetIt
  | Postpone
  | Normal
  | Important
  | VeryImportant
  deriving (Eq, Ord, Show, Enum, Bounded)

isImportant :: Case -> Bool
isImportant cas = casePriority cas >= Important

-- | Not closed and high priority case
needsAttention :: Case -> Bool
needsAttention cas = not (isArchived cas) && isImportant cas

setCasePriority :: Priority -> Case -> Case
setCasePriority p cas = cas {casePriority = p}

promoteCase :: Case -> Case
promoteCase cas
  | casePriority cas == maxBound = cas
  | otherwise = cas {casePriority = succ $ casePriority cas}

demoteCase :: Case -> Case
demoteCase cas
  | casePriority cas == minBound = cas
  | otherwise = cas {casePriority = pred $ casePriority cas}

data Status
  = -- | case is on the desk, we work on it
    OnDesk
  | -- | case is in the cabinet, waiting for the deadline to come back on desk
    Deferred Day
  | -- | case is closed, it is in the archives, hoppefully never comes back
    Archived
  deriving (Eq, Show)

isOnDesk :: Case -> Bool
isOnDesk cas = caseStatus cas == OnDesk

-- | Checks for finished case
isArchived :: Case -> Bool
isArchived cas = caseStatus cas == Archived

isDeferred :: Case -> Bool
isDeferred Case {caseStatus = Deferred _} = True
isDeferred _ = False

getDefferedDay :: Case -> Maybe Day
getDefferedDay Case {caseStatus = Deferred day} = Just day
getDefferedDay _ = Nothing

deferrCase :: Case -> Day -> Case
deferrCase cas day = cas { caseStatus = Deferred day }

type Warning = String

-- Close the case and send it to the archives.
-- If the case has flags or todo items then it gets back
-- Left Warning messages
closeCase :: Case -> Either Warning Case
closeCase cas
  | isArchived cas = Left "Case already closed"
  | isDeferred cas = Left "Case is deferred, not on desk"
  | anyFlag cas = Left "Case cannot be closed, it has duties"
  | otherwise = Right $ cas {caseStatus = Archived}

-- Put the task on the desk, open it and start working on it.
openCase :: Case -> Case
openCase cas = cas {caseStatus = OnDesk}

-- | the deadline of the task
data Deadline
  = -- | For tasks without deadline
    NoDeadline
  | -- | Deadline
    Deadline Day
  deriving (Eq, Show)

hasDeadline :: Case -> Bool
hasDeadline cas =
  case caseDeadline cas of
    NoDeadline -> False
    Deadline _ -> True

setDeadline :: Deadline -> Case -> Case
setDeadline day cas = cas {caseDeadline = day}

-- | Flags are attributes of the task.
data CaseFlag
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

anyFlag :: Case -> Bool
anyFlag = not . Set.null . caseFlags

hasFlag :: CaseFlag -> Case -> Bool
hasFlag flag = Set.member flag . caseFlags

addFlag :: CaseFlag -> Case -> Case
addFlag flag cas = cas {caseFlags = Set.insert flag (caseFlags cas)}

removeFlag :: CaseFlag -> Case -> Case
removeFlag flag cas = cas {caseFlags = Set.delete flag (caseFlags cas)}

-- | The Case data type contains the parameters of the case
-- correspondent to the workfile. Some title, a longer summary,
-- priority and status, and of course deadline. The caseFlags
-- attributes 
--
-- The summary field currently will be implemented as Pandoc Block.
--
-- The case has an ID.
data Case = Case
  { caseId :: Int,
    caseTitle :: String,
    casePriority :: Priority,
    caseStatus :: Status,
    caseDeadline :: Deadline,
    caseSummary :: Summary,
    caseFlags :: Set CaseFlag
  }
  deriving (Eq, Show)

-- | mkTask id title creates an open task with normal priority,
-- no deadline and empty summary.
newCase :: Int -> String -> Case
newCase iD title = Case
  { caseId = iD,
    caseTitle = title,
    casePriority = Normal,
    caseStatus = OnDesk,
    caseDeadline = NoDeadline,
    caseSummary = emptySummary,
    caseFlags = Set.empty
  }



setSummary :: Summary -> Case -> Case
setSummary s cas = cas {caseSummary = s}

getSummary :: Case -> Summary
getSummary = caseSummary 
