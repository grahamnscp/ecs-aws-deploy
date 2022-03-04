FROM alpine:latest

EXPOSE 53 53/udp

RUN apk --update upgrade && apk add bind bind-tools bind-plugins

# /etc/bind needs to be owned by root, group owned by "bind", and chmod 750
# since we are mounting, do it manually
# NOTE: Per Dockerfile manual --> need to mkdir the mounted dir to chown
# &
# /var/bind needs to be owned by root, group owned by "bind", and chmod 770
# since we are mounting, do it manually
# NOTE: Per Dockerfile manual --> need to mkdir the mounted dir to chown
# &
# Get latest bind.keys
RUN mkdir -m 0770 -p /etc/bind && chown -R root:named /etc/bind ; \
    mkdir -m 0770 -p /var/cache/bind && chown -R named:named /var/cache/bind ; \
    mkdir -m 0770 -p /var/bind && chown -R named:named /var/bind ; \
    wget -q -O /etc/bind/bind.keys https://ftp.isc.org/isc/bind9/keys/9.11/bind.keys.v9_11 ; \
    rndc-confgen -a

COPY configs/. /etc/bind/
COPY varbind/. /var/bind/

# Mounts
VOLUME ["/etc/bind"]
VOLUME ["/var/bind"]
#VOLUME ["/var/cache/bind"]

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
