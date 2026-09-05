module Worklog.Todo
(
  Urgency(..),
  Todo(..),
  mkTodo,
  isUrgent
)
where

import Worklog.Implementation.Internal

data Urgency
  = NotSoUrgent
  | Urgent
  deriving (Eq, Ord, Show)

data Todo = Todo
  {
    todoUrgency :: Urgency,
    todoSummary :: Summary
  }
  deriving (Eq, Show)

instance HasSummary Todo where
  getSummary = todoSummary
  setSummary todo s = todo {todoSummary = s}

mkTodo :: Urgency -> Summary -> Todo
mkTodo = Todo

isUrgent :: Todo -> Bool
isUrgent todo = todoUrgency todo == Urgent

