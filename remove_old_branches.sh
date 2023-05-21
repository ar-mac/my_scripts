#!/bin/bash

# Get the current date
current_date=$(date +%s)

# Parse command-line arguments
delete_option="-d" # Default: -d option
dry_run=false

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -D)
      delete_option="-D" # Use -D option for deletion
      shift
      ;;
    --dry-run)
      dry_run=true
      shift
      ;;
    *)
      echo "Unknown option: $key"
      exit 1
      ;;
  esac
done

if [ "$dry_run" = true ]; then
  # Dry run: List the branch without deleting
  echo "Branches to be removed:"
fi

# Iterate through all local branches
for branch in $(git branch --format='%(refname:short)' | grep "QUEST-"); do
  # Get the branch's last commit date
  last_commit_date=$(git log -1 --format=%at "$branch")

  # Calculate the difference in seconds between the current date and the last commit date
  time_difference=$((current_date - last_commit_date))

  # Calculate the number of seconds in 3 months (approx.)
  three_months=$((90 * 24 * 60 * 60))

  # Check if the branch is older than 3 months
  if [ "$time_difference" -gt "$three_months" ]; then
    if [ "$dry_run" = true ]; then
      # Dry run: List the branch without deleting
      echo $branch
    else
      # Delete the branch
      git branch "$delete_option" "$branch"
    fi
  fi
done
