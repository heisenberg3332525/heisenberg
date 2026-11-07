#!/bin/sh
set -e
PORT="${PORT:-3000}"
: "${UUID:?UUID environment variable is required}"
WS_PATH="${WS_PATH:-/ws}"
mkdir -p /etc/xray /etc/caddy
cat > /etc/xray/config.json <<JSON
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 10000,
      "protocol": "vless",
      "settings": {
        "clients": [ { "id": "${UUID}", "level": 0 } ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": { "path": "${WS_PATH}" }
      }
    }
  ],
  "outbounds": [
    { "protocol": "freedom", "tag": "direct" },
    { "protocol": "blackhole", "tag": "blocked" }
  ],
  "routing": {
    "rules": [
      { "type": "field", "ip": [ "geoip:private" ], "outboundTag": "blocked" }
    ]
  }
}
JSON
cat > /etc/Caddyfile <<CADDY
:${PORT} {
    @ws path ${WS_PATH}
    handle @ws {
        reverse_proxy 127.0.0.1:10000
    }
    handle {
        respond "OK" 200
    }
}
CADDY
/usr/local/bin/xray run -c /etc/xray/config.json &
exec caddy run --config /etc/Caddyfile --adapter caddyfile
