#!/bin/bash
set -Eeuo pipefail
ROOT=$(cd -- "$(dirname -- "$0")/.." && pwd)
ISO=${1:-$ROOT/output/yfit-os-amd64.iso}
DISK=${YFIT_TEST_DISK:-$ROOT/output/installer-test.qcow2}
[[ -s $ISO ]] || { echo "Build the ISO first: $ISO" >&2; exit 1; }
for tool in qemu-system-x86_64 qemu-img; do command -v "$tool" >/dev/null || { echo "Install $tool to run installer VM tests." >&2; exit 1; }; done
[[ ! -e $DISK ]] || { echo "Refusing to overwrite existing VM test disk: $DISK" >&2; exit 1; }
mkdir -p "$(dirname "$DISK")"
qemu-img create -f qcow2 "$DISK" 40G
if [[ -r /usr/share/OVMF/OVMF_CODE.fd ]]; then
  cp /usr/share/OVMF/OVMF_VARS.fd "${DISK}.vars.fd"
  exec qemu-system-x86_64 -machine q35,accel=kvm:tcg -m 4096 -smp 2 -cdrom "$ISO" -boot d -drive file="$DISK",format=qcow2,if=virtio -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.fd -drive if=pflash,format=raw,file="${DISK}.vars.fd" -nic user,model=virtio-net-pci -device virtio-vga -display gtk
else
  exec qemu-system-x86_64 -machine q35,accel=kvm:tcg -m 4096 -smp 2 -cdrom "$ISO" -boot d -drive file="$DISK",format=qcow2,if=virtio -nic user,model=virtio-net-pci -device virtio-vga -display gtk
fi
