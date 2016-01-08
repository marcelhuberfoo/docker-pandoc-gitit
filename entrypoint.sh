#!/bin/sh
set -e
umask 002
export PATH=/$UNAME/.cabal/bin:$PATH

if [ "$1" = 'gitit' ]; then
  if [ ! -f /data/gitit.conf ]; then
    gosu $UNAME gitit --print-default-config > /data/gitit.conf
    gosu $UNAME sed -i -e 's|^use-cache:.*$|use-cache: yes|' /data/gitit.conf
    gosu $UNAME sed -i -e 's|^cache-dir:.*$|cache-dir: /tmp|' /data/gitit.conf
    gosu $UNAME sed -i -e 's|^pdf-export:.*$|pdf-export: yes|' /data/gitit.conf
    #gosu $UNAME sed -i -e 's|^debug-mode:.*$|debug-mode: yes|' /data/gitit.conf
    #gosu $UNAME sed -i -e 's|^require-authentication:.*$|require-authentication: none|' /data/gitit.conf
    # run once, by specifying unbindable port 80, to initialize files in /data
    gosu $UNAME gitit -f /data/gitit.conf -p 80 2>/dev/null || true
    # copy over missing files
    gosu $UNAME bash -l -c "for n in \$(find . -type d -path '*data/static'); do cd \$(dirname \$n) && tar cf - static s5 markupHelp markup.* | ( tar xf - -C /data ); done"
  fi
  exec gosu $UNAME "$@"
elif [ "$1" = 'pandoc' ]; then
  exec gosu $UNAME "$@"
fi

exec "$@"
