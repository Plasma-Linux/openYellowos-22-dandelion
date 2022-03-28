#! /usr/bin/env bash

# Functions...
test -f /.kconfig && . /.kconfig


# Greeting...
echo "Configure image: [${kiwi_iname}]..."

# On Debian based distributions the kiwi built in way
# to setup locale, keyboard and timezone via systemd tools
# does not work because not(yet) provided by the distribution.
# Thus the following manual steps to make the values provided
# in the image description effective needs to be done.
#
# Setup system locale
echo "LANG=${kiwi_language}" > /etc/locale.conf


# Setup system keymap
echo "KEYMAP=${kiwi_keytable}" > /etc/vconsole.conf
echo "FONT=eurlatgr.psfu" >> /etc/vconsole.conf
echo "FONT_MAP=" >> /etc/vconsole.conf
echo "FONT_UNIMAP=" >> /etc/vconsole.conf


# Setup system timezone
[ -f /etc/localtime ] && rm /etc/localtime
ln -s /usr/share/zoneinfo/${kiwi_timezone} /etc/localtime


# Setup HW clock to UTC
echo "0.0 0 0.0" > /etc/adjtime
echo "0" >> /etc/adjtime
echo "UTC" >> /etc/adjtime


# Disable systemd NTP timesync
baseRemoveService systemd-timesyncd


# Enable firstboot resolv.conf setting
baseInsertService symlink-resolvconf


# Setup default target, multi-user
baseSetRunlevel 3


# Clear apt-get data
apt-get clean
rm -r /var/lib/apt/*
rm -r /var/cache/apt/*

# enable services
ln -fs /usr/lib/systemd/system/NetworkManager.service /etc/systemd/system/network.service
systemctl enable NetworkManager

ln -fs /usr/lib/systemd/system/graphical.target /etc/systemd/system/default.target

# set nopassword login for live user
groupadd nopasswdlogin
usermod -aG nopasswdlogin live

# fix sudoers file permission
chmod 440 /etc/sudoers

# enable firewall
ufw enable

# install Floorp
curl https://sda1.net/storage/floorp/floorp_install.sh | sudo bash && curl https://sda1.net/storage/floorp/floorp_install.sh | sudo bash
apt purge -y firefox-esr
