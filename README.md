# freeswitch-config

Freeswitch configuration files for Chibi

## Version Control

Prepend all git commands with `sudo -u freeswitch`

There are 3 branches.

1. development
2. production_testing
3. master

### development

Use this branch on a development machine with FreeSwitch installed locally to test the app.

#### Simulating Calls

Sign in to your dev-box FreeSwith as `85510236139@local_ip` using a SIP client such as QuteCom or make a new profile under `directory/default. The sign-in name is important as it will simulate the caller_id for the calling party.

##### Incoming

Placing a call to 2442 will simulate an incoming call to Chibi. You'll need to have Vibi and Chibi running locally as well to get this to work.

##### Outgoing

Placing a call to 2444 will simulate an outgoing call to whoever is in `$${test_number}` on your FreeSwitch development box though the external SIP provider. See `passwords.xml` for configuration.

### production_testing

Use this branch is for testing the production FreeSwitch server from your local FreeSwitch development box. It is set up to simulate incoming and outgoing calls over the VPN from an operator. SIP is set up to use an SDP of `27.109.112.25`. This means that you need to set up a NAT rule to change the source address of all packets going out to the production FreeSwitch server. You also need to setup a NAT rule to change the destination address of all packets with the destination of the SDP back to your local IP address. In addition you need to double check the public IP address of your development machine on *both* the FreeSwitch production server and your local development maching in `/etc/ipsec.conf`. See below for more details.

#### Network Setup

Follow these instructions every time since your local ip address is likely to change.

Todo: Write a script to do this automatically

1. Check your local IP address and note it down. `ifconfig`
2. Check your IP tables. `sudo iptables -t nat -L`
3. Check that your local IP address matches the IP table rule for changing the destination of packets with the destination address `27.109.112.25`
4. Modify the rule if required. `sudo iptables -t nat -D PREROUTING -d 27.109.112.25/32 -j NETMAP --to your_old_local_ip/32` and `sudo iptables -t nat -A PREROUTING -d 27.109.112.25/32 -j NETMAP --to your_new_local_ip/32`
5. Create NAT rule to change source IP for all packets destined for the FreeSwitch production server if required. This should only need to be done once. `sudo iptables -t nat -A POSTROUTING -d 54.251.107.12/32 -j SNAT --to-source 27.109.112.25`
6. Persist your iptables so they exist after reboot. `sudo apt-get install iptables-persistent` and `sudo sh -c "iptables-save > /etc/iptables/rules.v4"`
7. Verify the public IP of your development box in `/etc/ipsec.conf` on *both* the FreeSwitch production server and on your development box.
8. Bring up the VPN connection `sudo /etc/init.d/ipsec restart` and `sudo ipsec auto --up freeswitch`
9. Verify it works by pinging. From the FreeSwitch production server: `ping 27.109.112.25`. From your development box `ping 54.251.107.12`

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

103.5.126.33

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
* mod_com_g729 (required Codec for CooTel)

### Required Licences

mod_com_g729 requires one licence per channel. We have currently purchased 5 licences which should allow 5 simultanious calls using G.729.
Read the [G.729 codec guide](http://wiki.freeswitch.org/wiki/Mod_com_g729) for details on how to purchase additional licences. Note that each licence costs $10.

### Installation

    cd /path/to/freeswitch/source
    sudo mod_flite-install && sudo mod_shout-install && sudo mod_shout-install
