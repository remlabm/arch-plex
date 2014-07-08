FROM binhex/arch-base
MAINTAINER binhex

# install application
#####################

# update package databases for arch
RUN pacman -Sy --noconfirm

# run packer to install application
RUN packer -S plexmediaserver --noconfirm

# set env variables for plex
RUN sed -i 's/export PLEX_MEDIA_SERVER_USER=plex/export PLEX_MEDIA_SERVER_USER=nobody/g' /opt/plexmediaserver/start_pms
RUN sed -i 's/export PLEX_MEDIA_SERVER_TMPDIR=\/tmp/export PLEX_MEDIA_SERVER_TMPDIR=\/config\/tmp/g' /opt/plexmediaserver/start_pms
RUN sed -i 's/export PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="${PLEX_MEDIA_SERVER_HOME}\/Library\/Application Support"/export PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="\/config\/Library\/Application Support"/g' /opt/plexmediaserver/start_pms

# force pms to run as foreground task
RUN sed -i 's/Plex\\ Media\\ Server &/Plex\\ Media\\ Server/g' /opt/plexmediaserver/start_pms

# docker settings
#################

# map /config to host defined config path (used to store configuration from app)
VOLUME /config

# map /media to host defined media path (used to read/write to media library)
VOLUME /media

# expose port for http
EXPOSE 32400

# set permissions
#################

# change owner
RUN chown -R nobody:users /opt/plexmediaserver

# set permissions
RUN chmod -R 775 /opt/plexmediaserver

# add conf file
###############

ADD plexmediaserver.conf /etc/supervisor/conf.d/plexmediaserver.conf

# run supervisor
################

# run supervisor
CMD ["supervisord", "-c", "/etc/supervisor.conf", "-n"]