#!/bin/sh -eu
rm -rf .depscache
mkdir .depscache
rsync -r --exclude=.depscache . .depscache
pushd .depscache
find . -type f ! -wholename '*mix.*' -a -type f ! -wholename "*config/*" -delete
find . -type d -empty -delete
popd
DOCKER_BUILDKIT=1 docker build .
