#!/bin/sh
set -eu

## Mirror Docker image from GitLab container registry @GCP to private ECR @AWS

# shellcheck source=./scripts/docker.sh
. ./scripts/docker.sh

set -x

for docker_image in ${docker_images}
do
  regctl image copy "${CI_REGISTRY_IMAGE}:${docker_image}--${CI_COMMIT_SHA}" \
                    "${AWS_ECR_IMAGE}:${docker_image}--${CI_COMMIT_SHA}"
done
