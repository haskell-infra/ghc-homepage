#!/usr/bin/env bash

set -e

# docs/ seems to be a URL rewrite rule provided by haskell.org
# dist/mac_frameworks appears to be lost to history
linkchecker http://localhost:8000 --ignore-url 'docs/' --ignore-url=dist/mac_frameworks

