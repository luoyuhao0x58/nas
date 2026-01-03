#! /bin/sh

NSLCD_CONFIG_FILE=/etc/nslcd.conf
SAMBA_LDAP_CONFIG_FILE=/etc/samba/conf/ldap.conf
SAMBA_SHARES_CONFIG_FILE=/etc/samba/conf/shares.conf

if [ -n "$LDAP_URI" ] && [ -n "$LDAP_DOMAIN" ] && [ -n "$LDAP_ADMIN_PASSWORD" ]; then
  if [ ! -e "$NSLCD_CONFIG_FILE" ]; then
    BASE_DN=$(echo "${LDAP_DOMAIN}" | awk -F. '{for(i=1;i<=NF;i++) printf "dc=%s%s", $i, (i==NF?"":",")}')
    cat << EOF > "$NSLCD_CONFIG_FILE"
uid nslcd
gid nslcd

uri ${LDAP_URI}
base ${BASE_DN}
binddn cn=admin,${BASE_DN}
bindpw ${LDAP_ADMIN_PASSWORD}

tls_cacertfile /etc/ssl/certs/ca-certificates.crt
EOF
    chmod 600 "$NSLCD_CONFIG_FILE"
    sed -i 's/winbind/ldap/g' /etc/nsswitch.conf
  fi
  if [ ! -e "$SAMBA_LDAP_CONFIG_FILE" ]; then
  cat << EOF > "$SAMBA_LDAP_CONFIG_FILE"
passdb backend = ldapsam:"${LDAP_URI}"

ldap suffix = ${BASE_DN}
ldap user suffix = ou=people
ldap group suffix = ou=groups
ldap machine suffix = ou=computers
ldap admin dn = cn=admin,${BASE_DN}
ldap ssl = no
ldap passwd sync = yes
EOF
  fi
  smbpasswd -w "$LDAP_ADMIN_PASSWORD"
fi

if [ ! -e "$SAMBA_SHARES_CONFIG_FILE" ]; then
  mv /etc/samba/shares.conf.example "$SAMBA_SHARES_CONFIG_FILE"
fi

nslcd -d > /dev/stderr &
exec smbd -F --debug-stdout --no-process-group
