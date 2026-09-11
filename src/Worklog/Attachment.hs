-- | The Attachment type describes a document related to the case.
-- The document's minimal 
module Worklog.Attachment
(
  Attachment(..),
  AttachmentKind(..),
  IncomingDocType,
  OutgoingDocType,
  InternalDocType,
  newAttachment
)
where

import Text.Pandoc.MIME

-- | A Todo can be Urgent, which means that it must be executed
-- as soon as possible, today, or tomorrow.
-- NotSoUrgent Todos can postpone for a while.
data AttachmentKind
  = Picture
  | Incoming IncomingDocType
  | Outgoing OutgoingDocType
  | Internal InternalDocType
  | GeneralDoc
  deriving (Eq, Show)

data IncomingDocType
  = Application
  | Information
  | Report
  | Assessment
  | OtherIncoming String
  deriving (Eq, Show)

data OutgoingDocType
  = Decision
  | Order
  | Letter
  | OtherOutgoing String
  deriving (Eq, Show)

data InternalDocType
  = InternalNote
  | InternalMemo
  deriving (Eq, Show)

newtype DocumentID = DocumentID String
  deriving (Eq, Show)

type DocumentSubjet = String

newtype RelativePath = RelativePath FilePath
  deriving (Eq, Show)

-- | Very simple type, Urgency and a Summary type to hold
-- the todos matter.
data Attachment = Attachment
  {
    attachmentKind :: AttachmentKind,
    attachmentPath :: Maybe RelativePath,
    attachmentIds :: Maybe [DocumentID],
    attachmentMimeType :: Maybe MimeType,
    attachmentSubject :: DocumentSubjet
  }
  deriving (Eq, Show)

newAttachment :: AttachmentKind -> Maybe RelativePath -> Maybe [DocumentID] -> DocumentSubjet -> Attachment
newAttachment akind mpath maI sub = Attachment akind mpath maI mimetype sub where
  mimetype = case mpath of
    Nothing -> Nothing
    Just (RelativePath fpath) -> getMimeType fpath



