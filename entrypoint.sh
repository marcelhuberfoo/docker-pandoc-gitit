#!/bin/sh
set -e
umask 002
export PATH=/home/user/.cabal/bin:$PATH

if [ "$1" = 'gitit' ]; then
  if [ ! -f /data/gitit.conf ]; then
    gosu user gitit --print-default-config > /data/gitit.conf
  fi
  exec gosu user "$@"
elif [ "$1" = 'pandoc' ]; then
  exec gosu user "$@"
fi

exec "$@"
