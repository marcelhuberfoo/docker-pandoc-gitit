#!/bin/sh

cabal_image=marcelhuberfoo/cabal-build
cache_file=./.versions.

if [ ! -r "$cache_file" -o "${1}x" = "fx" ]; then
  docker run -ti --rm $cabal_image bash -l -c 'pacman -Syy --noconfirm git >/dev/null 2>&1 && git clone --single-branch -b master https://github.com/jgm/gitit >/dev/null 2>&1 && cd gitit && echo "$(cabal update >/dev/null 2>&1 && cabal list --simple-output pandoc | grep -E "^pandoc\s" | tail -1 | cut -d" " -f2)_$(git describe --abbrev=0 --tags)-$(git rev-list --count $(git describe --abbrev=0 --tags)..)-g$(git log -1 --format=%h)"' >$cache_file 2>./ver_errs
fi

cat $cache_file;
