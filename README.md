# freeswitch-config

Freeswitch config files for Chibi

## Servers

### Production

freeswitch.chibitxt.me

### SysAdmin

#### Cron

##### Cleanup Logs

You'll need a cron job to clean up the logs otherwise you'll run out of diskspace.

Copy the [cron job](https://github.com/dwilkie/freeswitch-config/blob/master/cron/freeswitch) to `/etc/cron.daily` and set it's permissions to `755`

## Branches

### master

Contains the config files needed on the Production Server

### production_testing

Contains the config files needed for your develoment machine

## Installation

### Installing Freeswitch

Use the [pre-compiled Debian Package](https://freeswitch.org/confluence/display/FREESWITCH/Debian).

### Installing Required Modules

* mod_shout (required for mp3 playback)
  * `sudo apt-get install freeswitch-mod-shout`
* mod_http_cache (for caching mp3 playback)
  * `sudo apt-get install freeswitch-mod-http-cache`
* mod_rayo (Required for Adhearsion)
  * `sudo apt-get install freeswitch-mod-rayo`
* mod_xml_cdr (Required for posting CDR)
  * `sudo apt-get install freeswitch-mod-xml-cdr`

### Required Licences

mod_g729 requires one licence per channel. We have currently purchased 5 licences which should allow 5 simultanious calls using G.729.
Read the [G.729 codec guide](http://wiki.freeswitch.org/wiki/Mod_com_g729) for details on how to purchase additional licences. Note that each licence costs $10.

#### mod G729

##### Installation

Adapted from the [official installation instructions](http://files.freeswitch.org/g729/INSTALL)

1. cd /src
2. wget http://files.freeswitch.org/g729/fs-latest-installer
3. chmod u+x fs-latest-installer
4. sudo ./fs-latest-installer /usr/bin /usr/lib/freeswitch/mod /etc/freeswitch

### Configuration

#### Installing Configuration

```
cd ~
git clone git@github.com:dwilkie/freeswitch-config.git
git checkout <master_or_production_testing>
sudo cp -a freeswitch_config /etc/freeswitch
sudo chown -R freeswitch:daemon /etc/freeswitch
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
27.109.112.80 (SIP)
27.109.112.84 (RTP)
27.109.112.0/24 (SMARTAXIATA)
```

### qb

#### Public MSC IP

```
117.55.252.146 (SIP & RTP)
117.55.252.0/24 (CADCOMMS)
```

### CooTel

#### Public MSC IP

```
103.5.126.165 (SIP & RTP)
103.5.126.0/24 (XINWEITELECOM-KH)
```

## Firewall

Open up the following ports:

    udp     16384:32768  (RTP)
    udp     5060         (SIP)
    tcp     5222         (XMPP / Adhearsion)

### Useful CLI Commands

### Reload SIP Profiles

```
sofia profile external [rescan|reload]
```
