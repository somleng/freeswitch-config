#!/usr/bin/env bash

# AWS Constants
AWS_ECS_CONTAINER_NAME_KEY="com.amazonaws.ecs.container-name"

# AWS Docker Image
AWS_DOCKER_IMAGE="garland/aws-cli-docker"

# FreeSWITCH Constants. These should match the valus in Dockerrun.aws.json
FREESWITCH_CONTAINER_NAME="freeswitch"
S3_PATH_KEY="org.somleng.freeswitch.recordings.s3-path"

# Local Constants
MOUNTED_CONTAINER_PATH="/data/freeswitch-mounted"
SCRATCH_SPACE="/data/scratch_space"

freeswitch_container_id=$(docker ps -aqf "label=${AWS_ECS_CONTAINER_NAME_KEY}=${FREESWITCH_CONTAINER_NAME}")

if [[ -z "$freeswitch_container_id" ]]
  s3_path=$(docker inspect --format "{{ index .Config.Labels \"${S3_PATH_KEY}\"}}" $freeswitch_container_id)

  if [ "$1" = '--all' ]; then
    # sync all volumes

    # get a list of volume names and put into $docker_volumes
    _x=$(docker volume ls --format "{{.Name}}")
    readarray -t docker_volumes <<<"$_x"

    # mount each volume as read only
    printf -v docker_volumes_command -- "-v %s:${MOUNTED_CONTAINER_PATH}/%s:ro " "${docker_volumes[@]}"

    # flatten the files and sync them to s3
    docker run $docker_volumes_command $AWS_DOCKER_IMAGE /bin/sh -c "mkdir -p $SCRATCH_SPACE && find $MOUNTED_CONTAINER_PATH -type f -exec cp {} $SCRATCH_SPACE \; && aws s3 sync ${SCRATCH_SPACE} ${s3_path} --sse"
  else
    # sync the current volume

    docker run --volumes-from $freeswitch_container_id:ro $AWS_DOCKER_IMAGE aws s3 sync $MOUNTED_CONTAINER_PATH $s3_path --sse
  fi
fi
