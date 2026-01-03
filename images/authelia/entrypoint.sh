#! /bin/bash


CONFIG_DIR=/etc/authelia/config
SECRET_DIR=/etc/authelia/secrets

X_AUTHELIA_CONFIG=$CONFIG_DIR/configuration.yml
X_AUTHELIA_OIDC_CLIENTS_CONFIG_FILE=$CONFIG_DIR/oidc_clients.yml

X_AUTHELIA_JWT_SECRET_FILE=$SECRET_DIR/jwt.secret
X_AUTHELIA_SESSION_SECRET_FILE=$SECRET_DIR/session.secret
X_AUTHELIA_STORAGE_KEY_FILE=$SECRET_DIR/storage.key
X_AUTHELIA_OIDC_JWK_KEY_FILE=$SECRET_DIR/oidc/jwks/nas/private.pem

if [ -e "/etc/authelia/configuration.yml.tpl" ]; then
    mkdir -p $(dirname $X_AUTHELIA_CONFIG)
    BASE_DN=$(echo "${LDAP_DOMAIN}" | awk -F. '{for(i=1;i<=NF;i++) printf "dc=%s%s", $i, (i==NF?"":",")}')
    sed -e "s/@@BASE_DN@@/${BASE_DN}/g" \
        -e "s|@@LDAP_URI@@|${LDAP_URI}|g" \
        -e "s|@@DOMAIN@@|${LDAP_DOMAIN}|g" \
        -e "s|@@LDAP_ADMIN_PASSWORD@@|${LDAP_ADMIN_PASSWORD}|g" \
        "/etc/authelia/configuration.yml.tpl" > "$X_AUTHELIA_CONFIG"
    rm -rf /etc/authelia/configuration.yml.tpl
    mkdir -p /var/run/authelia
fi
if [ ! -e "$X_AUTHELIA_OIDC_CLIENTS_CONFIG_FILE" ]; then
    mkdir -p $(dirname $X_AUTHELIA_OIDC_CLIENTS_CONFIG_FILE)
    mv /etc/authelia/oidc_clients.yml.example $X_AUTHELIA_OIDC_CLIENTS_CONFIG_FILE
fi

if [ ! -e "$X_AUTHELIA_JWT_SECRET_FILE" ]; then
    mkdir -p $(dirname $X_AUTHELIA_JWT_SECRET_FILE)
    authelia crypto rand --charset alphanumeric --file "$X_AUTHELIA_JWT_SECRET_FILE"
fi
if [ ! -e "$X_AUTHELIA_SESSION_SECRET_FILE" ]; then
    mkdir -p $(dirname $X_AUTHELIA_SESSION_SECRET_FILE)
    authelia crypto rand --charset alphanumeric --file "$X_AUTHELIA_SESSION_SECRET_FILE"
fi
if [ ! -e "$X_AUTHELIA_STORAGE_KEY_FILE" ]; then
    mkdir -p $(dirname $X_AUTHELIA_STORAGE_KEY_FILE)
    authelia crypto rand --charset alphanumeric --file "$X_AUTHELIA_STORAGE_KEY_FILE"
fi
if [ ! -e "$X_AUTHELIA_OIDC_JWK_KEY_FILE" ]; then
    mkdir -p $(dirname $X_AUTHELIA_OIDC_JWK_KEY_FILE)
    cd $(dirname $X_AUTHELIA_OIDC_JWK_KEY_FILE)
    authelia crypto certificate rsa generate --signature SHA256
    cd -
fi

cd /var/run/authelia
exec authelia --config "$X_AUTHELIA_CONFIG" --config.experimental.filters template