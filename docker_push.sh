#!/bin/sh

set -e
. ./build_params.sh

docker push $docker_image
docker tag $docker_image $docker_image:$(docker run -it --rm --entrypoint /bin/sh $docker_image -c 'echo -n ${PANDOC_VERSION}_${GITIT_VERSION}')
docker push $docker_image:$(docker run -it --rm --entrypoint /bin/sh $docker_image -c 'echo -n ${PANDOC_VERSION}_${GITIT_VERSION}')

