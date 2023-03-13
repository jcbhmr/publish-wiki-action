#!/bin/bash
set -e

source url.sh

echo "🟪 Splitting subtree on $INPUT_PATH..."
# Git will extract the specified subdirectory and create a new commit history
# that includes only the files and directories within that subdirectory. This
# new commit history will be stored in a new Git branch, which will be created
# automatically by the subtree command. The new branch will include all of the
# history for the original repository that relates to the specified
# subdirectory. It then prints out the ref to that branch which we capture in
# a variable.
ref=$(git subtree split -P "$INPUT_PATH")
echo "🟩 Successfully split $INPUT_PATH into $ref."

scheme=$(url "$GITHUB_SERVER_URL" | jq -r .scheme)
host=$(url "$GITHUB_SERVER_URL" | jq -r .host)
pathame=$(url "$GITHUB_SERVER_URL" | jq -r .pathname)
remote="$scheme//$GITHUB_ACTOR:$INPUT_TOKEN@$host$pathname$INPUT_REPO.wiki.git"
# Don't worry! The $INPUT_TOKEN is masked by GitHub Actions when postprocessed.
echo "🟪 Pushing $ref too $remote..."
git push -f "$remote" "$ref:master"
echo "🟩 Successfully published to the GitHub wiki for $GITHUB_REPOSITORY."
