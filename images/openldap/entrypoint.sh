#!/bin/sh

set -ex
ulimit -n 1024

if [ ! -f "/etc/ldap/slapd.d/cn=config.ldif" ]; then
    echo "Performing first-time setup..."

    ADMIN_PASSWORD_HASH=$(slappasswd -s "${LDAP_ADMIN_PASSWORD}")
    NAS_PASSWORD_HASH=$(slappasswd -s "${NAS_PASSWORD}")
    BASE_DN=$(echo "${LDAP_DOMAIN}" | awk -F. '{for(i=1;i<=NF;i++) printf "dc=%s%s", $i, (i==NF?"":",")}')
    BASE_DC=$(echo "${LDAP_DOMAIN}" | cut -d'.' -f 1)

    sed -e "s/@@BASE_DN@@/${BASE_DN}/g" \
        -e "s|@@ADMIN_PASSWORD_HASH@@|${ADMIN_PASSWORD_HASH}|g" \
        /etc/ldap/slapd.ldif.tpl > /etc/ldap/slapd.ldif

    sed -e "s/@@BASE_DN@@/${BASE_DN}/g" \
        -e "s/@@BASE_DC@@/${BASE_DC}/g" \
        -e "s|@@LDAP_ORGANISATION@@|${LDAP_ORGANISATION}|g" \
        -e "s/@@NAS_UID@@/${NAS_UID}/g" \
        -e "s/@@NAS_GID@@/${NAS_GID}/g" \
        -e "s|@@ADMIN_PASSWORD_HASH@@|${ADMIN_PASSWORD_HASH}|g" \
        -e "s|@@NAS_PASSWORD_HASH@@|${NAS_PASSWORD_HASH}|g" \
        /etc/ldap/org.ldif.tpl > /etc/ldap/org.ldif

    slapadd -n 0 -F /etc/ldap/slapd.d -l /etc/ldap/slapd.ldif

    slapadd -n 1 -l /etc/ldap/org.ldif

    rm /etc/openldap/slapd.ldif*
    rm /etc/openldap/org.ldif*
    rm /etc/openldap/slapd.conf

    echo "Setup complete."
fi

echo "Starting OpenLDAP server..."
exec slapd -h "ldapi:/// ldap:///" -d 1