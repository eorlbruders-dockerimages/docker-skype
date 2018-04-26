#!/usr/bin/env bash

set -x

USER_UID=$(id -u)

docker run -t -i --rm \
  	--volume=/run/user/${USER_UID}/pulse:/run/user/1000/pulse:ro \
	-e PULSE_SERVER=unix:/run/user/1000/pulse/native \
	-v $HOME/.config/pulse/cookie:$HOME/.config/pulse/cookie:ro \
  	-v /etc/localtime:/etc/localtime:ro \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-v $HOME/.Skype:/home/skype/.Skype \
	-e "DISPLAY=unix${DISPLAY}" \
	--device /dev/video0 \
	-v /dev/video0:/dev/video0 \
	--name skype \
	skype 
