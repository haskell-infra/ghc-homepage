import Data.List
import Data.Maybe
import System.Environment

import System.Directory
import System.FilePath
import Hakyll
import Types

collectFiles :: FilePath -> IO [DownloadFile]
collectFiles root = do
    getRecursiveContents (return . isHidden) root >>= fmap catMaybes . mapM toDownloadFile
  where
    isHidden path = "." `isPrefixOf` takeFileName path
    isTarball name = ".tar.gz"  `isSuffixOf` name
                  || ".tar.bz2" `isSuffixOf` name
                  || ".tar.xz"  `isSuffixOf` name
    toDownloadFile path
      | isTarball path = do
        let sigPath = root </> path <.> "sig"

        sig <- doesFileExist sigPath
        size <- getFileSize (root </> path)
        return $ Just $ DownloadFile { filePath = path
                                     , fileSize = size
                                     , fileSignature = if sig then Just sigPath else Nothing
                                     }
      | otherwise = return Nothing

main :: IO ()
main = do
    [root] <- getArgs
    files <- collectFiles root
    writeFile "files.index" (show files)
