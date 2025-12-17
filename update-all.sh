#!/bin/bash
set -eo pipefail

function localCacheExists() {
  local _chartName="$1"
  local _chartVersion="$2"

  if [ -f "./${_chartName}-${_chartVersion}.tgz" ]
  then
    return 0
  else
    return 1
  fi
}

WORK_DONE_FILE="$(mktemp)"
echo -n "false" > "$WORK_DONE_FILE"
while read -r repo
do
  cd charts
  chartName="$(basename "$repo")"
  echo "Updating $repo (Chart: $chartName)"
  repo_no_prefix="${repo#oci://}"
  oras repo tags "$repo_no_prefix" | grep -Eo '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -nr | while read -r tag
  do
    echo "Found tag $tag in remote repo."
    if ! localCacheExists "$chartName" "$tag"
    then
      echo "Missing local version of $chartName:$tag"
      helm pull "$repo" --version "$tag"
      echo -n "true" > "$WORK_DONE_FILE"
    else
      echo "Local version of $chartName:$tag exists, skipping pull"
    fi
  done
  cd ..
done < ./tracked.txt

WORK_DONE="$(cat "$WORK_DONE_FILE")"
echo "WORK_DONE=$WORK_DONE"
if [ "$WORK_DONE" == "true" ]
then
  echo "Creating index"
  helm repo index charts --url https://notepass.github.io/helm-oci-proxied-charts/charts/
  if [ "$GHA" == "true" ]
  then
    echo "Writing changes_present=true to changes to $GITHUB_OUTPUT"
    echo "changes_present=true" >> "$GITHUB_OUTPUT"
  fi
else
  echo "No updates happened - Skipping index update"
  if [ "$GHA" == "true" ]
    then
      echo "Writing changes_present=false to changes to $GITHUB_OUTPUT"
    echo "changes_present=false" >> "$GITHUB_OUTPUT"
  fi
fi
