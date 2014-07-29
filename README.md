# freeswitch-config (Production)

Freeswitch configuration files for Chibi in production

## Version Control

Make sure you're on the production branch

```
sudo -u freeswitch git checkout master
```

The master branch contains the configuration necessary for the production FreeSwitch server.

## IP addresses

### FreeSwitch Production Server

#### External IP

54.251.107.233

#### Natted SIP IP

54.251.107.12

### Smart

#### External IP (VPN)

27.109.115.201

#### Public MSC IP

27.109.112.80

#### Natted SIP IP's (No longer used)

27.109.112.12, 27.109.112.13, 27.109.112.14

### qb

#### Public MSC IP

117.55.252.146

### CooTel

#### Public MSC IP

103.5.126.165

## Firewall

For more information read [the Amazon EC2 Freeswitch Wiki](http://wiki.freeswitch.org/wiki/Amazon_ec2)

Open up the following ports:

    udp     16384:32768
    udp     4569
    udp     5060
    tcp     5060
    udp     5080
    tcp     5080
    tcp     8000
    udp     8000

## Reload SIP Profiles

    sofia profile [internal|external] [rescan|reload]

## Install a module

Uncomment the desired module in `path/to/freeswitch/source/modules.conf`

    cd /path/to/freeswitch/source
    sudo mod_<name>-install

## Required modules

* mod_flite (for TTS)
* mod_shout (for mp3 playback)
* mod_http_cache (for caching mp3 playback)
* mod_com_g729 (required Codec for CooTel)

### Required Licences

mod_com_g729 requires one licence per channel. We have currently purchased 5 licences which should allow 5 simultanious calls using G.729.
Read the [G.729 codec guide](http://wiki.freeswitch.org/wiki/Mod_com_g729) for details on how to purchase additional licences. Note that each licence costs $10.

### Installation

    cd /path/to/freeswitch/source
    sudo mod_flite-install && sudo mod_shout-install && sudo mod_shout-install
