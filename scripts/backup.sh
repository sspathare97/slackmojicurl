#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SCRIPT_DIR/../slackmojicurl.sh"

TIMESTAMP_DIR="$DATA_DIR/$(date +"%Y-%m-%d_%H-%M-%S")"

ADMIN_LIST_DIR="$TIMESTAMP_DIR/admin-list"
mkdir -p "$ADMIN_LIST_DIR"
rm -rf "$ADMIN_LIST_DIR"/*

BACKUP_FILE="$TIMESTAMP_DIR/backup.csv"
touch "$BACKUP_FILE"
: > "$BACKUP_FILE"
echo "name,is_alias,alias_for,url,team_id,user_id,created,is_bad,user_display_name,avatar_hash" > $BACKUP_FILE

ALIAS_FILE="$TIMESTAMP_DIR/backup-alias.csv"
touch "$ALIAS_FILE"
: > "$ALIAS_FILE"
echo "name,alias_for" > $ALIAS_FILE

BACKUP_DIR="$TIMESTAMP_DIR/backup-images"
mkdir -p "$BACKUP_DIR"
rm -rf "$BACKUP_DIR"/*

COMMANDS_FILE="$TIMESTAMP_DIR/backup-commands.txt"
touch "$COMMANDS_FILE"
: > "$COMMANDS_FILE"

page=1

while true; do

  slackmojicurl "adminList" "page=$page" "count=1000" "sort_by=name" "sort_dir=asc"

  if [ "$SUCCESS" == "true" ]; then
    echo "Page fetched successfully: $page"
    page_number=$(printf "%02d" $page)
    echo "$RESPONSE" | jq --indent 2 '.' > "$ADMIN_LIST_DIR/page-$page_number.json"
    
    echo "$RESPONSE" | jq -r '.emoji[] | "\(.name),\(.is_alias),\(.alias_for),\(.url),\(.team_id),\(.user_id),\(.created),\(.is_bad),\(.user_display_name),\(.avatar_hash)"' >> $BACKUP_FILE

    total_pages=$(echo "$RESPONSE" | jq -r '.paging.pages')
    ((page++))
    if [ "$page" -gt "$total_pages" ]; then
      echo "Fetched all $total_pages pages"
      break
    fi

  else
    echo "Failed to fetch page: $page"
    exit 1
  fi

done

while IFS="," read -r name is_alias alias_for url team_id user_id created is_bad user_display_name avatar_hash
do
  if [ "$is_alias" -eq 0 ]; then
    filename=$(basename $url);
    extension="${filename##*.}"
    echo "wget -O \"$BACKUP_DIR/$name.$extension\" '$url'" >> "$COMMANDS_FILE"
  else
    echo "$name,$alias_for" >> "$ALIAS_FILE"
  fi
done < <(tail -n +2 "$BACKUP_FILE")

echo "Wrote alias and commands files"

cat "$COMMANDS_FILE" | parallel -j 250

rm "$COMMANDS_FILE"

echo "Backup successful!"
