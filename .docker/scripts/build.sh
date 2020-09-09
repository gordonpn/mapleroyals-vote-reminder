#!/bin/sh
echo "$DOCKER_TOKEN" | docker login -u gordonpn --password-stdin
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx rm builder || true
docker buildx create --name builder --driver docker-container --use
docker buildx inspect --bootstrap
DOCKER_TAG=${DOCKER_TAG:-latest}
docker buildx build -t gordonpn/mapleroyals-vote-reminder:"$DOCKER_TAG" --platform linux/amd64,linux/arm64 --push .
