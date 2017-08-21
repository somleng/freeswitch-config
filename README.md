# freeswitch-config

[![Build Status](https://travis-ci.org/somleng/freeswitch-config.svg?branch=master)](https://travis-ci.org/somleng/freeswitch-config)

Freeswitch configuration optimized for [mod_rayo](https://freeswitch.org/confluence/display/FREESWITCH/mod_rayo) and [Adhearsion](https://github.com/adhearsion/adhearsion).

## Deployment

See [DEPLOYMENT](https://github.com/somleng/freeswitch-config/tree/master/docs/DEPLOYMENT.md)

## Testing

### SIPp

First install SIPp

```
$ git clone git@github.com:SIPp/sipp.git
$ cd sipp
$ sudo apt-get install libpcap-dev libsctp-dev libgsl-dev
$ ./build.sh
$ sudo make install
```

### sippy_cup

```
$ cd test
$ bundle install --path vendor
```

## License

The software is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
