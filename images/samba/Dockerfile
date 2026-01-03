ARG DOCKER_REPO
FROM ${DOCKER_REPO}:base

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
	&& apt-get install -y samba smbclient libnss-ldapd nslcd \
	&& apt-get clean \
	&& rm -rf /etc/nslcd.conf /var/lib/apt/lists/* /tmp/*

ADD ./smb.conf /etc/samba/smb.conf
ADD ./shares.conf /etc/samba/shares.conf.example
COPY --chmod=755 samba.sh /usr/bin/samba

EXPOSE 445/tcp

ENV LDAP_URI 'ldap://127.0.0.1/'
ENV LDAP_DOMAIN ''
ENV LDAP_ADMIN_PASSWORD ''

ENTRYPOINT ["/usr/bin/samba"]
