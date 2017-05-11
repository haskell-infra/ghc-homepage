This repository contains the source code for
the [primary GHC website](https://www.haskell.org/ghc).

## Updating content

The site is generated using the [Hakyll](http://hakyll.org/) static-site
generator. Use `cabal` to build the `ghc-website` executable.

The website can be built using the `ghc-website build` command.

The website cna be previewed locally using `ghc-website watch`. You can then run
`./check.sh` to run `linkcheck` on your local copy.

Since 7.10.2 we auto-generate the tarball links on the release download pages.
This requires metadata describing the files available from the download site
(e.g. `downloads.haskell.org`) which is stored in `files.index`. This file can
be updated using the `gen-index` executable provided by this package, passing
the path to a local checkout of the downloads repository on the command line.

## Deploying

First build the website with,
```
$ ghc-website build
```
The resulting content will be in `_site/`. This can be `rsync`'d to
`webhost.haskell.org` (using `sftpfs` since `webhost.haskell.org` only offers
SFTP).

