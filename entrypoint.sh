#!/bin/bash
set -ex

RUN_FLUXBOX=${RUN_FLUXBOX:-yes}
RUN_XTERM=${RUN_XTERM:-yes}

case $RUN_FLUXBOX in
  false|no|n|0)
    rm -f /app/conf.d/fluxbox.conf
    ;;
esac

case $RUN_XTERM in
  false|no|n|0)
    rm -f /app/conf.d/xterm.conf
    ;;
esac

adduser root pulse-access
rm -rf /var/run/pulse /var/lib/pulse /root/.config/pulse
pulseaudio -D --verbose --exit-idle-time=-1 --system --disallow-exit
pactl load-module module-null-sink sink_name=MySink
pactl set-default-sink MySink

exec supervisord -c /app/supervisord.conf
