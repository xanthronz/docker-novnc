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
    useradd -ms /bin/bash vcpb && \
    sed -i 's/^#\s*\(deb.*partner\)$/\1/g' /etc/apt/sources.list && \
    sed -i 's/^#\s*\(deb.*restricted\)$/\1/g' /etc/apt/sources.list && \ 
    apt-get update -y && \ 
    apt-get install -yqq locales  && \ 
    apt-get install -yqq \
        mplayer \
        screen \
        pulseaudio \
        python3.8 \
        python3-pip && \ 
    apt-get install --no-install-recommends -yqq \
        supervisor \
        sudo \
        tzdata \
        nano \
        iptables \
        mc \
        ca-certificates \
        xterm \
        curl \
        wget \
        wmctrl && \
    ln -fs /usr/share/zoneinfo/UTC /etc/localtime && dpkg-reconfigure -f noninteractive tzdata && \
    apt-get -y install \
        git \
        libxfont-dev \
        xserver-xorg-core \
        libx11-dev \
        libxfixes-dev \
        libssl-dev \
        libpam0g-dev \
        libtool \
        libjpeg-dev \
        flex \
        bison \
        gettext \
        autoconf \
        libxml-parser-perl \
        libfuse-dev \
        xsltproc \
        libxrandr-dev \
        python-libxml2 \
        nasm \
        xserver-xorg-dev \
        fuse \
        build-essential \
        pkg-config \
        libpulse-dev m4 intltool dpkg-dev \
        libfdk-aac-dev \
        libopus-dev \
        libmp3lame-dev && \ 
    apt-get update && apt build-dep pulseaudio -y && \
    cd /tmp && apt source pulseaudio && \
    pulsever=$(pulseaudio --version | awk '{print $2}') && cd /tmp/pulseaudio-$pulsever && ./configure  && \
    git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git && cd pulseaudio-module-xrdp && ./bootstrap && ./configure PULSE_DIR="/tmp/pulseaudio-$pulsever" && make && \
    cd /tmp/pulseaudio-$pulsever/pulseaudio-module-xrdp/src/.libs && install -t "/var/lib/xrdp-pulseaudio-installer" -D -m 644 *.so && \
    cd /home && \
    git clone https://github.com/rojserbest/VoiceChatPyroBot.git vcbot && \
    cd /root && \
    apt-mark manual libfdk-aac1 && \
    apt-get -y purge \
        libxfont-dev \
        libx11-dev \
        libxfixes-dev \
        libssl-dev \
        libpam0g-dev \
        libtool \
        libjpeg-dev \
        flex \
        bison \
        gettext \
        autoconf \
        libxml-parser-perl \
        libfuse-dev \
        xsltproc \
        libxrandr-dev \
        python-libxml2 \
        nasm \
        xserver-xorg-dev \
        pkg-config \
        libfdk-aac-dev \
        libopus-dev \
        libmp3lame-dev && \
    apt-get -y autoclean && apt-get -y autoremove && \
    apt-get -y purge $(dpkg --get-selections | grep deinstall | sed s/deinstall//g) && \
    rm -rf /var/lib/apt/lists/*  && \
    apt update && apt -y upgrade && \
    apt-get install -yqq \
        pavucontrol && \
    cd /home/vcbot && \
    pip3 install -U -r requirements.txt && \
    cd /home && \
    wget https://telegram.org/dl/desktop/linux -O tdesktop.tar.xz && tar -xf tdesktop.tar.xz && rm tdesktop.tar.xz && \
    
    chmod -R 777 /run/screen && \
    #useradd −u 8877 vcpb && \
    #adduser vcpb pulse-access && \
    #adduser vcpb audio && \
    #usermod --append --groups audio vcpb && \
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
COPY pulse-client.conf /etc/pulse/client.conf
COPY createusers.txt /root/
COPY __init__.py /home/vcbot/config/__init__.py
RUN chmod +x /app/conf.d/websockify.sh
CMD ["/app/entrypoint.sh"]
