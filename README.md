# imac18-kernel

A Linux kernel tuned for the **2017 27" iMac (model iMac18,3)**, running Fedora 44.

This isn't a new kernel written from scratch. It is the stable kernel from kernel.org, rebuilt and configured specifically for this machine's hardware.

## Hardware

| Component | Part | Driver |
|---|---|---|
| CPU | Intel Kaby Lake (7th gen Core) | `intel_pstate`, `intel_idle` |
| GPU | AMD Radeon Pro 570 / 575 / 580 (Polaris) | `amdgpu` |
| Wi-Fi | Broadcom | `brcmfmac` |
| Bluetooth | Broadcom | `btusb`, `btbcm` |
| Audio | Cirrus Logic HDA | `snd_hda_intel`, `snd_hda_codec_cs8409` |
| Fans and sensors | Apple SMC | `applesmc` |
| Ports | Thunderbolt 3, USB 3 | `thunderbolt`, `xhci_pci` |

## What's different from the stock Fedora kernel

- **Built for this exact CPU** (`CONFIG_X86_NATIVE_CPU`, i.e. `-march=native`), instead of the generic x86-64 baseline.
- **Only this machine's drivers**, trimmed with `localmodconfig`, so the kernel is smaller and boots faster.
- **Tuned for desktop responsiveness:** full preemption (`PREEMPT`) and a 1000 Hz timer.
- **Memory and networking:** multi-gen LRU enabled by default, zram with zstd compression, and BBR as the default TCP congestion control.
- **No debug info**, so the build is faster and the install is smaller.

Expect a snappier, smoother desktop and faster boots rather than large benchmark gains.

## Repository contents

| File | Purpose |
|---|---|
| `build-imac-kernel.sh` | Downloads, configures, builds and installs the kernel |
| `config-7.3.0-imac18` | Exact kernel configuration used for the 7.3.0 build |
| Releases | Prebuilt kernel packages (`kernel-<version>.tar.zst`) |

## Building a new version

Run this on the iMac, booted into Fedora, with your usual USB devices plugged in:

```bash
chmod +x build-imac-kernel.sh
./build-imac-kernel.sh           # latest stable kernel
./build-imac-kernel.sh 7.3.0     # or a specific version
```

It asks for your password once at the start. The build takes roughly 15–40 minutes, and your existing kernel is left installed.

## Setting it as the default

```bash
sudo grubby --set-default=/boot/vmlinuz-7.3.0-imac18
```

To stop Fedora updates from switching back to the stock kernel, set `UPDATEDEFAULT=no` in `/etc/sysconfig/kernel`. Hold Shift at startup to show the boot menu and choose another kernel.

## Restoring from a release

```bash
gh release download 7.3.0-imac18 -R aeon-s/imac18-kernel
sudo tar --zstd -xf kernel-7.3.0-imac18.tar.zst -C /
sudo kernel-install add 7.3.0-imac18 /boot/vmlinuz-7.3.0-imac18
```

## Notes

- Because it is compiled for this CPU, the prebuilt kernel may not boot on other machines. Use the script to build one for different hardware.
- The 2017 iMac has no T2 chip and no Secure Boot, so no kernel signing is needed.
- The FaceTime HD camera needs the separate community `facetimehd` driver, which isn't included here.
- The Linux kernel is licensed under GPL-2.0. Source for each build is the matching release at [kernel.org](https://kernel.org), combined with the config file in this repo.
