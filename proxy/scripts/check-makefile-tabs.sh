#!/usr/bin/env bash
set -e

# Look for lines starting with spaces instead of a tab in Makefile rules
if grep -P '^[ ]{4,}' Makefile | grep -v '^#' ; then
  echo "❌ Makefile uses spaces instead of tabs. Fix indentation!"
  exit 1
else
  echo "✅ Makefile indentation is valid."
fi

