-- | Defines case-specific to-do items needed to move a case forward,
-- such as contacting someone or reviewing a document.
-- Outstanding to-do items should be resolved before archiving a case.
module Worklog.Todo
(
  Todo(..),
  Urgency(..),
  newTodo,
  isUrgent
)
where

import Worklog.Implementation.Internal

-- | Indicates whether a to-do item requires prompt attention.
-- 'Urgent' items should generally be handled today or tomorrow;
-- 'NotSoUrgent' items can be postponed.
data Urgency
  = NotSoUrgent
  | Urgent
  deriving (Eq, Ord, Show)

-- | A to-do item with its urgency and summary.
data Todo = Todo
  {
    todoUrgency :: Urgency,
    todoSummary :: Summary
  }
  deriving (Eq, Show)

instance HasSummary Todo where
  getSummary = todoSummary
  setSummary todo s = todo {todoSummary = s}

-- ToDo: change to Maybe Todo. Cannot create Todo
-- with emptySummary
newTodo :: Urgency -> Summary -> Todo
newTodo = Todo

isUrgent :: Todo -> Bool
isUrgent todo = todoUrgency todo == Urgent

