#!/usr/bin/env bash

# AWS Constants
AWS_ECS_CONTAINER_NAME_KEY="com.amazonaws.ecs.container-name"

# AWS Docker Image
AWS_DOCKER_IMAGE="garland/aws-cli-docker"

# FreeSWITCH Constants. These should match the valus in Dockerrun.aws.json
FREESWITCH_CONTAINER_NAME="freeswitch"
CONTAINER_PATH_KEY="org.somleng.freeswitch.recordings.container-path"
S3_PATH_KEY="org.somleng.freeswitch.recordings.s3-path"

FREESWITCH_CONTAINER_ID=$(docker ps -aqf "label=${AWS_ECS_CONTAINER_NAME_KEY}=${FREESWITCH_CONTAINER_NAME}")

LOCAL_PATH=$(docker inspect --format "{{ index .Config.Labels \"${CONTAINER_PATH_KEY}\"}}" $FREESWITCH_CONTAINER_ID)

S3_PATH=$(docker inspect --format "{{ index .Config.Labels \"${S3_PATH_KEY}\"}}" $FREESWITCH_CONTAINER_ID)

docker run --volumes-from $FREESWITCH_CONTAINER_ID $AWS_DOCKER_IMAGE aws s3 sync $LOCAL_PATH $S3_PATH --sse
