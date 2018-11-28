#! /bin/bash

#########################################
# 1. Builds a new deployment image of
#    oasislabs/parity-ethereum
#    and tags it with the provided tag.
# 2. Push deployment image to Docker Hub.
#########################################

# Helpful tips on writing build scripts:
# https://buildkite.com/docs/pipelines/writing-build-scripts
set -euxo pipefail

###############
# Required args
###############
git_commit_sha=$1
docker_image_tag=$2

#################
# Local variables
#################
docker_image_name=oasislabs/parity-ethereum

####################################
# Build and publish the docker image
####################################

set +x
# The docker command will contain the SSH private key
# in plain text and we don't want that getting into bash
# history, so we intentionally disable printing commands
# with set +x.
set -x

# Build the deployable image
docker build --rm --force-rm \
  --build-arg PARITY_ETHEREUM_BUILD_IMAGE_TAG=${docker_image_tag} \
  --build-arg PARITY_ETHEREUM_COMMIT_SHA=${git_commit_sha} \
  --build-arg GITHUB_USER=${GITHUB_USER} \
  --build-arg GITHUB_TOKEN=${GITHUB_TOKEN} \
  -t ${docker_image_name}:${docker_image_tag} \
  -f docker/Dockerfile .

docker push ${docker_image_name}:${docker_image_tag}

# Remove the intermediate docker images that contain
# the private SSH key
docker rmi -f $(docker images -q --filter label=stage=intermediate)
