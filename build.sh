#!/bin/sh

set -e
docker_image=marcelhuberfoo/pandoc-gitit
docker_file=Dockerfile
docker_context=.
ver_file=pandoc_gitit_version.sh
docker build --rm --tag=${docker_image}:latest --file=$docker_file $docker_context

docker tag ${docker_image}:latest ${docker_image}:$(./$ver_file f)

docker push ${docker_image}:$(./$ver_file)
docker push ${docker_image}:latest

