# Installer VM test checklist

1. Build and verify `output/yfit-os-amd64.iso`.
2. Run `tests/run-installer-vm.sh`; verify the QEMU-created disk is the empty qcow2 at `output/installer-test.qcow2` (or `YFIT_TEST_DISK`).
3. In Calamares, check locale/keyboard pages, actual QEMU disk size/model, automatic and manual partition choices, user/password creation, timezone, and summary. Confirm the install confirmation appears before any disk writes.
4. Install to the disposable disk. Capture the Calamares completion screen and install logs. Confirm failure/cancel cases are reported and do not claim success.
5. Close QEMU. Run `tests/boot-installed-vm.sh` with the ISO detached. Verify GRUB, LightDM login, XFCE session, networking, sound, and `sudo` work in the installed guest.
6. Repeat the live boot on a separate QEMU BIOS configuration. For EFI, use OVMF variables and confirm an EFI System Partition and EFI GRUB entry were installed.
7. Save screenshots/logs and report the result in `docs/TEST-REPORT.md`. Do not use a physical disk for these tests.
