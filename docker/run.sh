#!/bin/sh

XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth

# avoid /tmp/.docker.xauth already exist, please check the path
touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

nvidia-docker run \
        -it --rm \
        --volume=$XSOCK:$XSOCK:rw \
        --volume=$XAUTH:$XAUTH:rw \
        --volume=/home/niise/.autoware:/home/autoware/.autoware:rw \
	--env="XAUTHORITY=${XAUTH}" \
        --env="DISPLAY=${DISPLAY}" \
        -u autoware \
        autoware-image
