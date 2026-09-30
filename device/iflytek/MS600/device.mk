#
# Copyright (C) 2026 The Team Win Recovery Project
#

LOCAL_PATH := device/iflytek/MS600

# 包含 BoardConfig 里定义的平台（在 TWRP 树中，这些通常由 vendor/qcom 提供）
# 注意：TWRP 最小树（minimal manifest）不含完整 vendor/qcom，需要靠 prebuilt
# 这里的 device.mk 只做最小必要的产品配置。

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/recovery.fstab:$(TARGET_COPY_OUT_RECOVERY)/root/etc/recovery.fstab

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
