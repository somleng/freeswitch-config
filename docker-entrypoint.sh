#!/bin/bash

# Local constants
FREESWITCH_CONTAINER_CONFIG_DIRECTORY="/etc/freeswitch/"
FREESWITCH_CONTAINER_STORAGE_DIRECTORY="/var/lib/freeswitch/storage"
FREESWITCH_CONTAINER_RECORDINGS_DIRECTORY="/freeswitch-recordings"
FREESWITCH_CONTAINER_BINARY="/usr/bin/freeswitch"
FREESWITCH_USER="freeswitch"
FREESWITCH_GROUP="daemon"

set -e

if [ "$1" = 'freeswitch' ]; then
  if [ -n "$FREESWITCH_CONFIG_S3_PATH" ]; then
    # Pull FreeSWITCH configuration from S3
    aws s3 cp --recursive ${FREESWITCH_CONFIG_S3_PATH} ${FREESWITCH_CONTAINER_CONFIG_DIRECTORY}
  fi

  # Setup recordings directory
  mkdir -p ${FREESWITCH_CONTAINER_RECORDINGS_DIRECTORY}
  chown -R "${FREESWITCH_USER}:${FREESWITCH_GROUP}" ${FREESWITCH_CONTAINER_RECORDINGS_DIRECTORY}

  # Setup config directory
  chown -R "${FREESWITCH_USER}:${FREESWITCH_GROUP}" ${FREESWITCH_CONTAINER_CONFIG_DIRECTORY}

  # Setup storage directory
  chown -R "${FREESWITCH_USER}:${FREESWITCH_USER}" ${FREESWITCH_CONTAINER_STORAGE_DIRECTORY}

  # execute FreeSWITCH
  exec ${FREESWITCH_CONTAINER_BINARY} -u ${FREESWITCH_USER} -g ${FREESWITCH_GROUP}
fi

exec "$@"
