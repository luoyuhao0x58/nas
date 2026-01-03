#! /bin/bash

CADDY_CONFIG=/etc/caddy/Caddyfile
ALLOWED_IPS="${ALLOWED_IPS:-192.168.0.0/16}"
UPSTREAMS="${UPSTREAMS}"
PROTECTED_UPSTREAMS="${PROTECTED_UPSTREAMS}"
TEMP_FILE="/tmp/upstreams.txt"

cd $(dirname $CADDY_CONFIG)

if [ ! -e "$CADDY_CONFIG" ]; then
    IFS=':' read -ra SERVICES <<< "$UPSTREAMS"
    for service in "${SERVICES[@]}"; do
        IFS=',' read -ra ITEM <<< "$service"
        if [ ${#ITEM[@]} -eq 3 ]; then
            name="${ITEM[0]}"
            host="${ITEM[1]}"
            port="${ITEM[2]}"
            printf "\t# $name\n\timport proxy_remote $host $port\n" >> "$TEMP_FILE"
        fi
    done
    
    IFS=':' read -ra SERVICES <<< "$PROTECTED_UPSTREAMS"
    for service in "${SERVICES[@]}"; do
        IFS=',' read -ra ITEM <<< "$service"
        if [ ${#ITEM[@]} -eq 3 ]; then
            name="${ITEM[0]}"
            host="${ITEM[1]}"
            port="${ITEM[2]}"
            printf "\t# $name\n\timport proxy_auth_remote $host $port\n" >> "$TEMP_FILE"
        fi
    done

    REPLACEMENT_TEXT=$(cat "$TEMP_FILE" | sed ':a;N;$!ba;s/\n/\\n/g')
    sed -e "s|@@ALLOWED_IPS@@|${ALLOWED_IPS}|g" \
        -e "s|@@DOMAIN@@|${DOMAIN}|g" \
        -e "s|##UPSTREAMS_CONTENT##|${REPLACEMENT_TEXT}|g" \
        "${CADDY_CONFIG}.tpl" > "$CADDY_CONFIG"
    rm -rf "${CADDY_CONFIG}.tpl" "$TEMP_FILE"

    caddy fmt --overwrite
fi

exec caddy run