{-# LANGUAGE OverloadedStrings #-}

import Data.Maybe
import Data.Monoid

import Text.Pandoc
import Hakyll
import Hakyll.Core.Metadata
import Hakyll.Web.Template.Context
import qualified Text.Blaze.Html5 as B

data DownloadFile = DownloadFile { filePath :: FilePath
                                 , fileSize :: Int
                                 , fileSignature :: Maybe FilePath
                                 }

collectFiles :: FilePath -> IO [DownloadFile]
collectFiles root = do
    return []

main :: IO ()
main = do
    files <- collectFiles "."
    let templates = [ compileTemplate  ]
    hakyll rules

rules :: Rules ()
rules = do
    match "ghc.css" $ do
        route     idRoute
        compile   copyFileCompiler

    match "images/*" $ do
        route     idRoute
        compile   copyFileCompiler

    match "download_*.shtml" $ do
        let ctx' = titleField <> ctx
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
  where
      ctx = snippetField <> defaultContext

bindistContext :: [DownloadFile] -> Context a
bindistContext files =
    functionField "bindist"
    $ \fields item -> do
        ident <- getUnderlying
        root <- fromMaybe "" <$> getMetadataField ident "bindist-root"
        return root
