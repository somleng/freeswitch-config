# freeswitch-config

Freeswitch config files for Chibi

## Servers

### Production

freeswitch.chibitxt.me

### Staging

freeswitch-staging.chibitxt.me

## Branches

### master

These are the config files needed on the Production and Staging Servers

### production_testing

This branch contains the config files needed for your develoment machine

## Installation

### Installing Freeswitch

Use the [pre-compiled Debian Package](https://freeswitch.org/confluence/display/FREESWITCH/Debian).

### Installing Required Modules

* mod_shout (required for mp3 playback)
  * `sudo apt-get install freeswitch-mod-shout`
* mod_http_cache (for caching mp3 playback)
  * `sudo apt-get install freeswitch-mod-http-cache`
* mod_com_g729 (required Codec for CooTel)
  * `sudo apt-get install freeswitch-mod-g729`
* mod_rayo (Required for Adhearsion)
  * `sudo apt-get install freeswitch-mod-rayo`

### Required Licences

mod_g729 requires one licence per channel. We have currently purchased 5 licences which should allow 5 simultanious calls using G.729.
Read the [G.729 codec guide](http://wiki.freeswitch.org/wiki/Mod_com_g729) for details on how to purchase additional licences. Note that each licence costs $10.

### Configuration

#### Installing Configuration

```
cd ~
git clone git@github.com:dwilkie/freeswitch-config.git
git checkout <master_or_production_testing>
sudo cp -a freeswitch_config /etc/freeswitch
sudo chown -R freeswitch:freeswitch /etc/production
```

Don't forget to put the correct values in `/etc/freeswitch/secrets.xml`

#### Restart FreeSwitch

```
sudo service freeswitch restart
```

## IP addresses

### Smart

#### Public MSC IP

```
27.109.112.80
```

### qb

#### Public MSC IP

```
117.55.252.146
```

### CooTel

#### Public MSC IP

```
103.5.126.165
```

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

### Useful CLI Commands

### Reload SIP Profiles

```
sofia profile [internal|external] [rescan|reload]
```
