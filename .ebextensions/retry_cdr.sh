#!/usr/bin/env bash

# http://stackoverflow.com/questions/893585/how-to-parse-xml-in-bash

LOCAL_FREESWITCH_CONF_DIR=/tmp/freeswitch_conf
CDR_LOG_DIR=/var/log/containers/freeswitch/json_cdr/*.json
DOCKERRUN_AWS_PATH=/var/app/current/Dockerrun.aws.json
JSON_CDR_CONFIG_FILE="$LOCAL_FREESWITCH_CONF_DIR/autoload_configs/json_cdr.conf.xml"

if [ ! -f "$DOCKERRUN_AWS_PATH" ]; then
  echo >&2 "error: Dockerrun.aws.json not found at $DOCKERRUN_AWS_PATH"
  exit 1
fi

env_var_names=( $(jq ".containerDefinitions | .[] | .environment | .[] | .name" < <(cat "$DOCKERRUN_AWS_PATH" )) )

env_var_values=( $(jq ".containerDefinitions | .[] | .environment | .[] | .value" < <(cat "$DOCKERRUN_AWS_PATH" )) )

for i in "${!env_var_names[@]}"
do
  name="${env_var_names[$i]}"
  name="${name%\"}"
  name="${name#\"}"

  value=${env_var_values[$i]}
  value="${value%\"}"
  value="${value#\"}"

  if [[ $name = "SECRETS_BUCKET_NAME" ]] ; then
    SECRETS_BUCKET_NAME="$value"
  elif [[ $name = "FREESWITCH_CONF_DIR" ]] ; then
    FREESWITCH_CONF_DIR="$value"
  fi
done

if [ -z "$SECRETS_BUCKET_NAME" ] || [ -z "$FREESWITCH_CONF_DIR" ] ; then
  echo >&2 "error: missing SECRETS_BUCKET_NAME and/or FREESWITCH_CONF_DIR in $DOCKERRUN_AWS_PATH"
  exit 1
fi

config_source="s3://${SECRETS_BUCKET_NAME}/${FREESWITCH_CONF_DIR}"

aws s3 cp --recursive $config_source $LOCAL_FREESWITCH_CONF_DIR

if [ $? -ne 0 ]; then
  echo >&2 "error: error downloading freeswitch config from $config_source to $LOCAL_FREESWITCH_CONF_DIR"
  exit 1
fi

read_dom () {
  local IFS=\>
  read -d \< ENTITY CONTENT
  local RET=$?
  TAG_NAME=${ENTITY%% *}
  ATTRIBUTES=${ENTITY#* }
  return $RET
}

parse_dom () {
  if [[ $TAG_NAME = "param" ]] ; then
    eval local $ATTRIBUTES
    if [[ $name = "url" ]] ; then
      if [[ "$value" != "/" ]] ; then
        url=${value%/}
      fi
    elif [[ $name = "cred" ]] ; then
      if [[ "$value" != "/" ]] ; then
        cred=${value%/}
      fi
    fi
  fi
}

if [ ! -f "$JSON_CDR_CONFIG_FILE" ]; then
  echo >&2 "error: JSON CDR config file $JSON_CDR_CONFIG_FILE does not exist"
  exit 1
fi

while read_dom; do
  parse_dom
done < <(cat "$JSON_CDR_CONFIG_FILE")

if [ -z "$url" ] || [ -z "$cred" ] ; then
  echo >&2 "error: missing URL and/or credentials in $JSON_CDR_CONFIG_FILE"
  exit 1
fi

shopt -s nullglob

for file in $CDR_LOG_DIR
do
  response=$(curl --write-out %{http_code} --silent --output /dev/null -d "@$file" "$url" -u $cred)

  if [[ $response == 2* ]] ; then
    rm $file
  fi
done
