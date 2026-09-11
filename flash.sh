#!/usr/bin/env bash
# ==============================================================================
# Flash Script for Xiaomi Mi A2 (jasmine_sprout) - Ubuntu Touch 24.04 (Noble)
# ==============================================================================
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}   Xiaomi Mi A2 (jasmine_sprout) Ubuntu Touch 24.04   ${NC}"
echo -e "${BLUE}                Automated Flash Utility               ${NC}"
echo -e "${BLUE}====================================================${NC}\n"

# Locate tools
FASTBOOT_BIN="$(which fastboot 2>/dev/null || echo "./platform-tools/fastboot")"
ADB_BIN="$(which adb 2>/dev/null || echo "./platform-tools/adb")"

if ! command -v "$FASTBOOT_BIN" &>/dev/null; then
    echo -e "${RED}Error: 'fastboot' command not found! Please install android-tools or place platform-tools in PATH.${NC}"
    exit 1
fi

# Locate artifacts
BOOT_IMG=""
UBUNTU_IMG=""

for dir in . ./out ./ubuntu-touch-mi-a2-images ../ubuntu-touch-mi-a2-images; do
    if [ -f "$dir/boot-loopmount.img" ] && [ -z "$BOOT_IMG" ]; then
        BOOT_IMG="$dir/boot-loopmount.img"
    elif [ -f "$dir/boot.img" ] && [ -z "$BOOT_IMG" ]; then
        BOOT_IMG="$dir/boot.img"
    fi
    if [ -f "$dir/ubuntu.img" ] && [ -z "$UBUNTU_IMG" ]; then
        UBUNTU_IMG="$dir/ubuntu.img"
    elif [ -f "$dir/ubuntu.img.xz" ] && [ -z "$UBUNTU_IMG" ]; then
        echo -e "${YELLOW}Decompressing $dir/ubuntu.img.xz...${NC}"
        xz -d -k "$dir/ubuntu.img.xz" 2>/dev/null || unxz -k "$dir/ubuntu.img.xz"
        UBUNTU_IMG="$dir/ubuntu.img"
    elif [ -f "$dir/ubuntu.img.zst" ] && [ -z "$UBUNTU_IMG" ]; then
        echo -e "${YELLOW}Decompressing $dir/ubuntu.img.zst...${NC}"
        zstd -d "$dir/ubuntu.img.zst" -o "$dir/ubuntu.img"
        UBUNTU_IMG="$dir/ubuntu.img"
    fi
done

echo -e "Found Boot Image  : ${GREEN}${BOOT_IMG:-Not found}${NC}"
echo -e "Found Rootfs Image: ${GREEN}${UBUNTU_IMG:-Not found}${NC}\n"

if [ -z "$BOOT_IMG" ] || [ -z "$UBUNTU_IMG" ]; then
    echo -e "${RED}Error: Required flashable images (boot.img, ubuntu.img) not found in the current directory or ./out.${NC}"
    echo -e "Please download the CI artifacts and place them alongside this script."
    exit 1
fi

echo -e "${YELLOW}Instructions:${NC}"
echo -e "1. Power off your Xiaomi Mi A2."
echo -e "2. Hold ${YELLOW}Volume Down + Power${NC} until the FASTBOOT screen appears."
echo -e "3. Connect your phone via USB.\n"

read -rp "Press [Enter] when the phone is connected in Fastboot mode..."

echo -e "\n${BLUE}--> Checking fastboot connection...${NC}"
if ! "$FASTBOOT_BIN" devices | grep -q "fastboot"; then
    echo -e "${RED}No fastboot device detected! Check your USB cable or driver.${NC}"
    exit 1
fi

DEVICE_SN=$("$FASTBOOT_BIN" devices | awk '{print $1}' | head -n1)
echo -e "Connected device serial: ${GREEN}$DEVICE_SN${NC}"

# Flash boot partition
echo -e "\n${BLUE}--> Flashing boot image ($BOOT_IMG)...${NC}"
"$FASTBOOT_BIN" flash boot_a "$BOOT_IMG"
"$FASTBOOT_BIN" flash boot_b "$BOOT_IMG" 2>/dev/null || true
"$FASTBOOT_BIN" set_active a 2>/dev/null || true

# Boot to TWRP / Recovery or Halium to push ubuntu.img
echo -e "\n${BLUE}--> Deploying rootfs (/userdata/ubuntu.img)...${NC}"
echo -e "${YELLOW}Option 1 (Fastboot/Recovery):${NC} If your device has Halium recovery or TWRP installed:"
echo -e "Run: adb push $UBUNTU_IMG /userdata/ubuntu.img"
echo -e "Or if you already have the rootfs deployed to /userdata/ubuntu.img, you are ready to reboot!"

read -rp "Do you want to reboot into Ubuntu Touch now? [y/N]: " REBOOT_CHOICE
if [[ "$REBOOT_CHOICE" =~ ^[Yy]$ ]]; then
    echo -e "\n${GREEN}Rebooting into Ubuntu Touch 24.04... Enjoy!${NC}"
    "$FASTBOOT_BIN" reboot
fi
