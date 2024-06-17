#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SCRIPT_DIR/../slackmojicurl.sh"

ALIAS_FILE="$DATA_DIR/upload-alias.csv"

while IFS=',' read -r name alias_for
do

  slackmojicurl "add" "mode=alias" "name=$name" "alias_for=$alias_for"

  if [[ "$SUCCESS" == "true" ]]; then
    echo "Uploaded successfully: $name"
  fi

done < "$ALIAS_FILE"
