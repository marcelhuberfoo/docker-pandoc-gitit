#!/bin/sh

set -e
docker_image=marcelhuberfoo/pandoc-gitit
docker_file=Dockerfile
docker_context=.
ver_file=pandoc_gitit_version.sh
docker build --rm \
             --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
             --build-arg VCS_REF=$(git rev-parse --short HEAD) \
             --build-arg PANDOC_VERSION=$(./$ver_file f | cut -d"_" -f1) \
             --build-arg GITIT_VERSION=$(./$ver_file f | cut -d"_" -f2) \
             --tag=$docker_image --file=$docker_file $docker_context

docker tag ${docker_image}:latest ${docker_image}:$(./$ver_file f)

docker push ${docker_image}:$(./$ver_file)
docker push ${docker_image}:latest

