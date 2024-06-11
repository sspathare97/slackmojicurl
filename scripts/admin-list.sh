#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SCRIPT_DIR/../slackmojicurl.sh"

ADMIN_LIST_DIR="$DATA_DIR/admin-list"
mkdir -p "$ADMIN_LIST_DIR"

page=1

while true; do

  slackmojicurl "adminList" "page=$page" "count=1000" "sort_by=name" "sort_dir=asc"

  if [ "$SUCCESS" == "true" ]; then
    echo "Page fetched successfully: $page"
    page_number=$(printf "%02d" $page)
    echo "$RESPONSE" | jq --indent 2 '.' > "$ADMIN_LIST_DIR/page-$page_number.json"

    total_pages=$(echo "$RESPONSE" | jq -r '.paging.pages')
    ((page++))
    if [ "$page" -gt "$total_pages" ]; then
      break
    fi

  else
    echo "Failed to fetch page: $page"
    break
  fi

done
