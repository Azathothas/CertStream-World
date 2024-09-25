#!/usr/bin/env bash

## Bash Script to only print latest changes for a file
## Required Deps : coreutils curl git grep jq moreutils sed

# bash <(curl -qfsSL "https://raw.githubusercontent.com/Azathothas/CertStream-World/main/.github/scripts/only_print_latest.sh")

# Check if the file path is provided as an argument
 if [ -z "$1" ]; then
     echo "Usage: $0 <file_path>"
     exit 1
 fi

#Env
 #Updated every 3-4 hr, get's reset at 00:00 UTC, contains all new domains since 00:00 UTC
 #export FILE_PATH="Russia/certstream_domains_ru_all_24h.txt"
 export FILE_PATH="$1"

#Clone the repo:
 pushd "$(mktemp -d)" > /dev/null 2>&1 && git clone --filter "blob:none" "https://github.com/Azathothas/CertStream-World" > /dev/null 2>&1 && cd "./CertStream-World"

#Get the SHA of the latest commit affecting the specified file
 SHA="$(git log -n 1 --pretty=format:'%H' -- "$FILE_PATH")" && export SHA="$SHA"

#Fetch the diff for the specified file
 DIFF_OUTPUT="$(mktemp)" && export DIFF_OUTPUT="$DIFF_OUTPUT"
 git diff --no-color --ignore-space-at-eol -U0 "$SHA" "$SHA^" -- "$FILE_PATH" | grep "^-" | sed '/^--/d; s/^-//' | sort -u -o "$DIFF_OUTPUT"

#Get UTC Time for the hash
 TIME="$(git show --format='%cd' --date='format:%Y-%m-%d %H:%M:%S' --no-patch "$SHA")" && export TIME="$TIME"

#Display the diff
 popd > /dev/null 2>&1 ; echo -e "\n\n"
#Comment this line if don't want terminal to get spammed 
 cat "$DIFF_OUTPUT"
#Show metrics 
 echo -e "\n[+] Commit SHA Used: $SHA"
 echo -e "[+] Commit Made : $TIME UTC"
 echo -e "[+] New Domains Count: $(wc -l < $DIFF_OUTPUT)"
 echo -e "[+] New Domains Saved: $DIFF_OUTPUT\n"
#EOF
