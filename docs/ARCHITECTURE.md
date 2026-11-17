# Architecture

Yfit OS is a Debian live-build image configuration, not a custom kernel fork. Debian supplies the Linux kernel, systemd, APT, GRUB, XFCE, LightDM, NetworkManager, UDisks/GVfs, PipeWire, firmware, and applications. `auto/config` pins the bootstrap/chroot package indexes to a Debian Snapshot timestamp while configuring the final live system's APT sources for current Debian updates.

## Build tree

- `auto/config`, `auto/build`: live-build automation entry points.
- `config/package-lists`: explicit desktop, hardware, installer, and security package selection.
- `config/includes.chroot`: filesystem configuration copied into the live and installed system, including LightDM/XFCE defaults, theme/font/icon assets, Calamares overrides, system services, and the ephemeral live credential hook.
- `config/bootloaders/grub-pc`: GRUB ISO menu template, used by live-build for BIOS and EFI menu construction.
- `config/hooks/normal`: chroot-stage setup after packages are installed (Plymouth initramfs, graphical target, and service enablement).
- `branding`: original Yfit SVG mark/wallpaper, generated Plymouth PNG and renderer, licensed Lucide SVG files, and Fredoka font source/license.
- `installer`: installer-specific policy and test notes.
- `scripts`, `tests`: build, ISO verification, static checks, and isolated VM launch workflows.
- `output`: genuine build products and evidence only; empty until a successful build.

## Boot and session

The ISO is configured as `iso-hybrid` for AMD64 with `grub-pc` BIOS and `grub-efi` UEFI boot paths. The live kernel uses Debian `live-boot` and `live-config`, starts systemd, creates an unprivileged `yfit` user, and launches XFCE through LightDM. The account password is random per boot and held in the RAM-backed `/run/yfit-live-admin-password` for the live account to use with administrative prompts; it is not embedded in the ISO. Installed users and passwords are created by Calamares.

XFCE remains responsible for window management, settings, panels, and session/power actions. Plank supplies a dock and Picom supplies XRender shadows/fades. XFCE's compositor is disabled in the provided session settings to avoid running two compositors. Adwaita is the neutral icon fallback, and the Yfit theme adds a small set of Lucide-compatible assets.

## Installer

Calamares and Debian's Trixie `calamares-settings-debian` package provide the real partitioning, filesystem, account, locale, display-manager, package, and bootloader workflows. Yfit overrides Calamares branding and enables a pre-install confirmation prompt. The ISO also enables Debian Installer's live installation menu. Neither path has been executed yet; both remain release blockers until tested on disposable virtual disks.

## Security baseline

The live user is non-root and receives a fresh password at boot. The installer makes the daily user and password. AppArmor is enabled through kernel parameters and service configuration. UFW defaults to deny incoming and allow outgoing traffic. Debian security sources plus unattended-upgrades are configured. No Secure Boot signing keys are supplied; Secure Boot is not claimed to work.

## Compatibility boundary

The image targets PC-compatible AMD64 only. Firmware packages improve compatibility for common network/audio/graphics devices but are not universal. Driver/firmware availability, ACPI implementation, graphics, suspend, external displays, printers, and wireless behavior require per-device testing.

The installed settings applications are XFCE Settings for display, keyboard, mouse, appearance, workspaces, and power; NetworkManager/Blueman for network and Bluetooth; pavucontrol plus the XFCE audio panel plugin for sound; GNOME Disks/Thunar for storage; MATE User Manager for local accounts; Synaptic for package install/removal; and UFW/Gufw for the firewall. Time synchronization uses systemd-timesyncd; timezone can be set in Calamares and managed after installation with `timedatectl`.
