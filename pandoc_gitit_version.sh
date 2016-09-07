#!/bin/sh

cabal_image=marcelhuberfoo/cabal-build
cache_file=./.versions.

if [ ! -r "$cache_file" -o "${1}x" = "fx" ]; then
  pandoc_version=$(docker run -ti --rm $cabal_image bash -l -c 'echo -n "$(cabal update >/dev/null 2>&1 && cabal list --simple-output pandoc | grep -E "^pandoc\s" | tail -1 | cut -d" " -f2)"')
  # gitit from cabal
#  gitit_version=$(docker run -ti --rm $cabal_image bash -l -c 'echo -n "$(cabal update >/dev/null 2>&1 && cabal list --simple-output gitit | grep -E "^gitit\s" | tail -1 | cut -d" " -f2)"')
  # gitit from git
  gitit_version=$(docker run -ti --rm $cabal_image bash -l -c 'pacman -Syy --noconfirm git >/dev/null 2>&1 && git clone --single-branch -b master https://github.com/jgm/gitit >/dev/null 2>&1 && cd gitit && echo -n "$(git describe --abbrev=0 --tags)-$(git rev-list --count $(git describe --abbrev=0 --tags)..)-g$(git log -1 --format=%h)"')
  echo "${pandoc_version}_${gitit_version}" >$cache_file
fi

cat $cache_file;
