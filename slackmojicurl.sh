#!/bin/bash

REPO_ROOT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ENV_FILE="$REPO_ROOT_DIR/.env"

function load_env() {
  # Check whether .env file exists
  if [ ! -f "$ENV_FILE" ]; then
    echo ".env file not found!"
    exit 1
  fi

  # Load environment variables from .env file
  export $(grep -v '^#' "$ENV_FILE" | xargs)

  # Check whether environment variables are set
  if [ -z "$WORKSPACE_URL" ] || [ -z "$AUTH_COOKIE" ] || [ -z "$API_TOKEN" ]; then
    echo "WORKSPACE_URL or AUTH_COOKIE or API_TOKEN not set in .env file!"
    exit 1
  else echo 'Loaded environment variables from .env file'
  fi

  WORKSPACE_NAME=$(echo "$WORKSPACE_URL" | sed 's/.*\/\/\([^\/]*\)\.slack\.com.*/\1/')
  
  BASE_WORKSPACE_DIR="$REPO_ROOT_DIR/workspaces"
  mkdir -p "$BASE_WORKSPACE_DIR"
  CURRENT_WORKSPACE_DIR="$BASE_WORKSPACE_DIR/$WORKSPACE_NAME"
  mkdir -p "$CURRENT_WORKSPACE_DIR"
  
  DATA_DIR="$CURRENT_WORKSPACE_DIR/data"
  mkdir -p "$DATA_DIR"
  LOG_DIR="$CURRENT_WORKSPACE_DIR/logs"
  mkdir -p "$LOG_DIR"
  LOG_FILE="$LOG_DIR/$(date +"%Y-%m-%d_%H-%M-%S").log"
  exec > >(tee -a "$LOG_FILE") 2>&1
}

function slackmojicurl() {
  local endpoint="$1"
  local form_data=("${@:2}")
  form_data+=("token=$API_TOKEN")

  local url="$WORKSPACE_URL/api/emoji.$endpoint"
  echo 'Loaded function parameters'

  local curl_command=$(cat <<EOF
curl --location "$url" \
  --header 'accept: application/json, text/plain, */*' \
  --header 'accept-language: en-US,en;q=0.9' \
  --header 'cache-control: no-cache' \
  --header 'cookie: d=$AUTH_COOKIE' \
  --header 'origin: $WORKSPACE_URL' \
  --header 'pragma: no-cache' \
  --header 'priority: u=1, i' \
  --header 'sec-ch-ua: "Chromium";v="125", "Not.A/Brand";v="24"' \
  --header 'sec-ch-ua-mobile: ?0' \
  --header 'sec-ch-ua-platform: "Linux"' \
  --header 'sec-fetch-dest: empty' \
  --header 'sec-fetch-mode: cors' \
  --header 'sec-fetch-site: same-origin' \
  --header 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36'
EOF
)

  for param in "${form_data[@]}"; do
    curl_command+=" --form '$param'"
  done

  RESPONSE=$(eval "$curl_command")

  SUCCESS=$(echo "$RESPONSE" | jq '.ok')

  if [ "$SUCCESS" == "true" ]; then
    echo "Success!"
  else
    error_message=$(echo "$RESPONSE" | jq -r '.error')
    echo "Failed with error: $error_message!"
  fi
}

# Load environment variables
load_env
