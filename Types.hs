module Types where

data DownloadFile = DownloadFile { filePath :: FilePath
                                 , fileSize :: Integer
                                 , fileSignature :: Maybe FilePath
                                 }
    deriving (Show, Read)
