#!/bin/bash

set +e
ERRORS=""

while IFS= read -r -d '' file; do
  echo "Validating $file"

  if [[ "$file" =~ \  ]]; then
    echo -e "\033[0;31mFilename contains whitespace: $file\033[0m"
    ERRORS="${ERRORS}\n\033[0;31mFilename contains whitespace: $file\033[0m"
    continue
  fi

  FRONTMATTER=$(sed -n '/^{/,/^}/p' "$file")
  echo "$FRONTMATTER" | jq '.' > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo -e "\033[0;31mInvalid JSON in $file\033[0m"
    ERRORS="${ERRORS}\n\033[0;31mInvalid JSON in $file\033[0m"
    continue
  fi

  CONTENT=$(sed -n '/^}/,$p' "$file" | tail -n +2 | tr -d '[:space:]')

  if [ -z "$CONTENT" ]; then
    echo -e "\033[0;31mNo content found after front matter in $file\033[0m"
    ERRORS="${ERRORS}\n\033[0;31mNo content found after front matter in $file\033[0m"
    continue
  fi
  
  REQUIRED_KEYS=("title" "excerpt" "creation_date" "postHashTags" "author")
  for key in "${REQUIRED_KEYS[@]}"; do
    VALUE=$(echo "$FRONTMATTER" | jq -r ".${key}")
    if [ "$VALUE" == "null" ] || [ -z "$VALUE" ]; then
      echo -e "\033[0;31mMissing or empty key '$key' in $file\033[0m"
      ERRORS="${ERRORS}\n\033[0;31mMissing or empty key '$key' in $file\033[0m"
      continue
    fi
    if [ "$key" == "creation_date" ]; then
      PARSED_DATE=$(date -d "$VALUE" "+%Y-%m-%dT%H:%M:%S" 2>/dev/null)
      if [ "$PARSED_DATE" != "$VALUE" ]; then
        echo -e "\033[0;31mInvalid creation_date format in $file. Expected format: Y-m-d\TH:i:s\033[0m"
        ERRORS="${ERRORS}\n\033[0;31mInvalid creation_date format in $file\033[0m"
      fi
    fi
    if [ "$key" == "postHashTags" ]; then
      if ! echo "$FRONTMATTER" | jq -e ".${key} | arrays" > /dev/null; then
        echo -e "\033[0;31mpostHashTags is not a valid array in $file\033[0m"
        ERRORS="${ERRORS}\n\033[0;31mpostHashTags is not a valid array in $file\033[0m"
      fi
    fi
  done
done < <(find ./blog -name '*.md' -print0)

if [ -n "$ERRORS" ]; then
  echo -e "Errors found:${ERRORS}"
  exit 1
else
  echo "All files validated successfully."
fi
