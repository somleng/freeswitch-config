#!/bin/bash

set -e

if [ "$1" = 'freeswitch' ]; then
  if [ -z "$SECRETS_BUCKET_NAME" ]; then
    echo >&2 'error: missing SECRETS_BUCKET_NAME environment variable'
    exit 1
  fi

  eval $(aws s3 cp s3://${SECRETS_BUCKET_NAME}/${SECRETS_FILE_NAME} /etc/freeswitch/secrets.xml)

  chmod 400 /etc/freeswitch/secrets.xml
  chown freeswitch:daemon /etc/freeswitch/secrets.xml

  exec /usr/bin/freeswitch -u freeswitch -g daemon -nonat
fi

exec "$@"
