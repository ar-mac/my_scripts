#!/bin/bash

# Script: remove_old_branches.sh
# Description: Removes local Git branches older than a specified number of days and containing "QUEST-" in their name.
# Usage: ./remove_old_branches.sh [options]
# Options:
#   -d               Use the -d option for deleting only merged branches.
#   -D               Use the -D option for deleting branches (force deletion).
#   --dry-run        Only list the branches that would be removed without deleting them. Default: true
#   -days=N          Specify the number of days (N) for considering branches as old. Default: 90 days.
#
# Note: The default behavior is --dry-run that shows which branches are to be removed.
# To actually delete them use the -d or -D option.

# Get the current date
current_date=$(date +%s)

# Default number of days for considering branches as old
days=90

# Parse command-line arguments
delete_option="" # Default: no option
dry_run=true # Default: dry run

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -D)
      delete_option="-D" # Use -D option for deletion
      dry_run=false
      shift
      ;;
    -d)
      delete_option="-d" # Use -d option for deletion
      dry_run=false
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
  echo "Branches longer than ${days} day(s) to be removed:"
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
  echo "No branches to remove."
fi
