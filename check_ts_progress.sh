#!/bin/bash

# Create initial CSV file
echo "date,jsFiles,tsFiles" > commits.csv

# Find merge commits younger than 1 year
merge_commits=$(git log --merges --since="1 year ago" --pretty=format:'%H')

# Loop through merge commits
for commit in $merge_commits
do
  # Checkout the commit
  git checkout $commit

  # Get commit date
  commit_date=$(git log -1 --format="%ai" $commit | cut -d' ' -f1)

  # Count jsFiles
  js_files=$(find ./src -type f -regex ".*\.js[x]*" | wc -l | tr -d '\n')

  # Count tsFiles
  ts_files=$(find ./src -type f -regex ".*\.ts[x]*" | wc -l | tr -d '\n')

   Append new entry to CSV file
    echo "$commit_date,$js_files,$ts_files" >> commits.csv

done

# Return to the latest commit
git checkout master
