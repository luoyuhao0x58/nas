{
	email {env.ADMIN_EMAIL}
}

(proxy_remote) {
	@{args[0]} host {args[0]}.@@DOMAIN@@
	handle @{args[0]} {
		reverse_proxy {
			to 127.0.0.1:{args[1]}
			header_up X-Scheme "https"
			header_down Content-Security-Policy "script-src 'self' 'unsafe-eval' 'unsafe-inline'"
		}
	}
}

(proxy_auth_remote) {
	@{args[0]} host {args[0]}.@@DOMAIN@@
	handle @{args[0]} {
		forward_auth 127.0.0.1:9091 {
			uri /api/authz/forward-auth
			copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
		}
		reverse_proxy {
			to 127.0.0.1:{args[1]}
			header_up X-Scheme "https"
			header_down Content-Security-Policy "script-src 'self' 'unsafe-eval' 'unsafe-inline'"
		}
	}
}

@@DOMAIN@@, *.@@DOMAIN@@ {
	tls {
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
    }
	encode zstd gzip
	@denied not remote_ip @@ALLOWED_IPS@@
	handle @denied {
		abort
	}

	# authelia
	@auth host auth.@@DOMAIN@@
	handle @auth {
		reverse_proxy 127.0.0.1:9091
	}

##UPSTREAMS_CONTENT##

	handle {
		abort
	}
}