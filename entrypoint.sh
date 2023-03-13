#!/bin/bash
set -e

echo "🟪 Splitting subtree on $INPUT_PATH..."
# Git will extract the specified subdirectory and create a new commit history
# that includes only the files and directories within that subdirectory. This
# new commit history will be stored in a new Git branch, which will be created
# automatically by the subtree command. The new branch will include all of the
# history for the original repository that relates to the specified
# subdirectory. It then prints out the ref to that branch which we capture in
# a variable.
ref=$(git subtree split -P "$INPUT_PATH")

# TODO: Include $GITHUB_TOKEN in here to make it work pushing to other repos
# outside of the current $GITHUB_REPOSITORY
remote="$GITHUB_SERVER_URL/$GITHUB_REPOSITORY.wiki.git"
echo "🟪 Pushing $ref too $remote..."
git push -f "$remote" "$ref:master"
echo "🟩 Successfully published to the GitHub wiki for $GITHUB_REPOSITORY."
