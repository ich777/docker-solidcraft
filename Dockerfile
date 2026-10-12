FROM ich777/debian-baseimage

LABEL org.opencontainers.image.authors="admin@minenet.at"
LABEL org.opencontainers.image.source="https://github.com/ich777/docker-solidcraft"

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends unzip fonts-noto-cjk fonts-wqy-microhei ttf-wqy-zenhei fonts-vlgothic fonts-arphic-uming fonts-takao fonts-noto-core fonts-symbola && \
	rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp/static-web-server && \
	SWS_V="$(wget -qO- https://api.github.com/repos/static-web-server/static-web-server/releases/latest | grep tag_name | cut -d '"' -f4)" && \
	wget -O /tmp/static-web-server/static-web-server.tar.gz https://github.com/static-web-server/static-web-server/releases/download/${SWS_V}/static-web-server-${SWS_V}-x86_64-unknown-linux-gnu.tar.gz && \
	tar -C /tmp/static-web-server -xvf /tmp/static-web-server/static-web-server.tar.gz && \
	mkdir -p /usr/share/doc/static-web-server && \
	cp /tmp/static-web-server/static-web-server-*/LICENSE-* /usr/share/doc/static-web-server/ && \
	mv /tmp/static-web-server/static-web-server-*/static-web-server /usr/bin/ && \
	chmod 755 /usr/bin/static-web-server && \
	mkdir -p /opt/icons && \
	wget -O /opt/icons/solidcraft.png https://raw.githubusercontent.com/ich777/mos-templates/master/images/solidcraft.png && \
	rm -rf /tmp/static-web-server

ENV DATA_DIR="/solidcraft"
ENV SOLIDCRAFT_V="latest"
ENV START_PARAMS=""
ENV UMASK=0000
ENV UID=99
ENV GID=100
ENV DATA_PERM=770
ENV USER="solidcraft"

RUN mkdir $DATA_DIR && \
	useradd -d $DATA_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/

EXPOSE 8080

#Webserver Start
ENTRYPOINT ["/opt/scripts/start.sh"]
