#!/usr/bin/env bash

set -e

mkdir -p mnt
sshfs webhost.haskell.org:ghc mnt
rsync -rv _site/ mnt || (fusermount -u mnt && false)
sleep 1
fusermount -u mnt

