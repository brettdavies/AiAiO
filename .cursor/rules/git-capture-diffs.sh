# .cursor/scripts/git/capture-state.sh
#!/bin/bash

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "ERR_NOT_GIT_REPO"; exit 1; }
cd "$ROOT" || exit 1

DIRS=${1:-.}

# Collect non-existent directories
NON_EXISTENT_DIRS=()
for dir in ${DIRS//,/ }; do
  if [ ! -d "$dir" ]; then
    NON_EXISTENT_DIRS+=("$dir")
  fi
done

# If there are non-existent directories, print them and exit with error
if [ ${#NON_EXISTENT_DIRS[@]} -ne 0 ]; then
  echo "ERR_INVALID_DIRS: ${NON_EXISTENT_DIRS[*]}"
  exit 1
fi

# Capture the state of the specified directories
(git status "$DIRS" && echo -e "\nChanges in files:" && git diff "$DIRS") > .idea/_gitdiff.tmp