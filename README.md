# Yfit OS

Yfit OS is a Debian GNU/Linux 13 (Trixie), AMD64 live desktop distribution using XFCE. The repository builds a real hybrid ISO with Debian live-build, includes Debian's live installer infrastructure and Calamares, and configures a Yfit-branded XFCE session.

> **Current state:** the build configuration and source assets are prepared. No ISO has been built or boot-tested yet. This workspace runs Android 17 on ARM64 in Termux and has no Debian live-build toolchain, so it cannot produce or run the AMD64 image. Do not use this as a released OS until a Debian 13 AMD64 build and VM release checks have completed.

## What is included

- Debian 13 Trixie packages, systemd, APT, Linux AMD64 kernel, GRUB BIOS/UEFI boot, and Debian live boot.
- XFCE session, LightDM, Thunar, XFCE Terminal and settings, NetworkManager, UDisks2, GVfs, BlueZ, PipeWire, CUPS, and standard desktop utilities.
- Debian repository firmware packages (`non-free-firmware` included); hardware capability still depends on the actual device and firmware support.
- Yfit color palette, original SVG mark and wallpaper, a vendored Fredoka variable font (OFL), and original Lucide-derived SVG icons (MIT). The icon theme inherits from Adwaita/hicolor; Papirus is not installed.
- Plank, Picom (XRender backend), XFCE panels/workspaces, and the Debian-packaged Calamares installer with Yfit installer branding. The GRUB ISO includes Debian Installer's live install menu as an alternate supported installer path.
- AppArmor, UFW with deny-incoming/allow-outgoing defaults, unattended security updates, and a per-boot random password for the temporary live account.

## Quick start

Use a dedicated Debian 13 Trixie **amd64** machine or a matching CI runner with root/sudo access, at least 7 GiB RAM, 30 GiB free disk, network access to Debian Snapshot and Debian mirrors, and the dependencies listed in [BUILD.md](BUILD.md).

```sh
sudo apt-get update
sudo apt-get install live-build debootstrap xorriso squashfs-tools \
  grub-pc-bin grub-efi-amd64-bin mtools dosfstools file rsync
cd yfit-os
sudo ./scripts/build-iso.sh
./scripts/verify-iso.sh output/yfit-os-amd64.iso
```

The build pins the Debian package inputs to the snapshot timestamp in `auto/config` and sets `SOURCE_DATE_EPOCH` from that timestamp. Update `YFIT_DEBIAN_SNAPSHOT` deliberately to roll the package set forward. The live session's APT sources point to the normal Debian repositories so users can receive current updates after boot/install.

Full setup, QEMU installer checks, and release gating are in [BUILD.md](BUILD.md). Architecture and installer decisions are in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Important limitations

- Secure Boot enrollment/signing is not configured. UEFI boot is intended with Secure Boot disabled; signed firmware and shim behavior must be verified on the target hardware.
- NVIDIA proprietary drivers, fingerprint readers, vendor hotkeys, WWAN, unusual RAID/storage controllers, and printers require model-specific validation. Debian firmware packages do not guarantee support for every device.
- Live persistence is supported by Debian live-boot when a persistence volume is configured by the user; it is not enabled by default. See [docs/INSTALLATION.md](docs/INSTALLATION.md).
- A successful build alone does not establish hardware compatibility. Supported hardware is only what appears in a completed test report.

## Project layout

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the live-build directory mapping and component boundaries.

## GitHub Actions build capacity

The workflow uses the free standard GitHub-hosted `ubuntu-24.04` AMD64 runner and an isolated Debian Trixie build container. It measures actual free workspace disk after safe cleanup and toolchain installation. The 30 GiB minimum remains enforced in both the workflow and build script with no override. If that runner does not provide 30 GiB free, the job stops before live-build and uploads no ISO. No successful ISO build has yet been verified.
