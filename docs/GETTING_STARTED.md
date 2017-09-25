# Getting Started

Follow instructions below to get FreeSWITCH up and running on your local machine.

## Install Docker

Follow the official [Docker documentation](https://docs.docker.com/engine/installation/) to install Docker.

## Pull and run the image

```
$ sudo docker run --rm --name fs-somleng -d -p 5060:5060/udp dwilkie/freeswitch-rayo
```

## Check the container is running

```
$ sudo docker ps -f "name=fs-somleng"
```

## Run fs_cli (optional)

```
$ sudo docker run --rm -it dwilkie/freeswitch-rayo fs_cli -H $(sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(sudo docker ps -qf "name=fs-somleng"))
```
