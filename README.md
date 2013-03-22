freeswitch-config
=================

Freeswitch configuration files

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

    cd /path/to/freeswitch/source
    sudo mod_flite-install
    sudo mod_shout-install
