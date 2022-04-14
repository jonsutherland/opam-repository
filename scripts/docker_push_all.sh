#!/bin/sh
set -eu

## Push all Docker images to GitLab container registry

# shellcheck source=./scripts/docker.sh
. ./scripts/docker.sh

tag_suffix="${1}"

for tag_prefix in ${docker_images}
do
  docker push "${CI_REGISTRY_IMAGE}:${tag_prefix}--${tag_suffix}"
done
