#!/bin/sh

set -e
imagename=marcelhuberfoo/pandoc-gitit
docker build --rm --tag=${imagename}:latest --file=./Dockerfile . >dockerbuild.out 2>dockerbuild.err

pd_version=$(sed -rn -e 's/Installed pandoc-([0-9.]+)$/\1/p' dockerbuild.out)
gi_version=$(sed -rn -e 's/Installed gitit-([0-9.]+)$/\1/p' dockerbuild.out)

docker tag ${imagename}:latest ${imagename}:${pd_version}_${gi_version}

docker push ${imagename}:${pd_version}_${gi_version}
docker push ${imagename}:latest

