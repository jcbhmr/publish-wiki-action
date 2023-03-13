#!/bin/bash
url() (
  set -e

  echo 'Hello world!'
)
if ! (return 2>/dev/null); then
  url "$@"
fi
