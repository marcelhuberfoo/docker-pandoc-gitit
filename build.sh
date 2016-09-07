#!/bin/sh

. ./build_params.sh

count=0
while [ true ]; do echo "[${count}min]"; count=$(($count+1)); sleep 60; done&
min_pid=$!

pd_ver=$(./$ver_file f| cut -d"_" -f1)
gi_ver=$(./$ver_file | cut -d"_" -f2)

docker build \
  --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
  --build-arg VCS_REF=$(git rev-parse --short HEAD) \
  --build-arg PANDOC_VERSION=$pd_ver \
  --build-arg GITIT_VERSION=$gi_ver \
  --tag=$docker_image --file=$docker_file $docker_context

ret_code=$?
kill $min_pid
exit $ret_code

