#!/usr/bin/env bash
# Takes a .csproj file as the first argument and an optional new version as the
# second argument. When the second argument is not provided, the patch version
# is incremented by 1. The script will update the version in the .csproj file
# and print the new version.

set -euo pipefail

csproj_file=$1

# Check if the csproj file exists
if [[ ! -f "$csproj_file" ]]; then
  echo "File '$csproj_file' does not exist." >&2
  exit 1
fi

# Read version from csproj file
version=$(grep -oPm1 "(?<=<Version>)[^<]+" "$csproj_file")

# Function to validate version format
validate_version() {
  local version=$1
  local version_regex="^[0-9]+\.[0-9]+\.[0-9]+$"

  if ! [[ $version =~ $version_regex ]]; then
    echo "Version '$version' is not in the correct format. Expected format is 'major.minor.patch'." >&2
    exit 1
  fi
}

# Validate the current version format
validate_version "$version"

# Get new version from second argument or increment patch version
if [[ -n "${2-}" ]]; then
  # Validate the new version format
  validate_version "$2"
  new_version=$2
else

  # Split the version into an array
  IFS='.' read -r -a version_parts <<<"$version"

  # Increment the patch version
  version_parts[2]=$((version_parts[2] + 1))

  new_version="${version_parts[0]}.${version_parts[1]}.${version_parts[2]}"
fi

# Replace the old version with the new version in the .csproj file
sed -i "s/<Version>$version/<Version>$new_version/g" "$csproj_file"

echo "$new_version"
