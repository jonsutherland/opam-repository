#!/bin/sh
set -eu

## Mirror Docker image from GitLab container registry @GCP to private ECR @AWS

# shellcheck source=./scripts/docker.sh
. ./scripts/docker.sh

set -x

for tag_prefix in ${docker_images}
do
  regctl image copy "${CI_REGISTRY_IMAGE}:${tag_prefix}--${CI_COMMIT_SHA}" \
                    "${AWS_ECR_IMAGE}:${tag_prefix}--${CI_COMMIT_SHA}"
done