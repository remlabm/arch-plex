#!/bin/bash

# install pre-reqs
pacman -Sy --noconfirm

# call aur packer script
source /root/packer.sh

# set permissions
chown -R nobody:users /var/lib/plex /etc/conf.d/plexmediaserver /opt/plexmediaserver/ && \
chmod -R 775 /var/lib/plex /etc/conf.d/plexmediaserver /opt/plexmediaserver/ && \

# cleanup
yes|pacman -Scc
rm -rf /usr/share/locale/*
rm -rf /usr/share/man/*
rm -rf /tmp/*
