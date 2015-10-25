#!/bin/sh

set -e

if [ $# -eq 0 ]; then
    gosu root sed -i "s/^\\(mersdk:x\\|nemo:x\\)\\(:[0-9]\\+\\)\\?:100000:/\\1:${UID:-"$(id -u)"}:${GID:-"$(id -g)"}:/" \
        /etc/group \
        /etc/passwd \
        /srv/mer/targets/SailfishOS-*/etc/passwd \
        /srv/mer/targets/SailfishOS-*/etc/group
    exec gosu root /usr/sbin/sshd -D -e -f /etc/ssh/sshd_config_engine
else
    exec gosu mersdk "$@"
fi
