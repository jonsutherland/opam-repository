#!/bin/sh
set -eu

## Multi-arch docker images with a single tag

# shellcheck source=./scripts/docker.sh
. ./scripts/docker.sh

# Loop over images
for tag_prefix in ${docker_images}
do
  echo "### Merging tags for docker image: ${tag_prefix}"

  # Loop over architectures
  amends=''
  for docker_architecture in ${docker_architectures}
  do
    amends="${amends} --amend ${CI_REGISTRY_IMAGE}:${tag_prefix}--${docker_architecture}--${CI_COMMIT_SHA}"
  done

  # Because of the variable amends, we use eval here to first construct the command
  # by concatenating all the arguments together (space separated), then read and execute it
  eval "docker manifest create ${CI_REGISTRY_IMAGE}:${tag_prefix}--${CI_COMMIT_SHA}${amends}"
  docker manifest push "${CI_REGISTRY_IMAGE}:${tag_prefix}--${CI_COMMIT_SHA}"
done
