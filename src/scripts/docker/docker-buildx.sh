#!/bin/bash

if [[ "${CONTAINER_REGISTRY_USER}" != "" ]]; then
  echo "${CONTAINER_REGISTRY_PWD}" | docker login -u "${CONTAINER_REGISTRY_USER}" --password-stdin
fi

docker pull "${IMAGE_NAME}:${LATEST_VERSION}" || true

# shellcheck disable=SC2086
docker buildx build --cache-from "${IMAGE_NAME}:${LATEST_VERSION}" \
  --build-arg BUILDKIT_INLINE_CACHE=1 ${BUILD_PARAMS:-} \
  -t "${IMAGE_NAME}:${CURRENT_VERSION}" \
  -t "${IMAGE_NAME}:${LATEST_VERSION}" \
  -f "${DOCKER_FILE}" \
  -o type=tar,dest=- . > image.tar
