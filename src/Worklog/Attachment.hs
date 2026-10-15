-- | Documents and other files associated with a case.
module Worklog.Attachment
(
  Attachment(..),
  AttachmentKind(..),
  IncomingDocType(..),
  OutgoingDocType(..),
  InternalDocType(..),
  newAttachment
)
where

import Text.Pandoc.MIME

-- | Classifies attachments by their role in a case.
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

-- | Stores an attachment's classification, optional location, identifiers,
-- inferred MIME type, and subject.
data Attachment = Attachment
  {
    attachmentKind :: AttachmentKind,
    attachmentPath :: Maybe RelativePath,
    attachmentIds :: [DocumentID],
    attachmentMimeType :: Maybe MimeType,
    attachmentSubject :: DocumentSubjet
  }
  deriving (Eq, Show)

newAttachment :: AttachmentKind -> Maybe RelativePath -> [DocumentID] -> DocumentSubjet -> Attachment
newAttachment akind mpath maI sub = Attachment akind mpath maI mimetype sub where
  mimetype = case mpath of
    Nothing -> Nothing
    Just (RelativePath fpath) -> getMimeType fpath



