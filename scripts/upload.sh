#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SCRIPT_DIR/../slackmojicurl.sh"

NEW_DIR="$DATA_DIR/upload-new"
DONE_DIR="$DATA_DIR/upload-done"
mkdir -p "$DONE_DIR"
FAILED_DIR="$DATA_DIR/upload-failed"
mkdir -p "$FAILED_DIR"

directory="/path/to/your/directory"

if [ -z "$(ls -A $NEW_DIR)" ]; then
  echo "$NEW_DIR is empty. Nothing to upload!"
  exit 0
fi

for file in "$NEW_DIR"/*; do
  filename=$(basename "$file")
  filepath=$(realpath "$file")
  filename_without_extension="${filename%.*}"
  echo "Filename: $filename_without_extension"
  echo "Absolute Path: $filepath"

  slackmojicurl "add" "mode=data" "name=$filename_without_extension" "image=@$filepath"

  if [ "$SUCCESS" == "true" ]; then
    echo "Uploaded successfully: $filename"
    mv $file "$DONE_DIR/$filename"
  else
    mv $file "$FAILED_DIR/$filename"
  fi

done
