-- | Domain types and operations for individual cases.
module Worklog.Case
  ( -- * Case
    Case,
    newCase,

    -- ** Read only parameters
    getCaseTitle,

    -- ** Mutable parameters
    caseDeadline,

    -- ** Status of task
    Status (..),
    getCaseStatus,
    isOnDesk,
    isArchived,
    isDeferred,
    getDeferredDay,
    deferCase,
    needsAttention,

    -- ** Deadlines
    Deadline (..),
    hasDeadline,
    setDeadline,

    -- ** Flags
    CaseFlag (..),
    anyFlag, hasFlag, addFlag, removeFlag,

    -- ** Todos
    addTodo,
    listCaseTodos,

    -- ** Tasks
    addTask,
    listCaseTasks,

    -- * Other types
    Warning,
    -- * Functions
    )
where

import Worklog.Implementation.Internal
import Worklog.Todo
import Worklog.Task
import Worklog.Attachment

import Data.Time.Calendar
import Data.Set (Set)
import qualified Data.Set as Set

-- | Indicates whether a case requires attention.
-- Currently, every non-archived case is considered to need attention.
needsAttention :: Case -> Bool
needsAttention cas = not (isArchived cas) 

data Status
  = -- | The case is actively being worked on.
    OnDesk
  | -- | The case is deferred until the specified date.
    Deferred Day
  | -- | The case has been closed and archived.
    Archived
  deriving (Eq, Show)

getCaseStatus :: Case -> Status
getCaseStatus = caseStatus

isOnDesk :: Case -> Bool
isOnDesk cas = caseStatus cas == OnDesk

-- | Returns 'True' for archived cases.
isArchived :: Case -> Bool
isArchived cas = caseStatus cas == Archived

isDeferred :: Case -> Bool
isDeferred Case {caseStatus = Deferred _} = True
isDeferred _ = False

getDeferredDay :: Case -> Maybe Day
getDeferredDay Case {caseStatus = Deferred day} = Just day
getDeferredDay _ = Nothing

deferCase :: Case -> Day -> Case
deferCase cas day = cas { caseStatus = Deferred day }

type Warning = String


-- The status of the case is burnt in the workfile. In
-- this version of the API does not provide opening and
-- closing a case, the case must be create with the status.
-- Close the case and send it to the archives.
-- If the case has flags or todo items then it gets back
-- Left Warning messages
{-- closeCase :: Case -> Either Warning Case
closeCase cas
  | isArchived cas = Left "Case already closed"
  | isDeferred cas = Left "Case is deferred, not on desk"
  | anyFlag cas = Left "Case cannot be closed, it has duties"
  | otherwise = Right $ cas {caseStatus = Archived}
--}

-- Put the task on the desk, open it and start working on it.
-- openCase :: Case -> Case
-- openCase cas = cas {caseStatus = OnDesk}

-- | An optional case deadline.
data Deadline
  = -- | No deadline has been assigned.
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

-- | Flags indicating conditions that affect a case.
data CaseFlag
    = Waiting
    -- ^ Work is waiting for an external response or event.
    | NeedsManager
    -- ^ A manager's decision is required.
    | ApprovalPending
    -- ^ At least one outgoing document is awaiting approval.
    deriving (Eq, Ord, Show)

anyFlag :: Case -> Bool
anyFlag = not . Set.null . caseFlags

hasFlag :: CaseFlag -> Case -> Bool
hasFlag flag = Set.member flag . caseFlags

addFlag :: CaseFlag -> Case -> Case
addFlag flag cas = cas {caseFlags = Set.insert flag (caseFlags cas)}

removeFlag :: CaseFlag -> Case -> Case
removeFlag flag cas = cas {caseFlags = Set.delete flag (caseFlags cas)}

-- | Represents a case described by a workfile, including its title,
-- status, deadline, summary, flags, and associated work items.
--
-- The summary representation may later be changed to Pandoc blocks.
data Case = Case
  { 
  -- todo: The metadata from the workfile must be preserved
    caseTitle :: String,
    caseStatus :: Status,
    caseDeadline :: Deadline,
    caseSummary :: Summary,
    caseFlags :: Set CaseFlag,
    caseTodos :: [Todo],
    caseTasks :: [Task],
    caseAttachments :: [Attachment]
  }
  deriving (Eq, Show)

instance HasSummary Case where
  getSummary = caseSummary
  setSummary cas s = cas {caseSummary = s}

-- | Returns the case title without exposing a setter.
getCaseTitle :: Case -> String
getCaseTitle = caseTitle

-- | Creates an on-desk case with no deadline or associated items.
-- This temporary constructor is intended for tests and may be removed
-- from the public API once validated parsing is available.
newCase :: String -> Case
newCase title = Case
  { caseTitle = title,
    caseStatus = OnDesk,
    caseDeadline = NoDeadline,
    caseSummary = emptySummary,
    caseFlags = Set.empty,
    caseTodos = [],
    caseTasks = [],
    caseAttachments = []
  }

-- ToDo: ?set a lista helyett a todo és a task esetén?
-- nem számít a sorrend, azonban a tárolni kell valahol
-- a workfileban a sor számát, hogy oda lehessen ugrani
listCaseTodos :: Case -> [Todo]
listCaseTodos = caseTodos

addTodo :: Todo -> Case -> Case
addTodo todo cas = cas {caseTodos = listCaseTodos cas ++ [todo]}

listCaseTasks :: Case -> [Task]
listCaseTasks = caseTasks

addTask :: Task -> Case -> Case
addTask task cas = cas {caseTasks = listCaseTasks cas ++ [task]}

