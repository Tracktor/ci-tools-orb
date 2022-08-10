#!/bin/bash

set -xe


if [[ "${CONTAINER_REGISTRY_USER}" != "" ]]; then
  echo "${CONTAINER_REGISTRY_PWD}" | docker login -u "${CONTAINER_REGISTRY_USER}" --password-stdin
fi

docker import image.tar "${IMAGE_NAME}:${CURRENT_VERSION}"
docker import image.tar "${IMAGE_NAME}:${LATEST_VERSION}"

docker push "${IMAGE_NAME}:${CURRENT_VERSION}"
docker push "${IMAGE_NAME}:${LATEST_VERSION}"
