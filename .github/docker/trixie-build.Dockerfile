FROM --platform=linux/amd64 debian:trixie-slim

ARG YFIT_DEBIAN_SNAPSHOT=20261101T000000Z

RUN set -eux; \
    test -f /usr/share/keyrings/debian-archive-keyring.gpg; \
    rm -f /etc/apt/sources.list /etc/apt/sources.list.d/debian.sources; \
    printf 'deb [check-valid-until=no signed-by=/usr/share/keyrings/debian-archive-keyring.gpg] https://snapshot.debian.org/archive/debian/%s trixie main\n' \
      "$YFIT_DEBIAN_SNAPSHOT" > /etc/apt/sources.list.d/yfit-build-tools.list; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      debian-archive-keyring live-build debootstrap xorriso squashfs-tools \
      grub-common grub-pc-bin grub-efi-amd64-bin mtools dosfstools file rsync dpkg-dev; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    for tool in lb debootstrap xorriso mksquashfs grub-mkstandalone file sha256sum dpkg-query; do \
      command -v "$tool" >/dev/null 2>&1 || { echo "Missing build tool: $tool" >&2; exit 1; }; \
    done; \
    dpkg --print-architecture | grep -qx amd64

WORKDIR /workspace
