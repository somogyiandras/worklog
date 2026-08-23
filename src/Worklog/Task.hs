-- | Task logic
module Worklog.Task
(
    Status (..),
    Task (..),
    isOpen
)
where

data Status
    = Open
    | Reviewed
    | Close
    deriving (Eq, Show)

data Task = Task
    { taskId        :: Int
    , taskTitle     :: String
    , taskStatus    :: Status
    }
    deriving (Eq, Show)

isOpen :: Task -> Bool
isOpen task = taskStatus task == Open


