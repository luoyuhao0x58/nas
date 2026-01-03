FROM caddy:2.10.2-builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare

FROM luoyuhao0x58/nas:base

ARG DEBIAN_FRONTEND=noninteractive

COPY --from=builder /usr/bin/caddy /usr/local/bin/
COPY --chmod=444 Caddyfile.tpl /etc/caddy/
COPY --chmod=755 entrypoint.sh /
RUN mkdir -p /root/.local/share/caddy

ENTRYPOINT ["/entrypoint.sh"]