FROM --platform=linux/amd64 debian:trixie-slim

ARG YFIT_DEBIAN_SNAPSHOT

RUN set -eux; \
    snapshot="${YFIT_DEBIAN_SNAPSHOT:-$(date -u +%Y%m%dT000000Z)}"; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates debian-archive-keyring; \
    update-ca-certificates; \
    rm -f /etc/apt/sources.list /etc/apt/sources.list.d/debian.sources; \
    printf 'deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg] https://snapshot.debian.org/archive/debian/%s trixie main\n' \
      "$snapshot" > /etc/apt/sources.list.d/yfit-build-tools.list; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      live-build debootstrap xorriso squashfs-tools grub-common grub-pc-bin \
      grub-efi-amd64-bin mtools dosfstools file rsync dpkg-dev; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    for tool in lb debootstrap xorriso mksquashfs grub-mkstandalone file sha256sum dpkg-query; do \
      command -v "$tool" >/dev/null 2>&1 || { echo "Missing build tool: $tool" >&2; exit 1; }; \
    done; \
    dpkg --print-architecture | grep -qx amd64

WORKDIR /workspace
