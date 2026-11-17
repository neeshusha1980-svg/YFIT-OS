# Installation and live use

## Write and boot the ISO

After a release is built, verify its SHA256 before writing it to removable media. Writing an ISO to a block device erases that device; identify the USB device carefully and follow the host distribution's documented image-writing procedure. Do not run a device-writing command until the target drive has been positively identified.

The live environment is non-persistent by default. Debian live-boot supports persistence when the user creates a separate persistence volume labeled `persistence` with a valid `persistence.conf` and adds the `persistence` boot option. This is opt-in and persistence is not encrypted unless the volume is separately configured with LUKS.

The temporary live account is `yfit`; its random boot password is available to that account at `/run/yfit-live-admin-password`. This supports sudo/Polkit prompts during the live session without embedding a shared password in the ISO. The file resides in `/run` and disappears on reboot.

## Install to disk

From the live desktop, launch **Install Yfit OS** or select the Debian Installer live entry from the GRUB menu. Calamares presents the actual detected disks and partitioning choices. Read every device name and size. Choosing an erase-disk layout destroys data on the selected drive; back up important data first. Manual partitioning is available through Calamares. For UEFI, use an EFI System Partition and install GRUB to the intended system disk. The installer creates the target account/password and requests locale, keyboard, and timezone details.

The default image configuration does not set an automatic disk layout or embed credentials. Any installer failure should leave the source disk untouched until the user explicitly confirms a partitioning operation; this behavior must be verified in the installer VM before release.

## After installation

Install updates using the Debian package manager or the XFCE update tools available from the system. APT sources are Debian Trixie and its security repository. AppArmor, UFW, and unattended security updates are configured in the installed system. Review firewall needs before opening incoming ports.

## Secure Boot

Secure Boot signing/MOK enrollment is not configured or verified. Disable Secure Boot before booting this build. A future signed release needs a documented key ownership, signing, enrollment, revocation, and update process.
