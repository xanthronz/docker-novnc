FROM ubuntu:latest
ENV DEBIAN_FRONTEND noninteractive
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null
RUN set -ex; \
    apt-get update; \
    apt-get install -y \
      bash \
      fluxbox \
      git \
      net-tools \
      novnc \
      socat \
      supervisor \
      x11vnc \
      xterm \
      xvfb && \
     cd /root && \
    apt-get update -y && \ 
    apt-get install -yqq \
        mplayer \
        screen \
        alsa-base \
        alsa-utils \
        alsa-tools \
        pulseaudio \
        pulseaudio-utils \
        pulseaudio socat \
        ffmpeg \
        python3.8 \
        python3-pip && \ 
    cd /home && \
    git clone https://github.com/rojserbest/VoiceChatPyroBot.git vcbot && \
    apt update && apt -y upgrade && \
    apt-get install -yqq \
        pavucontrol && \
    cd /home/vcbot && \
    pip3 install -U -r requirements.txt && \
    cd /home && \
    wget https://telegram.org/dl/desktop/linux -O tdesktop.tar.xz && tar -xf tdesktop.tar.xz && rm tdesktop.tar.xz && \
    chmod -R 777 /run/screen && \
    rm -rf /var/run/pulse /var/lib/pulse /root/.config/pulse && \
    pulseaudio -D --exit-idle-time=-1 && \
    pulseaudio -D --verbose --exit-idle-time=-1 --system --disallow-exit && \
    pactl load-module module-null-sink sink_name=MySink && \
    pactl set-default-sink MySink && \
    chmod -R 777 /var/run/screen
ENV HOME=/root \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=C.UTF-8 \
    DISPLAY=:0.0 \
    DISPLAY_WIDTH=1024 \
    DISPLAY_HEIGHT=768 \
    RUN_XTERM=yes \
    RUN_FLUXBOX=yes
COPY . /app
COPY createusers.txt /root/
COPY __init__.py /home/vcbot/config/__init__.py
RUN chmod +x /app/conf.d/websockify.sh
CMD ["/app/entrypoint.sh"]
