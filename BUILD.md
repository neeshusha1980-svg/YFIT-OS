# Build and download Yfit OS

Yfit OS is configured as a real Debian GNU/Linux 13 (Trixie) AMD64 live ISO. `auto/config` pins the live-build target to `trixie` and `amd64`. The workflow builds on a GitHub-hosted Ubuntu 24.04 AMD64 VM, using Debian Trixie's pinned `live-build` and `debootstrap` tools. It uploads an artifact only after ISO and boot-structure verification pass.

## Build from an Android phone with GitHub Actions

You do not need a PC or Linux server. GitHub Actions runs the build remotely. The workflow removes only unrelated preinstalled tool directories from its temporary VM, installs build dependencies, and checks actual available disk before starting. Both the workflow and build script require at least 30 GiB free. If cleanup cannot provide that, the workflow stops with a clear space error instead of risking a partial build.

### 1. Create an empty GitHub repository

On your phone, open [github.com/new](https://github.com/new), sign in, and create a repository named `yfit-os`. Choose public or private, and leave **Add a README**, **Add .gitignore**, and **Choose a license** unchecked because those files already exist here.

### 2. Push this project from Termux

Open Termux in the existing project directory. If Git is not installed, run `pkg install git`. Set your own Git name and email, then add and commit the project:

```sh
cd ~/yfit-os
git config user.name "Your Name"
git config user.email "you@example.com"
git add -A
git commit -m "Initial Yfit OS project"
git branch -M main
```

Set `GITHUB_OWNER` to your GitHub username or organization name. For SSH, first add a public SSH key from Termux to your GitHub account, then run:

```sh
GITHUB_OWNER=your-github-username
git remote add origin "git@github.com:${GITHUB_OWNER}/yfit-os.git"
git push -u origin main
```

If you prefer HTTPS, use this remote instead:

```sh
GITHUB_OWNER=your-github-username
git remote add origin "https://github.com/${GITHUB_OWNER}/yfit-os.git"
git push -u origin main
```

GitHub does not accept account passwords for Git over HTTPS. When prompted for a password, enter a GitHub personal access token with access to this repository's contents. Enter it only at the password prompt; never put it in a command, project file, or commit. The workflow does not need repository secrets or credentials.

The `.gitignore` excludes generated ISO files, checksums, and build reports, so they will not be added to the source commit. GitHub Actions uploads those generated files separately after a successful build.

### Runner disk capacity

The workflow is intentionally pinned to the free standard `ubuntu-24.04` GitHub-hosted AMD64 runner. It removes only listed, unrelated preinstalled SDK directories on that ephemeral VM, installs the build tools, then measures actual free space on the workspace filesystem. Both the workflow and `scripts/build-iso.sh` enforce a hard minimum of 30 GiB; neither accepts an override. If the standard runner has less space, the job stops before live-build and does not upload an ISO. This is an expected safe failure on runner images whose available storage is below the requirement. No ISO is produced by that failed run.
### 3. Start the build

Pushing a commit to `main` starts the workflow automatically. To start it manually on the GitHub website:

1. Open the `yfit-os` repository.
2. Select **Actions**.
3. Select **Yfit OS build and checks**.
4. Select **Run workflow**, choose branch `main`, and confirm.


The workflow validates scripts/assets and scans for common committed credential patterns. It installs Debian Trixie `live-build` and `debootstrap` from the pinned Debian snapshot, builds on an AMD64 host, verifies the ISO9660 file, SHA256 checksum, kernel, initramfs, live root filesystem, and BIOS/UEFI boot entries, then uploads the evidence. No artifact is uploaded if build or verification fails.

### 4. Download the ISO

After the workflow run succeeds, open that run's **Summary** page and download the artifact named `yfit-os-amd64-<commit-sha>`. The artifact contains:

- `yfit-os-amd64.iso`
- `yfit-os-amd64.iso.sha256`
- ISO file-type and boot-structure reports
- Build log and Debian package manifest

Artifacts are retained for 30 days. Download the ISO and checksum before they expire. To check the checksum after downloading both files, run in Termux:

```sh
cd ~/storage/downloads
sha256sum -c yfit-os-amd64.iso.sha256
```

If the build fails, open the failed job step in Actions. Disk cleanup and remaining space are shown in the build log. An uploaded ISO is not evidence that desktop or installer runtime tests passed; those require the separate QEMU test steps below.

## Build dependencies and direct build

For a direct build on Debian 13 Trixie AMD64, install:

```sh
sudo apt-get update
sudo apt-get install -y live-build debootstrap xorriso squashfs-tools \
  grub-common grub-pc-bin grub-efi-amd64-bin mtools dosfstools file rsync dpkg-dev
```

The GitHub workflow also supports Ubuntu 24.04 AMD64 and installs `live-build` and `debootstrap` from the pinned Debian Trixie snapshot rather than Ubuntu's older package versions. Android/Termux and ARM hosts are rejected. The output target remains Debian Trixie AMD64. At least 7 GiB RAM and 30 GiB free storage are required.

```sh
sudo ./scripts/build-iso.sh
```

The build script cleans only live-build-generated state under this repository, invokes `auto/config` and `auto/build`, and refuses to report success unless one ISO, a package database, checksum, and structural verification are produced.

## Verification and runtime testing

Run source checks before building:

```sh
./tests/static-checks.sh
```

Verify an already generated image:

```sh
./scripts/verify-iso.sh output/yfit-os-amd64.iso
```

The ISO verifier checks ISO9660 recognition, SHA256, kernel, initramfs, SquashFS live root, and BIOS and UEFI El Torito entries. A successful ISO build does not prove the live desktop or installer works. The QEMU test scripts and checklist are in `tests/`; run them on a host with QEMU/KVM and record results in `docs/TEST-REPORT.md`. Physical hardware compatibility remains unverified until tested on actual PCs.

## Release limits

Do not advertise a release as tested until the live session boots, desktop services are exercised, and the installer completes against a disposable virtual disk. Secure Boot signing is not configured. Hardware support is limited to devices with Debian kernel and firmware support and has not been established by this build configuration alone.
