#!/bin/bash

# Script: remove_old_branches.sh
# Description: Removes local Git branches older than a specified number of days and containing "QUEST-" in their name.
# Usage: ./remove_old_branches.sh [options]
# Options:
#   -D               Use the -D option for deleting branches (force deletion).
#   --dry-run        Only list the branches that would be removed without deleting them.
#   -days=N          Specify the number of days (N) for considering branches as old. Default: 90 days.
#
# Note: The default behavior is to use the -d option for deleting branches, which only deletes branches that have been fully merged.

# Get the current date
current_date=$(date +%s)

# Default number of days for considering branches as old
days=90

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
    -days=*)
      days="${key#*=}" # Extract the number of days
      shift
      ;;
    *)
      echo "Unknown option: $key"
      exit 1
      ;;
  esac
done

# Calculate the number of seconds in the specified number of days
days_in_seconds=$((days * 24 * 60 * 60))

if [ "$dry_run" = true ]; then
  echo "Branches to be removed:"
fi
has_branches_to_remove=false
# Iterate through all local branches
for branch in $(git branch --format='%(refname:short)'); do
  # Get the branch's last commit date
  last_commit_date=$(git log -1 --format=%at "$branch")

  # Calculate the difference in seconds between the current date and the last commit date
  time_difference=$((current_date - last_commit_date))

  # Check if the branch is older than the specified number of days
  if [ "$time_difference" -gt "$days_in_seconds" ]; then
    if [ "$dry_run" = true ]; then
      has_branches_to_remove=true
      # Dry run: List the branch without deleting
      echo "$branch"
    else
      # Delete the branch
      git branch "$delete_option" "$branch"
    fi
  fi
done
if [ "$has_branches_to_remove" = false ]; then
  echo "No branches"
fi
