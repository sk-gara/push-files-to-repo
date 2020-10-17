#!/bin/sh -l

# Combination of:
# - https://github.com/cpina/github-action-push-to-another-repository
# - https://github.com/dmnemec/copy_file_to_another_repo_action

set -e
set -x

echo "Start"

if [ -z "$INPUT_AUTHOR" ]
then
  INPUT_AUTHOR="$GITHUB_ACTOR"
fi
if [ -z "$INPUT_AUTHOR_EMAIL" ]
then
  INPUT_AUTHOR_EMAIL="$INPUT_AUTHOR@users.noreply.github.com"
fi
if [ -z "$INPUT_TARGET_BRANCH" ]
then
  INPUT_TARGET_BRANCH="main"
fi

CLONE_DIR=$(mktemp -d)

echo "Cloning destination git repository"
# Setup git
git config --global user.email "$INPUT_AUTHOR_EMAIL"
git config --global user.name "$INPUT_AUTHOR"
git clone --single-branch --branch "$INPUT_TARGET_BRANCH" "https://$INPUT_TOKEN@github.com/$INPUT_DESTINATION_REPO.git" "$CLONE_DIR"
ls -la "$CLONE_DIR"

echo "Copying contents to to git repo"
mkdir -p $CLONE_DIR/$INPUT_DESTINATION_FOLDER
cp -r "$INPUT_SOURCE_FILE_PATH"/* "$CLONE_DIR/$INPUT_DESTINATION_FOLDER"
cd "$CLONE_DIR"
ls -la

echo "Adding git commit"
git add .
git status
git commit --message "Update from https://github.com/$GITHUB_REPOSITORY/commit/$GITHUB_SHA"

echo "Pushing git commit"
git push origin "$INPUT_TARGET_BRANCH"
