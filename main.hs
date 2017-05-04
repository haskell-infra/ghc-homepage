{-# LANGUAGE OverloadedStrings #-}

import Data.List
import Data.Maybe
import Data.Monoid
import Numeric

import System.Directory
import System.FilePath

import Text.Pandoc
import Hakyll
import Hakyll.Core.Metadata
import Hakyll.Web.Template.Context
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as HA
import qualified Text.Blaze.Html.Renderer.String as H

import Types

main :: IO ()
main = hakyll $ rules

rules :: Rules ()
rules = do
    match "ghc.css" $ do
        route     idRoute
        compile   copyFileCompiler

    match "images/*" $ do
        route     idRoute
        compile   copyFileCompiler

    match "download_*.shtml" $ do
        let ctx' = titleField <> tarballsField <> downloadsUrlField <> ctx
            titleField = functionField "title" $ \_ item -> do
                version <- fromMaybe "???" <$> getMetadataField (itemIdentifier item) "version"
                return $ "GHC "++version++" download"

        route   $ setExtension "html"
        compile $ getResourceBody
              >>= applyAsTemplate ctx'
              >>= loadAndApplyTemplate "templates/default.html" ctx'
              >>= relativizeUrls

    match "*.shtml" $ do
        route   $ setExtension "html"
        compile $ getResourceBody
              >>= applyAsTemplate ctx
              >>= loadAndApplyTemplate "templates/default.html" ctx
              >>= relativizeUrls

    match "*.mkd" $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
              >>= loadAndApplyTemplate "templates/default.html" ctx
              >>= relativizeUrls

    match "templates/*" $ compile templateCompiler
    match "partials/*" $ compile getResourceString
    match "files.index" $ compile getResourceString
  where
      ctx = snippetField <> defaultContext

downloadsUrlField :: Context a
downloadsUrlField = functionField "downloads_url" $ \_ item -> do
    mversion <- getMetadataField (itemIdentifier item) "version"
    case mversion of
      Nothing -> fail $ "downloadsUrlField: No version"
      Just version -> return $ rootUrl </> version

tarballsField :: Context a
tarballsField = functionField "tarballs" $ \args item -> do
    files <- fmap read $ loadBody "files.index" :: Compiler [DownloadFile]
    let ident = itemIdentifier item
        uhOh err = do
            unsafeCompiler $ putStrLn $ "Warning: " <> show ident <> ": " <> err
            return $ H.renderHtml $ H.toHtml err
    root <- fromMaybe "" <$> getMetadataField ident "bindist-root"
    filename <- case args of
                  [filename] -> return filename
                  _          -> uhOh "Invalid argument list for $file"

    mversion <- getMetadataField ident "version"
    case mversion of
      Nothing -> uhOh $ "No file for " <> filename
      Just version ->
        let isMyFile f = (version </> "ghc-" <> version <> "-" <> filename <> ".") `isPrefixOf` filePath f
            toFileContent f = H.li $ do
                downloadLink (filePath f) $ H.toHtml (takeFileName $ filePath f)
                " (" <> H.toHtml (showFFloat (Just 1) (realToFrac (fileSize f) / 1024 / 1024) "") <> " MB"
                case fileSignature f of
                  Just sig -> ", " >> downloadLink sig "sig"
                  Nothing  -> mempty
                ")"
        in case filter isMyFile files of
             [] -> uhOh $ "No files for " <> filename
             files' -> return $ H.renderHtml $ H.ul $ foldMap toFileContent files'

downloadLink :: FilePath -> H.Html -> H.Html
downloadLink path body = H.a H.! HA.href (H.stringValue $ downloadUrl path) $ body

downloadUrl path = rootUrl <> "/" <> path

rootUrl = "https://downloads.haskell.org/~ghc"
