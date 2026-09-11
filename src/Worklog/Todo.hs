-- | The Todo type introduce a case specific task or to-do.
-- It is connected to the case, it is neccessary to accomplish to
-- reach some advance in the case. For example: to call or email somebody
-- or find or review a document, before the appropriate decision is made.
--
-- Very important, that Todo lives only in the case, and obviously
-- a case cannot be archived if it has Todo.
module Worklog.Todo
(
  Todo(..),
  Urgency(..),
  newTodo,
  isUrgent
)
where

import Worklog.Implementation.Internal

-- | A Todo can be Urgent, which means that it must be executed
-- as soon as possible, today, or tomorrow.
-- NotSoUrgent Todos can be postponed for a while.
data Urgency
  = NotSoUrgent
  | Urgent
  deriving (Eq, Ord, Show)

-- | Very simple type, Urgency and a Summary type to hold
-- the todo's matter.
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

