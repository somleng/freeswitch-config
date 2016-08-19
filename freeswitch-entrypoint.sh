#!/bin/bash

# Check that the environment variable has been set correctly
if [ -z "$SECRETS_BUCKET_NAME" ]; then
  echo >&2 'error: missing SECRETS_BUCKET_NAME environment variable'
  exit 1
fi

# Load the S3 secrets file contents into the environment variables
eval $(aws s3 cp s3://${SECRETS_BUCKET_NAME}/${SECRETS_FILE_NAME} /etc/freeswitch/secrets.xml)
chmod 400 /etc/freeswitch/secrets.xml
chown freeswitch:daemon /etc/freeswitch/secrets.xml

exec "$@"
