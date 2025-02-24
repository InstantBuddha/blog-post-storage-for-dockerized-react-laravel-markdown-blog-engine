#!/bin/bash

set +e
RED='\033[0;31m'
NC='\033[0m'

declare -A FILE_ERRORS

error() {
  local message="$1"
  local file="$2"
  echo -e "${RED}$message in $file${NC}"
  FILE_ERRORS["$file"]+="$message"$'\n'
}

check_filename_for_whitespaces() {
  local file="$1"
  if [[ "$file" =~ \  ]]; then
    error "Filename contains whitespace" "$file"
  fi
}

extract_front_matter() {
  local file="$1"
  local front_matter
  front_matter=$(sed -n '/^{/,/^}/p' "$file")
  echo "$front_matter"
}

validate_json() {
  local front_matter="$1"
  local file="$2"
  if ! echo "$front_matter" | jq '.' > /dev/null 2>&1; then
    error "Invalid JSON" "$file"
    return 1
  fi
  return 0
}

check_for_content_after_front_matter() {
  local file="$1"
  local content
  content=$(sed -n '/^}/,$p' "$file" | tail -n +2 | tr -d '[:space:]')
  if [ -z "$content" ]; then
    error "No content found after front matter" "$file"
  fi
}

validate_required_keys() {
  local front_matter="$1"
  local file="$2"
  local required_keys=("title" "excerpt" "creation_date" "postHashTags" "author")
  for key in "${required_keys[@]}"; do
    local value
    value=$(echo "$front_matter" | jq -r ".${key}")
    if [ "$value" == "null" ] || [ -z "$value" ]; then
      error "Missing or empty key '$key'" "$file"
      continue
    fi
    if [ "$key" == "creation_date" ]; then
      local parsed_date
      parsed_date=$(date -d "$value" "+%Y-%m-%dT%H:%M:%S" 2>/dev/null)
      if [ "$parsed_date" != "$value" ]; then
        error "Invalid creation_date format. Expected format: Y-m-d\TH:i:s" "$file"
      fi
    fi
    if [ "$key" == "postHashTags" ]; then
      if ! echo "$front_matter" | jq -e ".${key} | arrays" > /dev/null; then
        error "postHashTags is not a valid array" "$file"
      fi
    fi
  done
}

while IFS= read -r -d '' file; do
  echo "Validating $file"

  check_filename_for_whitespaces "$file"

  FRONTMATTER=$(extract_front_matter "$file")

  validate_json "$FRONTMATTER" "$file"
  if [ $? -ne 0 ]; then
    continue
  fi

  check_for_content_after_front_matter "$file"

  validate_required_keys "$FRONTMATTER" "$file"

done < <(find ./blog -name '*.md' -print0)

if [ ${#FILE_ERRORS[@]} -ne 0 ]; then
  error_file_count=${#FILE_ERRORS[@]}
  echo -e "${RED}Errors found in $error_file_count file(s):${NC}"
  for file in "${!FILE_ERRORS[@]}"; do
    echo -e "${RED}Problems in file $file:${NC}"
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            echo -e "${RED}- $line${NC}"
        fi
    done <<< "${FILE_ERRORS["$file"]}"
  done
  exit 1
else
  echo "All files validated successfully."
fi