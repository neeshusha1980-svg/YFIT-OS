#!/bin/bash
set -Eeuo pipefail
ROOT=$(cd -- "$(dirname -- "$0")/.." && pwd)
ISO=${1:-$ROOT/output/yfit-os-amd64.iso}
[[ -f $ISO && -s $ISO ]] || { echo "No generated ISO found at $ISO" >&2; exit 1; }
for tool in file sha256sum xorriso; do command -v "$tool" >/dev/null || { echo "Missing verification tool: $tool" >&2; exit 1; }; done
file "$ISO" | tee "$ROOT/output/verified-file.txt"
grep -Eiq "ISO 9660" "$ROOT/output/verified-file.txt" || { echo "Generated artifact is not recognized as an ISO 9660 image" >&2; exit 1; }
(cd "$(dirname -- "$ISO")" && sha256sum -c "$(basename -- "$ISO").sha256")
xorriso -indev "$ISO" -report_el_torito as_mkisofs > "$ROOT/output/boot-structure.txt" 2>&1
xorriso -indev "$ISO" -find / -type f -exec lsdl > "$ROOT/output/iso-file-list.txt" 2>&1
grep -Eiq 'filesystem\.squashfs' "$ROOT/output/iso-file-list.txt" || { echo 'ISO lacks the live root filesystem' >&2; exit 1; }
grep -Eiq 'vmlinuz' "$ROOT/output/iso-file-list.txt" || { echo 'ISO lacks a Linux kernel image' >&2; exit 1; }
grep -Eiq 'initrd' "$ROOT/output/iso-file-list.txt" || { echo 'ISO lacks an initramfs' >&2; exit 1; }
grep -Eiq 'efi|uefi' "$ROOT/output/boot-structure.txt" || { echo 'El Torito report has no EFI boot image' >&2; exit 1; }
grep -Eiq 'eltorito|isolinux|syslinux' "$ROOT/output/boot-structure.txt" || { echo 'El Torito report has no BIOS boot image' >&2; exit 1; }
printf 'ISO checksum, live payload, kernel, initramfs, EFI and BIOS boot entries verified.\n'
