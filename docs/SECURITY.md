# Security and provenance

- Base packages are fetched from signed Debian repositories and a fixed Debian Snapshot timestamp during the build. Updating the snapshot is a deliberate security maintenance action and must be followed by a rebuild and retest.
- The live session creates a normal unprivileged `yfit` account. A random password is generated at each boot and only stored in RAM at `/run/yfit-live-admin-password`, readable by the live account for privilege prompts. It is neither embedded in the ISO nor persistent.
- Calamares asks the installer user to create the installed account and password. No user password, private key, or service credential is built into the image.
- AppArmor and UFW are included; UFW policy is deny-incoming/allow-outgoing. Unattended security updates are enabled for Debian security origins.
- The image includes Debian non-free firmware packages under Debian's package licenses. The Fredoka variable font is distributed under SIL OFL 1.1; its license is in `branding/fonts/OFL-Fredoka.txt` and in the installed documentation. Lucide SVG assets are from the Lucide project and are MIT licensed (`branding/lucide/LICENSE`). The Yfit SVG artwork and project configuration are MIT licensed.
- Debian package copyright/provenance remains in the installed `/usr/share/doc/<package>/copyright` files. No third-party repositories or embedded signing keys are configured.
- Secure Boot is not supported by the current unsigned build configuration.
