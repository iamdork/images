#!/bin/bash
if [ -z "$XDEBUG_REMOTE_HOST" ]; then
  >&2 echo "Please provide the \$XDEBUG_REMOTE_HOST environment variable to use cli debugging."
else:
  export XDEBUG_CONFIG="remote_enable=1 remote_mode=req remote_port=9000 remote_host=$XDEBUG_REMOTE_HOST remote_connect_back=0"
  exec "$@"
fi
