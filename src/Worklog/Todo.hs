module Worklog.Todo
(
  Urgency(..),
  Todo(..)
)
where

data Urgency
  = NotSoUrgent
  | Urgent
  deriving (Eq, Ord, Show)
    

data Todo = Todo
  {
    todoUrgency :: Urgency,
    todoMatter :: String
  }
