# Getting Started

## Install Docker

Follow the official [Docker documentation](https://docs.docker.com/engine/installation/) to install Docker on your local machine.

## Pull and run the image

```
$ sudo docker run -d -p 5222:5222/tcp -p 5060:5060/udp dwilkie/freeswitch-rayo
```

###

### Run fs_cli (optional)

```
$ sudo docker run dwilkie/freeswitch-rayo fs_cli
```
