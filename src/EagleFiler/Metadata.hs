{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE StrictData #-}

module EagleFiler.Metadata
  ( Metadata(..)
  , Tags(..)
  , Date(..)
  , decodeMetadata
  ) where

--------------------------------------------------------------------------------

import qualified Data.ByteString.Char8 as BS
import qualified Data.ByteString.Lazy as Lazy (ByteString)
import qualified Data.Csv as Csv
import qualified Data.Text as Strict (Text)
import qualified Data.Text as TS
import qualified Data.Text.Encoding as TS
import Data.Vector (Vector)
import Data.Time (LocalTime)
import qualified Data.Time as Time
import GHC.Generics (Generic)

--------------------------------------------------------------------------------

-- | The kind of the record. This seems to generally be the file type. There are
-- certainly more kinds not included here.
data RecordKind
  = FolderKind
  | ImageKind
  | PDFKind
  | PowerPointKind
  | RTFKind
  | TextKind
  | WebArchiveKind
  | OtherKind !Strict.Text

instance Show RecordKind where
  show = \case
    FolderKind     -> "Folder"
    ImageKind      -> "Image"
    PDFKind        -> "PDF"
    PowerPointKind -> "Microsoft PowerPoint Document"
    RTFKind        -> "RTF Document"
    TextKind       -> "Text File"
    WebArchiveKind -> "Web Archive"
    OtherKind k    -> TS.unpack k

instance Csv.FromField RecordKind where
  parseField f
    | f == "Folder"                         = return FolderKind
    | f == "Image"                          = return ImageKind
    | f == "PDF"                            = return PDFKind
    | f == "Microsoft PowerPoint Document"  = return PowerPointKind
    | f == "RTF Document"                   = return RTFKind
    | f == "Text File"                      = return TextKind
    | f == "Web Archive"                    = return WebArchiveKind
    | otherwise                             = return $ OtherKind $ TS.decodeUtf8 f

-- | A list of tags. This type only exists for the 'Csv.FromField' instance.
newtype Tags = Tags [Strict.Text]
  deriving (Monoid, Show)

instance Csv.FromField Tags where
  parseField = return . Tags . map TS.decodeUtf8 . BS.split ','

-- | A local date-time. This type primarily exists for the 'Csv.FromField'
-- instance.
newtype Date = Date LocalTime
  deriving Show

instance Csv.FromField Date where
  parseField = fmap Date . parse . BS.unpack
    where
      parse :: String -> Csv.Parser LocalTime
      parse = Time.parseTimeM True Time.defaultTimeLocale
        (Time.iso8601DateFormat $ Just "%H:%M:%S")

-- | The EagleFiler metadata record
data Metadata = Metadata
  { fileName      :: !Strict.Text
  , filePath      :: !Strict.Text
  , recordKind    :: !RecordKind
  , title         :: !Strict.Text
  , from          :: !(Maybe Strict.Text)
  , sourceUrl     :: !(Maybe Strict.Text)
  , dateCreated   :: !Date
  , dateAdded     :: !Date
  , dateModified  :: !Date
  , labelIndex    :: !Int
  , tags          :: !Tags
  , notes         :: !(Maybe Strict.Text)
  }
  deriving (Generic, Show)

instance Csv.FromRecord Metadata

--------------------------------------------------------------------------------

-- | Decode EagleFiler metadata from CSV data extracted by the accompanying
-- AppleScript
decodeMetadata :: Lazy.ByteString -> Either String (Vector Metadata)
decodeMetadata = Csv.decode Csv.HasHeader
