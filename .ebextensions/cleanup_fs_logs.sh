#!/bin/bash
set -xe

# AWS Constants
AWS_ECS_CONTAINER_NAME_KEY="com.amazonaws.ecs.container-name"

# FreeSWITCH Constants. These should match the values in Dockerrun.aws.json
FREESWITCH_CONTAINER_NAME="freeswitch"

freeswitch_container_id=$(docker ps -qf "label=${AWS_ECS_CONTAINER_NAME_KEY}=${FREESWITCH_CONTAINER_NAME}")

docker exec $freeswitch_container_id /bin/bash -c 'rm /var/log/freeswitch/freeswitch.log.*'
