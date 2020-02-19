# Docker Images
Cron Jobs to build images by using travis-ci.

+ ~~shadowsocks (Python version)~~
+ shadowsocks-libev (C version)
+ Net (V2ray+Random+upx / ss+V2ray-plug)

Travis CI: [![Build Status](https://travis-ci.org/swoiow/ftw-travis-ci.svg?branch=master)](https://travis-ci.org/swoiow/ftw-travis-ci)

# Crontab
```
#0 1 * * * /usr/bin/sh /root/cronTasks/restart.sh
#0 1 * * * /usr/local/bin/vps_updater updater
```
+ ### restart.sh
```
#!/usr/bin/env bash

/usr/bin/docker pull xxx/v2ray
cd /root/xxx && /usr/local/bin/docker-compose down && /usr/local/bin/docker-compose up -d
```
