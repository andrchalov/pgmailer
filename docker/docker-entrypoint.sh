#!/bin/sh

USER_ID=${LOCAL_USER_ID:-9001}
GROUP_ID=${LOCAL_GROUP_ID:-9001}

if [ ! -d "/home/user" ]; then
  addgroup -g $GROUP_ID usergrp
  adduser -s /bin/sh -h /home/user -u $USER_ID -D -G usergrp user
fi

export HOME=/home/user

cd /opt/app
exec su-exec user "$@"
