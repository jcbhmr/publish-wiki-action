#!/bin/sh

TEMP_CLONE_FOLDER="temp_wiki_$GITHUB_SHA"
TEMP_EXCLUDED_FILE="temp_wiki_excluded_$GITHUB_SHA.txt"

if [ -z "$GH_TOKEN" ]; then
  echo "GH_TOKEN ENV is missing. Use $\{{ secrets.GITHUB_TOKEN }} or a PAT if your wiki repo is different from your current repo."
  exit 1
fi

if [ -z "$REPO" ]; then
  echo "REPO ENV is missing. Using the current one."
  REPO=$GITHUB_REPOSITORY
fi

if [ -z "$WIKI_DIR" ]; then
    echo "WIKI_FOLDER ENV is missing, using default wiki/"
    WIKI_DIR='wiki/'
fi

if [ -n "$GH_NAME" -a -n "$GH_MAIL" ]; then

# Disable Safe Repository checks
git config --global --add safe.directory "/github/workspace"
git config --global --add safe.directory "/github/workspace/$TEMP_CLONE_FOLDER"

echo "Cloning wiki git..."
git clone https://$GH_NAME:$GH_TOKEN@github.com/$REPO.wiki.git $TEMP_CLONE_FOLDER

# Get commit message
if [ -z "$WIKI_PUSH_MESSAGE" ]; then
  message=$(git log -1 --format=%B)
else
  message=$WIKI_PUSH_MESSAGE
fi
echo "Message:"
echo $message

echo "Copying files to Wiki"
# Configuring a file to exclude specified files
if [ -z "$EXCLUDED_FILES" ]; then
  rsync -av --delete $WIKI_DIR $TEMP_CLONE_FOLDER/ --exclude .git
else
  for file in $EXCLUDED_FILES; do
    echo "$file" >> ./$TEMP_EXCLUDED_FILE
  done
  rsync -av --delete $WIKI_DIR $TEMP_CLONE_FOLDER/ --exclude .git --exclude-from=$TEMP_EXCLUDED_FILE
  # Delete files in target repo if it was a reminant.
  for file in $EXCLUDED_FILES; do
    rm -r $TEMP_CLONE_FOLDER/$file
  done
fi

echo "Pushing to Wiki"
cd $TEMP_CLONE_FOLDER

# Setup credentials
git config user.name $GH_NAME
git config user.email $GH_MAIL

git add .
git commit -m "$message"
git push origin master

else
  # FUTURE: Rename "WIKI_DIR" option to "path" in action.yml
  INPUT_PATH="$WIKI_DIR"

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
fi
