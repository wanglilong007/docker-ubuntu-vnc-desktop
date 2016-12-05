#!/bin/bash

mkdir -p /var/run/sshd

# create an ubuntu user
# PASS=`pwgen -c -n -1 10`
USER=ubuntu
PASS=ubuntu
GROUPS=adm,sudo
# echo "Username: ubuntu Password: $PASS"
id -u $USER &>/dev/null || useradd --create-home --shell /bin/bash --user-group --groups $GROUPS $USER
echo "$USER:$PASS" | chpasswd
sudo -u $USER -i sh -c "mkdir -p /home/$USER/.config/pcmanfm/LXDE/ \
    && cp /usr/share/doro-lxde-wallpapers/desktop-items-0.conf /home/$USER/.config/pcmanfm/LXDE/"

exec /bin/tini -- /usr/bin/supervisord -n
