FROM binhex/arch-base:2015010200
MAINTAINER binhex

# additional files
##################

# download packer from aur
ADD https://aur.archlinux.org/packages/pa/packer/packer.tar.gz /tmp/packer.tar.gz

# add supervisor file for application
ADD plexmediaserver.conf /etc/supervisor/conf.d/plexmediaserver.conf

# install app
#############

# install base devel, install app using packer, set perms, cleanup
RUN pacman -Sy --noconfirm && \
	pacman -S --needed base-devel --noconfirm && \
	cd /tmp && \
	tar -xzf packer.tar.gz && \
	cd /tmp/packer && \
	useradd -m -g wheel -s /bin/bash makepkg_user && \
	echo -e "makepkg_password\nmakepkg_password" | passwd makepkg_user && \
	echo "Defaults:makepkg_user      !authenticate" >> /etc/sudoers && \
	su -c "makepkg -s --noconfirm --needed" - makepkg_user && \
	pacman -U /tmp/packer/packer*.tar.xz --noconfirm && \
	su -c "packer -S plex-media-server --noconfirm" - makepkg_user && \
	pacman -Ru base-devel --noconfirm && \
	pacman -Scc --noconfirm && \
	chown -R nobody:users /var/lib/plex /etc/conf.d/plexmediaserver /opt/plexmediaserver/ && \
	chmod -R 775 /var/lib/plex /etc/conf.d/plexmediaserver /opt/plexmediaserver/ && \
	rm -rf /archlinux/usr/share/locale && \
	rm -rf /archlinux/usr/share/man && \
	rm -rf /root/* && \
	rm -rf /tmp/*
	
# add custom environment file for application
ADD plexmediaserver.sh /usr/bin/plexmediaserver.sh
RUN chmod +x /usr/bin/plexmediaserver.sh
	
# docker settings
#################

# map /config to host defined config path (used to store configuration from app)
VOLUME /config

# map /media to host defined media path (used to read/write to media library)
VOLUME /media

# run supervisor
################

# run supervisor
CMD ["supervisord", "-c", "/etc/supervisor.conf", "-n"]