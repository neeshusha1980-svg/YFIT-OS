#!/bin/bash
set -Eeuo pipefail
ROOT=$(cd -- "$(dirname -- "$0")/.." && pwd)
DISK=${YFIT_TEST_DISK:-$ROOT/output/installer-test.qcow2}
[[ -s $DISK ]] || { echo "No installer VM disk exists at $DISK" >&2; exit 1; }
command -v qemu-system-x86_64 >/dev/null || { echo 'Install qemu-system-x86 to boot the installed VM.' >&2; exit 1; }
if [[ -r /usr/share/OVMF/OVMF_CODE.fd && -s ${DISK}.vars.fd ]]; then
  exec qemu-system-x86_64 -machine q35,accel=kvm:tcg -m 4096 -smp 2 -drive file="$DISK",format=qcow2,if=virtio -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.fd -drive if=pflash,format=raw,file="${DISK}.vars.fd" -nic user,model=virtio-net-pci -device virtio-vga -display gtk
fi
exec qemu-system-x86_64 -machine q35,accel=kvm:tcg -m 4096 -smp 2 -drive file="$DISK",format=qcow2,if=virtio -nic user,model=virtio-net-pci -device virtio-vga -display gtk
