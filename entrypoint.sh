#!/bin/sh
set -e
umask 002
export PATH=/$UNAME/.cabal/bin:$PATH

if [ "$1" = 'gitit' ]; then
  if [ ! -f /data/gitit.conf ]; then
    gosu $UNAME gitit --print-default-config > /data/gitit.conf
  fi
  exec gosu $UNAME "$@"
elif [ "$1" = 'pandoc' ]; then
  exec gosu $UNAME "$@"
fi

exec "$@"
