#!/bin/bash
set -eo pipefail

if [ -z "$OCI_URL" ]
then
  read -rp "OCI Url: " OCI_URL
fi

if [ -z "$OCI_TAG" ]
then
  read -rp "Version: " OCI_TAG
fi

if [ -d charts ]
then
  cd charts
fi

helm pull "$OCI_URL" --version "$OCI_TAG"
cd ..

helm repo index charts --url https://example.com/