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
