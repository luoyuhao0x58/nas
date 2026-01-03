ARG DOCKER_REPO

FROM authelia/authelia:4.39.15 AS builder
FROM ${DOCKER_REPO}:base

ARG DEBIAN_FRONTEND=noninteractive

COPY --from=builder /app/authelia /usr/local/bin/
COPY --chmod=444 configuration.yml.tpl /etc/authelia/
COPY --chmod=444 oidc_clients.yml /etc/authelia/oidc_clients.yml.example
COPY --chmod=755 entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]