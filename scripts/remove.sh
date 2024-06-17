#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SCRIPT_DIR/../slackmojicurl.sh"

REMOVE_SRC_DIR="$DATA_DIR/upload-done"

function get_files_matching_pattern {
  local directory=$1
  local pattern="91*"
  local matching_files=()

  # Check if the directory exists
  if [[ -d "$directory" ]]; then
    # Find files matching the pattern and store them in the array
    for file in "$directory"/$pattern; do
      if [[ -f "$file" ]]; then
        filename=$(basename $file);
        filename_without_extension="${filename%.*}"
        matching_files+=("$filename_without_extension")
      fi
    done
  else
    echo "Directory $directory does not exist."
    return 1
  fi

  # Use declare -p to return the array
  declare -p matching_files
}

# Capture the output of the function in a variable
result=$(get_files_matching_pattern "$REMOVE_SRC_DIR")
# Evaluate the captured output to recreate the array
eval "$result"
# Now matching_files array is available
echo "Files matching pattern in $directory: ${matching_files[@]}"

for emoji_name in "${matching_files[@]}"; do
  echo "Emoji: $emoji_name"

  slackmojicurl "remove" "name=$emoji_name"

  if [[ "$SUCCESS" == "true" ]]; then
    echo "Removed successfully: $emoji_name"
  fi

done
