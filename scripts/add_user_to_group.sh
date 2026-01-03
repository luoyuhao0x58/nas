#! /bin/bash


if [ $# -lt 2 ]; then
  echo "usage: $(basename $0) USER_NAME GROUP_NAME"
  exit 1
fi

SCRIPT_FOLDER=$(cd "$(dirname "$0")"; pwd -P)
source "$SCRIPT_FOLDER/../.env"

USER_NAME="$1"
GROUP_NAME="$2"

TEMP_LDIF_FILE=$(mktemp)
trap 'rm -f "$TEMP_LDIF_FILE"' EXIT

BASE_DN=$(echo "${DOMAIN}" | awk -F. '{for(i=1;i<=NF;i++) printf "dc=%s%s", $i, (i==NF?"":",")}')

cat << EOF > "$TEMP_LDIF_FILE"
dn: cn=${GROUP_NAME},ou=groups,${BASE_DN}
changetype: modify
add: memberUid
memberUid: ${USER_NAME}

dn: cn=${GROUP_NAME},ou=groups,${BASE_DN}
changetype: modify
add: member
member: uid=${USER_NAME},ou=people,${BASE_DN}
EOF

cat "$TEMP_LDIF_FILE"

docker compose cp $TEMP_LDIF_FILE openldap:/tmp/add_user_to_group.ldif
docker compose exec -it openldap ldapadd -x -D "cn=admin,${BASE_DN}" -w "${ADMIN_PASSWD}" -H ldapi:/// -f /tmp/add_user_to_group.ldif
docker compose exec -it openldap rm -rf /tmp/add_user_to_group.ldif

usermod -a -G "$GROUP_NAME" "$USER_NAME"