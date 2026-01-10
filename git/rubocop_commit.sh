#!/bin/bash

# Script to run RuboCop auto-correct on Ruby files from a specific git commit
# Usage: ./rubocop_commit.sh <git-ref>

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <git-ref>"
    echo "Example: $0 HEAD"
    echo "Example: $0 abc123"
    echo "Example: $0 feature-branch"
    exit 1
fi

GIT_REF="$1"

echo "Finding Ruby files in commit: $GIT_REF"

# Get list of Ruby files that were modified in the commit
RUBY_FILES=$(git diff-tree --no-commit-id --name-only -r "$GIT_REF" | grep -E '\.(rb|rake)$' | grep -v '^db/migrate/' || true)

if [ -z "$RUBY_FILES" ]; then
    echo "No Ruby files found in commit $GIT_REF"
    exit 0
fi

echo "Found Ruby files:"
echo "$RUBY_FILES"
echo ""

# Convert to array for proper handling of filenames with spaces
readarray -t FILES_ARRAY <<< "$RUBY_FILES"

echo "Running RuboCop auto-correct on ${#FILES_ARRAY[@]} files..."

# Run RuboCop with auto-correct on the specific files
# Using --force-exclusion to respect .rubocop.yml excludes
docker compose exec web bin/rubocop -A --force-exclusion "${FILES_ARRAY[@]}"

echo "RuboCop auto-correct completed!"