#!/bin/sh
set -eu

# Docker JSON configuration for both GitLab container registry and Amazon ECR

mkdir -pv /root/.docker
CI_REGISTRY_AUTH=$(printf '%s:%s' "${CI_REGISTRY_USER}" "${CI_REGISTRY_PASSWORD}" | base64 | tr -d '\n')
echo "{\"auths\":{\"registry.gitlab.com\":{\"auth\":\"${CI_REGISTRY_AUTH}\"}},\"credHelpers\":{\"${AWS_ECR}\":\"ecr-login\"}}" > /root/.docker/config.json
