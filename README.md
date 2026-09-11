# Xiaomi Mi A2 (`jasmine_sprout`) — Ubuntu Touch 24.04 LTS (Noble Numbat)

[![Ubuntu Touch](https://img.shields.io/badge/Ubuntu%20Touch-24.04%20Noble-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubports.com)
[![Halium](https://img.shields.io/badge/Halium-9.0%20(Android%20Pie)-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://halium.org)
[![Architecture](https://img.shields.io/badge/Arch-arm64-blue?style=for-the-badge)](https://en.wikipedia.org/wiki/AArch64)
[![Kernel](https://img.shields.io/badge/Kernel-4.4.250--Xiaomi__SDM660-green?style=for-the-badge&logo=linux&logoColor=white)](https://github.com/ubports-xiaomi-sdm660/android_kernel_xiaomi_sdm660)

This repository contains the complete device adaptation tree for running **Ubuntu Touch 24.04 LTS (Noble Numbat)** on the **Xiaomi Mi A2** (`jasmine_sprout` / `jasmine`).

---

## 📱 Hardware Support Status

| Component | Status | Details |
| :--- | :---: | :--- |
| **Boot & System** | 🟢 **Working** | Ubuntu Touch 24.04.5 LTS Noble on Linux 4.4.250 |
| **Display / Backlight** | 🟢 **Working** | Full HD+ (1080 × 2160) with smooth brightness scaling |
| **Touchscreen** | 🟢 **Working** | Multitouch, responsive gestures, Lomiri edge swiping |
| **Wi-Fi** | 🟢 **Working** | 2.4 GHz & 5.0 GHz 802.11 a/b/g/n/ac |
| **Bluetooth** | 🟢 **Working** | Audio streaming, pairing, BLE peripheral connectivity |
| **Audio** | 🟢 **Working** | Loudspeaker, earpiece, microphone, USB-C audio |
| **Cellular (Calls / SMS)** | 🟢 **Working** | oFono RIL, voice calling, SMS messaging, Dual SIM |
| **Mobile Data** | 🟢 **Working** | 4G LTE data connection |
| **Fingerprint Reader** | 🟢 **Working** | Goodix (`gf3208`) & FPC (`fpc1020`) via TrustZone QSEE HAL |
| **Battery & Charging** | 🟢 **Working** | Quick Charge support, stable charging curves, ~93% CPU idle efficiency |
| **Camera** | 🟢 **Working** | Front & rear photo capture |
| **Sensors** | 🟢 **Working** | Accelerometer, proximity, ambient light, compass |
| **Double Tap to Wake** | 🟢 **Supported** | Supported via kernel driver |
| **USB Connectivity** | 🟢 **Working** | MTP file transfer, ADB debugging, `usb-moded` |

---

## 🚀 Installation & Flashing Guide

Because the physical `system` partition on the Mi A2 is limited to 3.0 GB, Ubuntu Touch 24.04 Noble (which is ~3.5 GB) utilizes **Halium's native loopmount** on the **46 GB `/userdata` partition**. Everything is configured to work **completely out of the box**.

### 1. Prerequisites
- **Xiaomi Mi A2** with an unlocked bootloader.
- Stock Android 9 (Pie) firmware base on both slots (`V10.0.17.0.PDIMIXM` or newer).
- Android platform tools (`fastboot` and `adb`) installed on your PC.

### 2. Download Images
From the [Releases or CI Actions](../../actions), download the latest `ubuntu-touch-mi-a2-images` artifact containing:
- `boot.img` (or `boot-loopmount.img`)
- `ubuntu.img` (the rootfs)

### 3. Automated Flashing
Place the images in the directory and run:
```bash
chmod +x flash.sh
./flash.sh
```

### 4. Manual Flashing Steps (Alternative)
1. **Reboot to Fastboot**:
   Turn off your phone, then hold **Volume Down + Power** until the `FASTBOOT` screen appears. Connect the phone to your computer via USB.

2. **Flash Boot Partition**:
   ```bash
   fastboot flash boot_a boot.img
   fastboot flash boot_b boot.img
   fastboot set_active a
   ```

3. **Deploy Root Filesystem**:
   Boot your phone into Halium recovery or TWRP, then push `ubuntu.img` to `/userdata/`:
   ```bash
   adb push ubuntu.img /userdata/ubuntu.img
   ```

4. **Reboot into Ubuntu Touch**:
   ```bash
   fastboot reboot
   ```
   *The phone will boot directly into the Lomiri desktop environment.*

---

## 🔒 Fingerprint Reader: Usage & Notes

1. **First Unlock Requirement**:
   Like modern Android and iOS, Ubuntu Touch's security model requires entering your **Passcode / PIN (`1234` by default)** once on the initial screen after boot. This activates the biometric subsystem.
2. **Enrolling Fingerprints**:
   - Navigate to **Settings $\rightarrow$ Security & Privacy $\rightarrow$ Locking and unlocking $\rightarrow$ Fingerprint**.
   - Tap **Add fingerprint** and place your finger on the rear sensor to enroll.
3. **Unlocking**:
   - Turn off the screen with the Power button.
   - Wake the screen and touch the rear sensor to unlock instantly.

---

## 🛠️ Building from Source

### GitHub Actions CI
The easiest way to build is by pushing to your fork or running the workflow manually:
1. Go to **Actions** $\rightarrow$ **Build Ubuntu Touch (Mi A2)**.
2. Click **Run workflow** and select your release branch (`24.04-2.x`).
3. Download the flashable artifacts once complete.

### Local Build
```bash
# Clone generic build tools
git clone https://gitlab.com/ubports/community-ports/halium-generic-adaptation-build-tools.git build

# Build device kernel & adaptation tarball
./build/build.sh

# Generate flashable images
DEVICE="$(source deviceinfo && echo $deviceinfo_codename)"
./build/prepare-fake-ota.sh out/device_${DEVICE}.tar.xz ota
./build/system-image-from-ota.sh ota/ubuntu_command out
mv out/rootfs.img out/ubuntu.img
```

---

## 📂 Repository Structure

```
device-jasmine-sprout/
├── .github/workflows/          # Automated GitHub Actions CI workflow
├── build.sh                    # Build runner script
├── deviceinfo                  # Device configuration, offsets, and kernel flags
├── flash.sh                    # One-click installation utility
├── overlay/                    # Rootfs overlay applied on top of Ubuntu Touch
│   └── system/
│       ├── android/vendor/     # Qualcomm TrustZone firmware blobs (Goodix QSEE)
│       ├── etc/                # ofono, repowerd, usb-moded configs
│       ├── lib/udev/rules.d/   # udev permissions for hardware & fingerprint
│       └── usr/libexec/        # device-hacks initialization & hal hooks
└── README.md
```

---

## 🤝 Credits & Acknowledgements

- **[UBports Community](https://ubports.com)** — For keeping Ubuntu Touch alive and modernizing to 24.04 Noble.
- **[Halium Project](https://halium.org)** — Next-generation hardware abstraction layer for Linux on mobile.
- **[Xiaomi SDM660 Porting Team](https://github.com/ubports-xiaomi-sdm660)** — Original kernel and HAL adaptations.

---

**License**: Distributed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.html).
