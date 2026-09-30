#
# Copyright (C) 2026 The Team Win Recovery Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base_telephony.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_full.mk)

# 继承 TWRP 通用配置
$(call inherit-product, vendor/omni/config/common.mk)
$(call inherit-product, vendor/omni/config/gsm.mk)

# 设备专有配置
$(call inherit-product, device/iflytek/MS600/device.mk)

# 覆盖默认值
PRODUCT_NAME := omni_MS600
PRODUCT_DEVICE := MS600
PRODUCT_BRAND := iFlytek
PRODUCT_MODEL := MeetingService600
PRODUCT_MANUFACTURER := iFlytek

PRODUCT_GMS_CLIENTID_BASE := android-iflytek

# 系统属性
PRODUCT_PROPERTY_OVERRIDES += \
    ro.sf.lcd_density=224 \
    ro.com.google.clientidbase=android-iflytek \
    persist.sys.usb.config=adb
