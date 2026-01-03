---
server:
  address: 'tcp://:9091'
  endpoints:
    authz:
      forward-auth:
        implementation: 'ForwardAuth'

log:
  level: 'debug'

identity_validation:
  reset_password:
    jwt_secret: {{ secret "/etc/authelia/secrets/jwt.secret" }}

identity_providers:
  oidc:
    jwks:
      - key_id: 'nas'
        algorithm: 'RS256'
        use: 'sig'
        key:  {{ secret "/etc/authelia/secrets/oidc/jwks/nas/private.pem" | mindent 10 "|" | msquote }}
        certificate_chain: {{ secret "/etc/authelia/secrets/oidc/jwks/nas/public.crt" | mindent 10 "|" | msquote }}
    {{- fileContent "/etc/authelia/config/oidc_clients.yml" | nindent 4 }}

authentication_backend:
  ldap:
    implementation: 'custom'
    address: '@@LDAP_URI@@'
    base_dn: '@@BASE_DN@@'
    additional_users_dn: 'ou=people'
    users_filter: '(&({username_attribute}={input})(objectClass=person))'
    additional_groups_dn: 'ou=groups'
    groups_filter: '(&(member={dn})(objectClass=posixGroup))'
    group_search_mode: 'filter'
    user: 'cn=admin,@@BASE_DN@@'
    password: '@@LDAP_ADMIN_PASSWORD@@'

access_control:
  default_policy: 'deny'
  rules:
    - domain: '*.@@DOMAIN@@'
      policy: 'one_factor'

session:
  secret: {{ secret "/etc/authelia/secrets/session.secret" }}
  cookies:
    - name: 'authelia_session'
      domain: '@@DOMAIN@@'
      authelia_url: 'https://auth.@@DOMAIN@@'
      expiration: '1 hour'
      inactivity: '5 minutes'
      default_redirection_url: 'https://@@DOMAIN@@'

regulation:
  max_retries: 3
  find_time: '2 minutes'
  ban_time: '5 minutes'

storage:
  encryption_key: {{ secret "/etc/authelia/secrets/storage.key" }}
  local:
    path: '/var/run/authelia/authelia.sqlite3'

ntp:
  address: 'udp://ntp.tencent.com:123'

notifier:
  filesystem:
    filename: '/tmp/notification.txt'
...