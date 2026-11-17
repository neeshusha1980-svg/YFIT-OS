#!/bin/bash
set -Eeuo pipefail
ROOT=$(cd -- "$(dirname -- "$0")/.." && pwd)
ISO=${1:-$ROOT/output/yfit-os-amd64.iso}
[[ -s $ISO ]] || { echo "Build the ISO first: $ISO" >&2; exit 1; }
command -v qemu-system-x86_64 >/dev/null || { echo 'Install qemu-system-x86 to run the live VM test.' >&2; exit 1; }
if [[ -r /dev/kvm && -w /dev/kvm ]]; then ACCEL=(-enable-kvm); else ACCEL=(-accel tcg,thread=multi); fi
exec qemu-system-x86_64 "${ACCEL[@]}" -machine q35 -m 4096 -smp 2 -cdrom "$ISO" -boot d -nic user,model=virtio-net-pci -device virtio-vga -display gtk -usb -device usb-tablet
