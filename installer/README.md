# Installer configuration

The project packages Debian Trixie's `calamares` and `calamares-settings-debian`, then overrides `/etc/calamares/settings.conf` to use the Yfit branding directory and require an explicit confirmation before the install execution phase. Debian's module sequence provides actual disk selection/partitioning, mount and filesystem creation, unpacking the live system, account creation, locale/keyboard, LightDM, and GRUB work. The Yfit desktop launcher invokes Debian's packaged `calamares-install-debian` wrapper.

The ISO also enables Debian Installer's live menu in GRUB as an alternate real installer. No custom partition writer or fake progress UI is included.

Before release, inspect the target device name and partition plan in a disposable QEMU disk, test cancellation and failure handling, then boot the installed virtual disk with the ISO detached. Do not claim installer completion until this test passes. Calamares settings source and module defaults are inherited from the Debian Trixie package at the pinned snapshot date.
