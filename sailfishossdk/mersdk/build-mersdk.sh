#!/bin/sh

set -e

cd "${0%/*}"

if [ ! -f mersdk.tar.xz ]; then
    if [ ! -f mersdk.disk ]; then
        if [ ! -f mersdk.vdi ]; then
            if [ ! -f SailfishOSSDK-linux-64-offline/org.merproject.mersdk/*mersdk.7z ]; then
                if [ ! -f SailfishOSSDK-linux-64-offline.run ]; then
                    curl -o SailfishOSSDK-linux-64-offline.run http://releases.sailfishos.org/sdk/installers/1510/SailfishOSSDK-Beta-1510-Qt5-linux-64-offline.run
                fi

                sha256sum -c <<EOF
04615d6a2113663ff3fec8575d568d6e354774b19e5a778a2a8f285bb50b11a4 *SailfishOSSDK-linux-64-offline.run
EOF

                chmod +x SailfishOSSDK-linux-64-offline.run
                ./SailfishOSSDK-linux-64-offline.run --dump-binary-data -o SailfishOSSDK-linux-64-offline
            fi

            7z x -so SailfishOSSDK-linux-64-offline/org.merproject.mersdk/*mersdk.7z mersdk/mer.vdi > mersdk.vdi
        fi
        sha256sum -c <<EOF
a16067e507c993b1e1c0eeb0d0b5e5962bb6971965ec1dcfabcb4043b78f3342 *mersdk.vdi
EOF

        # Need to run inside a container to prevent (potential) conflicts when the SDK is already installed on the local system
        TMPCFGDIR=`mktemp -d`
        docker run --rm -v "`pwd`:/mersdk:rw" -v "${TMPCFGDIR}:/.config:rw" -u "${UID:-"$(id -u)"}:${GID:-"$(id -g)"}" --entrypoint=/usr/bin/VBoxManage jess/virtualbox clonehd /mersdk/mersdk.vdi /mersdk/mersdk.disk --format RAW
        rm -rf "${TMPCFGDIR}"
    fi

    sha256sum -c <<EOF
f0de4d49909747b2daf2670c36d6f73b853484156a698f9f4367351b3df82bec *mersdk.disk
EOF

    MOUNTPOINT=`mktemp -d`
    cleanup() {
        rmdir "${MOUNTPOINT}"
    }
    trap cleanup 0 INT TERM QUIT

    sudo unshare -m -- sh -c "mount --no-mtab -t ext4 -o ro,loop,offset=512,sizelimit=4294966784 mersdk.disk ${MOUNTPOINT} && exec tar -C "${MOUNTPOINT}" -c --xattrs ." | xz --best > mersdk.tar.xz
fi

docker build --force-rm -t muggenhor/mersdk:2015.10.01-1 .
docker tag -f muggenhor/mersdk:2015.10.01-1 muggenhor/mersdk:latest
