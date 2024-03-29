#!/usr/bin/env bash

set -euo pipefail

# Store path to csproj
csproj_path=$1

# Checks if the file exists
if [[ ! -f "$csproj_path" ]]; then
  echo "File '$csproj_path' does not exist." >&2
  exit 1
fi

# Read version from csproj file and save into a variable
version=$(grep -oPm1 "(?<=<Version>)[^<]+" "$csproj_path")

# Split the version into an array on the period '.'
IFS='.' read -r -a version_parts <<<"$version"

if [[ ${#version_parts[@]} -ne 3 ]]; then
  echo "Version '$version' is not in the correct format. Expected format is 'major.minor.patch'." >&2
  exit 1
fi

# Increment the last part of the version number
((version_parts[2]++))

# Recombine the version parts back into a full version string
new_version="${version_parts[0]}.${version_parts[1]}.${version_parts[2]}"

# Replace the old version with the new version in the .csproj file
sed -i "s/<Version>$version/<Version>$new_version/g" "$csproj_path"

# echo the output as the new version because the GitHub action will use this as an output
echo "$new_version"
