freeswitch-config
=================

Freeswitch configuration files

## Version Control

Prepend all git commands with `sudo -u freeswitch`

There are 3 branches.

1. development
2. production_testing
3. master

### development

Use this branch on a development machine with FreeSwitch installed locally to test the app.

#### Simulating Calls

##### Incoming

Placing a call to 2442 will simulate an incoming call to Chibi. You'll need to have Vibi and Chibi running locally as well to get this to work.

##### Outgoing

Placing a call to 2444 will simulate an outgoing call to whoever is in `$${test_number}` on your FreeSwitch development box though the external SIP provider. See `passwords.xml` for configuration.

### production_testing

Use this branch is for testing the production FreeSwitch server from your local FreeSwitch development box. It is set up to simulate incoming and outgoing calls over the VPN from an operator. SIP is set up to use an SDP of `27.109.112.25`. This means that you need to set up a NAT rule to change the source address of all packets going out to the production FreeSwitch server like this: `sudo iptables -t nat -A POSTROUTING -d 54.251.107.12/32 -j SNAT --to-source 27.109.112.25`. Persist your IP table rule with `sudo sh -c "iptables-save > /etc/iptables/rules.v4"` and `sudo apt-get install iptables-persistent`.

In addition you also need to make sure the VPN is up between the FreeSwitch production server and your development FreeSwitch box. You'll need to verify the public IP in `/etc/ipsec.conf` *both* on the FreeSwitch production server and on your development box. Then make sure the connection is up by running `sudo ipsec auto --up freeswitch` and `ping 54.251.107.12`

#### Simulating Calls

Sign in to your dev-box FreeSwith as `85510236139@local_ip` using a SIP client such as QuteCom or make a new profile under `directory/default`. The sign-in name is important as it will simulate the caller_id for the calling party.

##### Incoming

Placing a call to 2442 it will bridge to the production FreeSwitch box over the VPN simulating an incoming call from the operator.

##### Outgoing

Placing a call to 2443 will simulate an outgoing call to whoever is in `dialplan/public/00_test_vpn_sip.xml` on the FreeSwitch production server over the VPN.

Placing a call to 2444 will simulate an outgoing call to whoever is in `$${test_number}` on the FreeSwitch production server though the external SIP provider. See `passwords.xml` for configuration.

### master

The master branch contains the configuration necessary for the production FreeSwitch server.

## IP addresses

### FreeSwitch Production Server

#### External IP

54.251.107.233

#### Natted SIP IP

54.251.107.12

### Smart

#### External IP

27.109.115.201

### Natted SIP IP's

27.109.112.12, 27.109.112.13, 27.109.112.14

### Development Box

#### External IP

???

#### Natted SIP IP

27.109.112.25

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

    cd /path/to/freeswitch/source
    sudo mod_flite-install && sudo mod_shout-install && sudo mod_shout-install
