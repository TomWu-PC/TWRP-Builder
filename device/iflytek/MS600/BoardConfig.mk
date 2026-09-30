#
# Copyright (C) 2026 The Team Win Recovery Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Platform
TARGET_BOARD_PLATFORM := msm8953
TARGET_BOOTLOADER_BOARD_NAME := MS600
TARGET_BOARD_PLATFORM_GPU := qcom-adreno506

# Architecture
# SDM450 / msm8953 是 64 位 SoC（Cortex-A53 x8），设备实际 ABI 为 arm64-v8a
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := cortex-a53

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv7-a-neon
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a53
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a53
TARGET_CPU_VARIANT_RUNTIME := cortex-a53

TARGET_USES_64_BIT_BINDER := true
TARGET_SUPPORTS_32_BIT_APPS := true
TARGET_SUPPORTS_64_BIT_APPS := true

# Kernel
# 内核来源：本机 boot/recovery 分区实测 kernel 3.18.71-perf (CodeAurora msm-3.18)
# 优先使用 prebuilt 内核（从 recovery 分区提取的 kernel.bin），保证与硬件 100% 匹配
TARGET_PREBUILT_KERNEL := device/iflytek/MS600/prebuilt/kernel
# 内核使用附加 dtb 拼接（qcdt / appended dtb）
BOARD_KERNEL_IMAGE_NAME := Image.gz-dtb
TARGET_KERNEL_APPEND_DTB := true
BOARD_KERNEL_CMDLINE := console=ttyHSL0,115200,n8 androidboot.console=ttyHSL0 androidboot.hardware=qcom msm_rtb.filter=0x237 ehci-hcd.park=3 lpm_levels.sleep_disabled=1 androidboot.bootdevice=7824900.sdhci earlycon=msm_hsl_uart,0x78af000 buildvariant=user
BOARD_KERNEL_BASE := 0x80000000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_TAGS_OFFSET := 0x00000100
BOARD_RAMDISK_OFFSET := 0x01000000
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_DTB_OFFSET := 0x01f00000

# Recovery
TARGET_RECOVERY_PIXEL_FORMAT := "RGBX_8888"
TARGET_RECOVERY_FSTAB := device/iflytek/MS600/recovery.fstab
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
TARGET_USES_MKE2FS := true
BOARD_HAS_LARGE_FILESYSTEM := true

# A-only 设备（无 A/B 分区）
AB_OTA_UPDATER := false

# TWRP 相关标志
TW_THEME := portrait_hdpi
TW_DEVICE_VERSION := MS600-by-WorkBuddy
TW_MAX_BRIGHTNESS := 255
TW_DEFAULT_BRIGHTNESS := 140
TW_BRIGHTNESS_PATH := "/sys/class/backlight/panel0-backlight/brightness"
TW_EXCLUDE_TWRPAPP := true
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_FUSE_EXFAT := true
TW_HAS_DOWNLOAD_MODE := true
TW_USE_TOOLBOX := true
# 无硬件加密芯片，footer 加密
TW_CRYPTO_USE_SYSTEM_VOLD := false
TW_INCLUDE_NTFS_3G := true

# 屏幕：1200x1920 竖屏，density 224
TW_SCREEN_BLANK_ON_BOOT := true
TW_EXTRA_LANGUAGES := true
TW_DEFAULT_LANGUAGE := zh_CN

# 触摸屏 - focaltech,fts
TW_USE_TWRP_NETWORK := true

# SELinux
# ⚠️ 暂不启用自定义 sepolicy：本项目写的 device.te 里重复声明了
#    boot_block_device 等类型（TWRP 通用策略已定义），导致编译报
#      ERROR 'Duplicate declaration of type'
#    TWRP 自带的 recovery 域策略已足够首次编译/启动。
#    等 TWRP 跑起来后若发现权限不足，再针对性补 allow 规则。
# BOARD_SEPOLICY_DIRS := device/iflytek/MS600/sepolicy

# 分区大小（来自本机实测 partitions.txt / 分区镜像）
# system  : 3145728 KB = 3.0 GB
# vendor  : 1048576 KB = 1.0 GB
# userdata: 20700647 blocks (dm-0)
# cache   : 262144 KB = 256 MB
# boot    : 65536 KB = 64 MB
# recovery: 65536 KB = 64 MB
# misc    : 1024 KB
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 67108864
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 3221225472
BOARD_USERDATAIMAGE_PARTITION_SIZE := 21196642816
BOARD_CACHEIMAGE_PARTITION_SIZE := 268435456
BOARD_FLASH_BLOCK_SIZE := 131072

# 使用文件系统
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_ROOT_EXTRA_FOLDERS := persist firmware

# 本机是 Treble 设备（有独立 vendor 分区）
# TWRP 只编译 recovery.img，不构建 vendor 镜像。
# 只需声明 TARGET_COPY_OUT_VENDOR := vendor，让 build 系统知道 vendor 产物的
# 输出目录；绝不能开 BOARD_USES_VENDORIMAGE（那会强制要求生成 vendor 镜像，
# 反而触发 "must be set to 'vendor' to use a vendor image" 报错）。
TARGET_COPY_OUT_VENDOR := vendor

# TWRP 保存分区（备份目标）
TW_HAS_NO_RECOVERY_PARTITION := false
