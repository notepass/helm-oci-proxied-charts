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

WORK_DONE=false
while read -r repo
do
  cd charts
  chartName="$(basename "$repo")"
  echo "Updating $repo (Chart: $chartName)"
  oras repo tags codeberg.org/wrenix/helm-charts/paperless-ngx | grep -Eo '[0-9]\.[0-9]\.[0-9]' | while read -r tag
  do
    echo "Found tag $tag in remote repo."
    if ! localCacheExists "$chartName" "$tag"
    then
      echo "Missing local version of $chartName:$tag"
      helm pull "$repo" --version "$tag"
      WORK_DONE=true
    else
      echo "Local version of $chartName:$tag exists, skipping pull"
    fi
  done
  cd ..
done < ./tracked.txt

if [ "$WORK_DONE" == "true" ]
then
  echo "Creating index"
  helm repo index charts --url https://notepass.github.io/helm-oci-proxied-charts/charts/
else
  echo "No updates happened - Skipping index update"
fi