#!/usr/bin/env bash
set -e

if [ -f /usr/local/etc/php/conf.d/development.ini ]; then
  rm /usr/local/etc/php/conf.d/development.ini
fi

if [ -f /usr/local/etc/php/conf.d/xdebug-remote.ini ]; then
  rm /usr/local/etc/php/conf.d/xdebug-remote.ini
fi

# If development mode is on, install the corresponding configuration files.
if [ "$DEVELOPMENT" = "yes" ]; then
  cp /dork/config/development.ini /usr/local/etc/php/conf.d/development.ini

  if [ -z "$XDEBUG_REMOTE_HOST" ]; then
    echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/xdebug.ini
  else
    echo "xdebug.remote_host=$XDEBUG_REMOTE_HOST" >> /usr/local/etc/php/conf.d/xdebug.ini
  fi
fi

# Wait until the database is available, or abort after 30 seconds.
if [[ -n "$MYSQL_USER" && -n "$MYSQL_PASSWORD" && -n "$MYSQL_HOST" && -n "$MYSQL_PORT" ]]; then
  tries=0
  while ! mysql -u "$MYSQL_USER" --host "$MYSQL_HOST" --port "$MYSQL_PORT" -p"$MYSQL_PASSWORD"  -e ";" ; do
    echo "Could not connect to database. Retrying."
    if [ "$tries" == "30" ]; then
      echo "Tried 30 times, aborting."
      exit 1
    fi
    sleep 3
    tries=$((tries + 1))
  done
fi
