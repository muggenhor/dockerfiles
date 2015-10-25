#!/bin/sh

set -e

: "${UID:="$(id -u)"}" "${GID:="$(id -g)"}"

if [ ! -d /home/deploy/installroot ]; then
    gosu root sed -i "s/^\\(mersdk:x\\|nemo:x\\)\\(:[0-9]\\+\\)\\?:100000:/\\1:${UID}:${GID}:/" \
        /etc/group \
        /etc/passwd \
        /srv/mer/targets/SailfishOS-*/etc/passwd \
        /srv/mer/targets/SailfishOS-*/etc/group
    gosu root mkdir -p /home/deploy/installroot
    gosu root chown -h -R "${UID}:${GID}" /home/deploy/installroot /srv/mer/targets/*
    gosu root find /home/mersdk -path /home/mersdk/share -prune -o -print0 | gosu root xargs -0 chown -h "${UID}:${GID}"
fi

if [ $# -eq 0 ]; then
    exec gosu root /usr/sbin/sshd -D -e -f /etc/ssh/sshd_config_engine
else
    exec gosu mersdk "$@"
fi
