# syntax=docker/dockerfile:1
# Multi-stage: official xray image has no shell, so copy its binary into Alpine.
FROM ghcr.io/xtls/xray-core:latest AS xray
FROM alpine:3.20
RUN apk add --no-cache ca-certificates caddy
COPY --from=xray /usr/local/bin/xray /usr/local/bin/xray
COPY --from=xray /usr/local/share/xray/geoip.dat /usr/local/share/xray/geoip.dat
COPY --from=xray /usr/local/share/xray/geosite.dat /usr/local/share/xray/geosite.dat
ENV XRAY_LOCATION_ASSET=/usr/local/share/xray
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh /usr/local/bin/xray
EXPOSE 3000
ENTRYPOINT ["/entrypoint.sh"]
