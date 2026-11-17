#!/bin/bash
set -Eeuo pipefail
ROOT=$(cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
fail() { printf 'BUILD ERROR: %s\n' "$*" >&2; exit 1; }

[[ $(dpkg --print-architecture 2>/dev/null || true) == amd64 ]] || fail 'Build host must be native AMD64; Android/ARM and cross builds are not supported.'
[[ $EUID -eq 0 ]] || fail 'Run as root (for example: sudo ./scripts/build-iso.sh).'
for tool in lb xorriso mksquashfs debootstrap grub-mkstandalone file sha256sum dpkg-query df awk tee install; do
  command -v "$tool" >/dev/null 2>&1 || fail "Missing required build tool: $tool (install live-build and its Debian dependencies)."
done
[[ -r /etc/os-release ]] || fail 'Host operating system metadata is unavailable.'
. /etc/os-release
case "${ID:-}:${VERSION_ID:-}:${VERSION_CODENAME:-}" in
  debian:13:trixie|ubuntu:24.04:*) ;;
  *) fail 'Use Debian GNU/Linux 13 Trixie or Ubuntu 24.04 as the native AMD64 build host.' ;;
esac

mem_kib=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)
(( mem_kib >= 7 * 1024 * 1024 )) || fail 'At least 7 GiB RAM is required for this full XFCE image.'
required_space_kib=$((30 * 1024 * 1024))
available_space_kib=$(df -Pk "$ROOT" | awk 'NR == 2 {print $4}')
[[ $available_space_kib =~ ^[0-9]+$ ]] || fail 'Could not determine available build storage; refusing to start live-build.'
printf 'Available build storage: %s GiB\n' "$((available_space_kib / 1024 / 1024))"
printf 'Required build storage: 30 GiB\n'
if (( available_space_kib < required_space_kib )); then
  df -h "$ROOT" >&2 || true
  fail 'At least 30 GiB free storage is required; refusing to start live-build.'
fi

SNAPSHOT=${YFIT_DEBIAN_SNAPSHOT:-20261101T000000Z}
[[ $SNAPSHOT =~ ^[0-9]{8}T[0-9]{6}Z$ ]] || fail 'YFIT_DEBIAN_SNAPSHOT must use YYYYMMDDThhmmssZ.'
SOURCE_DATE_EPOCH=$(date -u -d "${SNAPSHOT:0:8} ${SNAPSHOT:9:2}:${SNAPSHOT:11:2}:${SNAPSHOT:13:2}" +%s)
export SOURCE_DATE_EPOCH YFIT_DEBIAN_SNAPSHOT=$SNAPSHOT
mkdir -p output/logs output/manifests
LOG="output/logs/build-${SNAPSHOT}.log"
exec > >(tee -a "$LOG") 2>&1
printf 'Yfit OS build: Debian Trixie amd64 snapshot %s\n' "$SNAPSHOT"
printf 'Build host: %s (%s)\n' "$(hostname)" "$(uname -srmo)"
printf 'Source date epoch: %s\n' "$SOURCE_DATE_EPOCH"
command -v lb | xargs dpkg-query -S | head -1 || true
lb clean
./auto/config
./auto/build
shopt -s nullglob
images=(binary/*.iso)
(( ${#images[@]} == 1 )) || fail "Expected exactly one generated ISO in binary/, found ${#images[@]}"
install -m 0644 "${images[0]}" output/yfit-os-amd64.iso
file output/yfit-os-amd64.iso | tee output/iso-file.txt
(cd output && sha256sum yfit-os-amd64.iso | tee yfit-os-amd64.iso.sha256)
if [[ -d chroot/var/lib/dpkg ]]; then
  dpkg-query --admindir="$ROOT/chroot/var/lib/dpkg" -W -f='${binary:Package}\t${Version}\n' | LC_ALL=C sort > "output/manifests/packages-${SNAPSHOT}.tsv"
else
  fail 'Build completed without a Debian package database; refusing to emit an incomplete release manifest.'
fi
./tests/verify-iso.sh output/yfit-os-amd64.iso
printf 'Build and structural verification finished. Runtime and installer VM checks remain a separate release gate.\n'
