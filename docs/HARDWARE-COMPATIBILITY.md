# Hardware compatibility

## Supported platform

The build target is x86_64/AMD64 PCs with UEFI or legacy BIOS boot firmware. Debian's AMD64 kernel and firmware packages are used. This is a target declaration, not evidence of compatibility with every PC.

## Expected device classes

Debian kernel drivers and firmware packages cover many common Intel/AMD CPUs, Intel/AMD graphics, wired NICs, Wi-Fi adapters, Bluetooth controllers, USB devices, SATA/NVMe storage, common audio codecs, and removable drives. NetworkManager, BlueZ, PipeWire, UDisks2/GVfs, and CUPS provide the corresponding user-space services. Detection and behavior must still be checked on each model.

## Known limitations / not claimed

- NVIDIA proprietary GPU acceleration is not preinstalled; Nouveau support and performance vary by model.
- Secure Boot signing and enrollment are not configured.
- Fingerprint readers, WWAN modems, Thunderbolt docks, RAID/VMD controllers, vendor-specific ACPI hotkeys, RGB utilities, and unusual touchpads may require additional drivers/configuration.
- Suspend/resume, battery reporting, multiple display layouts, hardware video decode, printers, and audio routes have not been physically tested.
- Non-AMD64 architectures are unsupported by this build.

## Evidence policy

Record exact machine model, firmware mode/version, CPU/GPU, Wi-Fi/Bluetooth chipset, audio device, display setup, test date, and test results in `TEST-REPORT.md`. QEMU results demonstrate guest behavior only and cannot be generalized to physical hardware.
