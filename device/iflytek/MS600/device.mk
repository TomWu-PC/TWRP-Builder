#
# Copyright (C) 2026 The Team Win Recovery Project
#

LOCAL_PATH := device/iflytek/MS600

# 包含 BoardConfig 里定义的平台（在 TWRP 树中，这些通常由 vendor/qcom 提供）
# 注意：TWRP 会自动把 BoardConfig 里 TARGET_RECOVERY_FSTAB 指定的 fstab
# 装进 recovery ramdisk 的 /etc/recovery.fstab，这里不要重复 COPY，
# 否则会覆盖 TWRP 自己生成的 fstab（含 /etc/twrp.fstab 合并逻辑）。

# TWRP 语言
PRODUCT_DEFAULT_LANGUAGE := zh_CN
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    persist.sys.timezone=Asia/Shanghai

# 预编译内核
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/prebuilt/kernel:kernel

# 允许 recovery 使用 adb
PRODUCT_PROPERTY_OVERRIDES += \
    ro.adb.secure=0 \
    ro.secure=0
