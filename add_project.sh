#!/bin/bash

# Directory of your main repo
MAIN_REPO="/home/aryan/chrt/Public-ground"

# Move to main repo
cd "$MAIN_REPO" || { echo "Main repo not found"; exit 1; }

# Path to local project (the argument)
LOCAL_PROJECT="$1"

if [ -z "$LOCAL_PROJECT" ]; then
    echo "Usage: $0 /path/to/local/project"
    exit 1
fi

# Ensure the project path is valid
if [ ! -d "$LOCAL_PROJECT/.git" ]; then
    echo "'$LOCAL_PROJECT' is not a git repository."
    exit 1
fi

# Folder name inside MyLearnings
FOLDER_NAME=$(basename "$LOCAL_PROJECT")

# Temporary remote name (safe: replace - or spaces)
REMOTE_NAME="temp_remote_${FOLDER_NAME//[^a-zA-Z0-9]/_}"


REMOTE_BRANCH=$(git -C "$LOCAL_PROJECT" symbolic-ref --short HEAD)

if [ -z "$REMOTE_BRANCH" ]; then
    echo "Could not detect remote branch of $LOCAL_PROJECT"
    exit 1
fi

# Check if folder already exists in MyLearnings
if [ -d "$MAIN_REPO/$FOLDER_NAME" ]; then
    echo "Directory '$FOLDER_NAME' already exists in MyLearnings."
    read -p "Do you want to overwrite/merge it? (y/n): " ans
    if [ "$ans" != "y" ]; then
        echo " Aborted."
        exit 1
    fi
    rm -rf "$MAIN_REPO/$FOLDER_NAME"
fi

echo "Adding $LOCAL_PROJECT"

# Add local project as remote
git remote add "$REMOTE_NAME" "$LOCAL_PROJECT"

# Fetch from local project
git fetch "$REMOTE_NAME"

# Add subtree with history into subdirectory
git subtree add --prefix="$FOLDER_NAME" "$REMOTE_NAME" "$REMOTE_BRANCH" -m "Add project $FOLDER_NAME with history"

# Remove temporary remote
git remote remove "$REMOTE_NAME"

# Push changes to GitHub
git push

echo "Successfully added '$FOLDER_NAME' to the target and pushed."
