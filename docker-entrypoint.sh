#!/bin/bash

set -e

if [ "$1" = 'freeswitch' ]; then
  if [ -z "$SECRETS_BUCKET_NAME" ] || [ -z "$FREESWITCH_CONF_DIR" ] ; then
    echo >&2 'error: missing SECRETS_BUCKET_NAME and/or FREESWITCH_CONF_DIR environment variables'
    exit 1
  fi

  aws s3 cp --recursive s3://${SECRETS_BUCKET_NAME}/${FREESWITCH_CONF_DIR} /etc/freeswitch/
  chown -R freeswitch:daemon /etc/freeswitch

  exec /usr/bin/freeswitch -u freeswitch -g daemon -nonat
fi

exec "$@"
