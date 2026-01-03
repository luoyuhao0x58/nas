ARG DOCKER_REPO
FROM ${DOCKER_REPO}:base

ARG DEBIAN_FRONTEND=noninteractive

# https://wiki.alpinelinux.org/wiki/Configure_OpenLDAP
# https://www.openldap.org/doc/admin26/quickstart.html
RUN apt-get update -y \
	&& apt-get install -y slapd ldap-utils \
	&& mkdir -p /var/run/slapd/ \
	&& chown openldap:openldap /var/run/slapd/ \
	&& rm -rf /etc/ldap/slapd.d/* \
	&& rm -rf /var/lib/ldap/* \
    && rm -rf /tmp/* /var/cache/apk/*

COPY --chmod=444 samba.ldif /etc/ldap/schema/
COPY --chmod=444 samba.schema /etc/ldap/schema/
COPY --chmod=444 slapd.ldif.tpl /etc/ldap/
COPY --chmod=444 org.ldif.tpl /etc/ldap/
COPY --chmod=755 entrypoint.sh /

ENV LDAP_ORGANISATION="NAS"
ENV LDAP_DOMAIN="nas.lan"
ENV LDAP_ADMIN_PASSWORD="admin"
ENV NAS_UID=996
ENV NAS_GID=996
ENV NAS_PASSWORD="nas"

EXPOSE 389 636

ENTRYPOINT ["/entrypoint.sh"]
