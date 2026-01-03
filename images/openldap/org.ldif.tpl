dn: @@BASE_DN@@
objectclass: dcObject
objectclass: organization
o: @@LDAP_ORGANISATION@@
dc: @@BASE_DC@@

dn: cn=admin,@@BASE_DN@@
objectclass: organizationalRole
cn: admin
description: LDAP Administrator

dn: ou=people,@@BASE_DN@@
objectClass: organizationalUnit
ou: people

dn: ou=groups,@@BASE_DN@@
objectClass: organizationalUnit
ou: groups

dn: ou=computers,@@BASE_DN@@
objectClass: organizationalUnit
ou: computers

dn: ou=idmap,@@BASE_DN@@
objectClass: organizationalUnit
ou: idmap

dn: uid=root,ou=people,@@BASE_DN@@
objectClass: top
objectClass: person
objectClass: posixAccount
objectClass: shadowAccount
objectClass: inetOrgPerson
homeDirectory: /root
loginShell: /bin/bash
uid: root
uidNumber: 0
gidNumber: 0
cn: root
sn: Root
givenName: Root
gecos: Root
displayName: Root
userPassword: @@ADMIN_PASSWORD_HASH@@

dn: cn=root,ou=groups,@@BASE_DN@@
objectClass: top
objectClass: posixGroup
objectClass: extensibleObject
gidNumber: 0
description: Root Group
cn: root
memberUid: root
member: uid=root,ou=people,@@BASE_DN@@

dn: uid=nas,ou=people,@@BASE_DN@@
objectClass: top
objectClass: person
objectClass: shadowAccount
objectClass: inetOrgPerson
objectClass: posixAccount
uid: nas
cn: nas
sn: NAS
givenName: NAS
gecos: NAS
displayName: NAS
description: Network Attached Storage
uidNumber: @@NAS_UID@@
gidNumber: @@NAS_GID@@
homeDirectory: /home/nas
loginShell: /sbin/nologin
userPassword: @@NAS_PASSWORD_HASH@@

dn: cn=nas,ou=groups,@@BASE_DN@@
objectClass: top
objectClass: posixGroup
objectClass: extensibleObject
cn: nas
gidNumber: @@NAS_GID@@
description: NAS Group
memberUid: nas
member: uid=nas,ou=people,@@BASE_DN@@
