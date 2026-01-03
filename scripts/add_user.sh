#! /bin/bash


if [ $# -lt 7 ]; then
  echo "usage: $(basename $0) USER_ID USER_NAME USER_F_NAME USER_G_NAME USER_DISPLAYNAME PHONE MAIL"
  exit 1
fi

get_password() {
  local password1=""
  local password2=""

  while true; do
    read -s -p "Please enter your password: " password1
    echo

    # 检查密码是否为空
    if [ -z "$password1" ]; then
        echo "Error: Password cannot be empty."
        continue
    fi

    read -s -p "Please enter your password again: " password2
    echo

    if [ "$password1" = "$password2" ]; then
        PASS="$password1"
        break
    else
        echo "Error: The two passwords do not match. Please try again."
    fi
  done
}

SCRIPT_FOLDER=$(cd "$(dirname "$0")"; pwd -P)
source "$SCRIPT_FOLDER/../.env"

USER_ID="$1"
USER_NAME="$2"
USER_F_NAME="$3"
USER_G_NAME="$4"
USER_DISPLAYNAME="$5"
USER_PHONE="0086$6"
USER_MAIL="$7"

get_password

TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

PASSWORD_HASH=$(docker compose exec -it openldap slappasswd -s "$PASS")
BASE_DN=$(echo "${DOMAIN}" | awk -F. '{for(i=1;i<=NF;i++) printf "dc=%s%s", $i, (i==NF?"":",")}')

cat << EOF > "$TEMP_FILE"
dn: uid=${USER_NAME},ou=people,${BASE_DN}
objectClass: top
objectClass: person
objectClass: shadowAccount
objectClass: inetOrgPerson
objectClass: posixAccount
uid: ${USER_NAME}
cn: ${USER_NAME}
sn: ${USER_F_NAME}
givenName: ${USER_G_NAME}
uidNumber: ${USER_ID}
gidNumber: ${USER_ID}
employeeNumber: ${USER_ID}
homeDirectory: /home/${USER_NAME}
loginShell: /bin/bash
userPassword: ${PASSWORD_HASH}
displayName: ${USER_DISPLAYNAME}
gecos: ${USER_F_NAME} ${USER_G_NAME}
mobile: ${USER_PHONE}
homePhone: ${USER_PHONE}
telephoneNumber: ${USER_PHONE}
mail: ${USER_MAIL}

dn: cn=${USER_NAME},ou=groups,${BASE_DN}
objectClass: top
objectClass: posixGroup
objectClass: extensibleObject
cn: ${USER_NAME}
gidNumber: ${USER_ID}
description: ${USER_NAME} group
memberUid: ${USER_NAME}
member: uid=${USER_NAME},ou=people,${BASE_DN}
EOF
docker compose cp $TEMP_FILE openldap:/tmp/add_user.ldif
docker compose exec -it openldap ldapadd -x -D "cn=admin,${BASE_DN}" -w "${ADMIN_PASSWD}" -H ldapi:/// -f /tmp/add_user.ldif
docker compose exec -it openldap rm -rf /tmp/add_user.ldif

cat << EOF > "$TEMP_FILE"
printf '%s\n%s\n' "$PASS" "$PASS" | smbpasswd -a -s "$USER_NAME"
EOF
docker compose cp $TEMP_FILE samba:/tmp/add_user.sh
docker compose exec -it samba sh /tmp/add_user.sh
docker compose exec -it samba rm -rf /tmp/add_user.sh


groupadd -g $USER_ID $USER_NAME
useradd -u $USER_ID -g $USER_ID -m $USER_NAME
echo "$USER_NAME:$PASS" | chpasswd