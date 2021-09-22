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

TARGET_BRANCH_EXISTS=true

CLONE_DIR=$(mktemp -d)

echo "Clean up old references maybe"
git remote prune origin

echo "Cloning destination git repository"
# Setup git
git config --global user.email "$INPUT_AUTHOR_EMAIL"
git config --global user.name "$INPUT_AUTHOR"
# Clone branch matching the target branch name or default branch (master, main, etc)
{ # try
  git clone --single-branch --branch "$INPUT_TARGET_BRANCH" "https://$INPUT_TOKEN@github.com/$INPUT_DESTINATION_REPO.git" "$CLONE_DIR"
} || { # on no such remote branch, pull default branch instead
  echo "The input target branch does not already exist on the target repository. It will be created."
  git clone --single-branch "https://$INPUT_TOKEN@github.com/$INPUT_DESTINATION_REPO.git" "$CLONE_DIR"
  TARGET_BRANCH_EXISTS=false
}

ls -la "$CLONE_DIR"

echo "Copying files to git repo. Invisible files must be handled differently than visible files."
# Include dot files for source filepath
mkdir -p $CLONE_DIR/$INPUT_DESTINATION_FOLDER

files=0
hidden_files=0
for file in "$INPUT_SOURCE_FILE_PATH"/.[!.]*; do
        if [[ -a "$file" ]]; then
              $hidden_files=1
              break
        fi
done

for file in "$INPUT_SOURCE_FILE_PATH"/*; do
        if [[ -f "$file" ]]; then
              $files=1
              break
        fi
done

if [ $files == 1 ] ; then
  cp -r "$INPUT_SOURCE_FILE_PATH"/* "$CLONE_DIR/$INPUT_DESTINATION_FOLDER"
else
  echo "WARNING: No visible files exist"
fi
# invisible_exists=false
if [ $hidden_files == 1 ]; then
  cp -r "$INPUT_SOURCE_FILE_PATH"/.??* "$CLONE_DIR/$INPUT_DESTINATION_FOLDER"
else
  echo "WARNING: No invisible/hidden (dot) files exist"
fi

cd "$CLONE_DIR"
ls -la

# Create branch locally if it doesn't already exist locally
if [ "$TARGET_BRANCH_EXISTS" = false ] ; then
  git checkout -b "$INPUT_TARGET_BRANCH"
fi

echo "Adding git commit"
git add .
git status
# git diff-index to avoid an error when there are no changes to commit
git diff-index --quiet HEAD || git commit --message "Update from https://github.com/$GITHUB_REPOSITORY/commit/$GITHUB_SHA"

echo "Pushing git commit. Create branch if none exists."
# --set-upstream also creates the branch if it doesn't already exist in the destination repository
git push origin --set-upstream "$INPUT_TARGET_BRANCH"
