#!/bin/sh -l

echo "Starts"
FOLDER="$1"
USER_EMAIL="$4"
TARGET_BRANCH="$6"

if [ -z "$INPUT_USER_NAME" ]
then
  INPUT_USER_NAME="$GITHUB_ACTOR"
fi
if [ -z "$TARGET_BRANCH" ]
then
  TARGET_BRANCH="master"
fi

CLONE_DIR=$(mktemp -d)

echo "Cloning destination git repository"
# Setup git
git config --global user.email "$USER_EMAIL"
git config --global user.name "$INPUT_USER_NAME"
git clone --single-branch --branch "$TARGET_BRANCH" "https://$API_TOKEN_GITHUB@github.com/$INPUT_DESTINATION_REPO.git" "$CLONE_DIR"
ls -la "$CLONE_DIR"

#echo "Cleaning destination repository of old files"
## Copy files into the git and deletes all git
#find "$CLONE_DIR" | grep -v "^$CLONE_DIR/\.git" | grep -v "^$CLONE_DIR$" | xargs rm -rf # delete all files (to handle deletions)
#ls -la "$CLONE_DIR"

echo "Copying contents to to git repo"
mkdir -p $CLONE_DIR/$INPUT_DESTINATION_FOLDER
cp -r "$FOLDER"/* "$CLONE_DIR/$INPUT_DESTINATION_FOLDER"
cd "$CLONE_DIR"
ls -la

echo "Adding git commit"
git add .
git status
git commit --message "Update from https://github.com/$GITHUB_REPOSITORY/commit/$GITHUB_SHA"

echo "Pushing git commit"
git push origin "$TARGET_BRANCH"
