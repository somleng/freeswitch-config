#!/usr/bin/env bash

# AWS Constants
AWS_ECS_CONTAINER_NAME_KEY="com.amazonaws.ecs.container-name"

# AWS Docker Image
AWS_DOCKER_IMAGE="garland/aws-cli-docker"

# FreeSWITCH Constants. These should match the valus in Dockerrun.aws.json
FREESWITCH_CONTAINER_NAME="freeswitch"
CONTAINER_PATH_KEY="org.somleng.freeswitch.recordings.container-path"
S3_PATH_KEY="org.somleng.freeswitch.recordings.s3-path"

freeswitch_container_id=$(docker ps -aqf "label=${AWS_ECS_CONTAINER_NAME_KEY}=${FREESWITCH_CONTAINER_NAME}")

if [[ -z "$freeswitch_container_id" ]]
  local_path=$(docker inspect --format "{{ index .Config.Labels \"${CONTAINER_PATH_KEY}\"}}" $freeswitch_container_id)

  s3_path=$(docker inspect --format "{{ index .Config.Labels \"${S3_PATH_KEY}\"}}" $freeswitch_container_id)

  docker run --volumes-from $freeswitch_container_id:ro $AWS_DOCKER_IMAGE aws s3 sync $local_path $s3_path --sse
fi
