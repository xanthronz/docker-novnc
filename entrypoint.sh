#!/bin/bash


#Set Timezone
if [[ -z "${TZ}" ]]; then
   ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime
   dpkg-reconfigure -f noninteractive tzdata
else
   ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime
   dpkg-reconfigure -f noninteractive tzdata
fi

#CREATE USERS.
# username:passsword:Y
# username2:password2:Y

file="/root/createusers.txt"
if [ -f $file ]
  then
    while IFS=: read -r username password is_sudo
        do
            echo "Username: $username, Password: $password , Sudo: $is_sudo"

            if getent passwd $username > /dev/null 2>&1
              then
                echo "User Exists"
              else
                useradd -ms /bin/bash $username
                usermod -aG audio $username
                usermod -aG input $username
                usermod -aG root $username
                usermod -aG video $username
                adduser $username pulse-access
                mkdir -p /run/user/$(id -u $username)/dbus-1/
                chmod -R 700 /run/user/$(id -u $username)/
                chown -R "$username" /run/user/$(id -u $username)/
                chown -R $username:root /home/vcbot
                chown -R $username:root /home
                echo "$username:$password" | chpasswd
                if [ "$is_sudo" = "Y" ]
                  then
                    usermod -aG sudo $username
                fi
            fi
            
    done <"$file"
fi
rm -rf /var/run/pulse /var/lib/pulse /root/.config/pulse
pulseaudio -D --verbose --exit-idle-time=-1 --system --disallow-exit
if [ $UID -eq 0 ]; then
user=$1vcpb #Make change here if you changed username
exec su "$user" "$0" -- "$@"
fi
echo "This will be run from user $UID"
pactl load-module module-null-sink sink_name=MySink #loading MySink
echo "Pulseaudio MySink Loaded"
pactl set-default-sink MySink #setting Mysink as default Mic
echo "MySink Is Now Your Default Mic"
echo "Now Start xrdp and login and join a VoiceChat"
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



exec supervisord -c /app/supervisord.conf
