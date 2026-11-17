# Contributing

1. Keep the Debian base on Trixie and target AMD64 unless the support policy is explicitly changed.
2. Make OS changes through live-build configuration, Debian packages, and inspected source assets. Do not add fake desktop controls or unverified package names.
3. Keep secrets and user credentials out of the image. Installer accounts are chosen by the installer user; the live-session password is generated at boot and is not persisted.
4. Run `tests/static-checks.sh`, build on Debian Trixie AMD64, then run ISO and VM checks described in `BUILD.md`.
5. Update hardware/support docs and release notes with observed evidence. Never infer physical support from a successful VM boot.
6. Include source/license information for bundled assets. Fredoka is OFL; Lucide SVGs are MIT-licensed.

Pull requests should include the live-build log and relevant test report for changes affecting boot, storage, networking, authentication, installer behavior, or kernel/firmware packages.
