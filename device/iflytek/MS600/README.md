# TWRP 设备树 — 讯飞听见 L1 (iFlytek MS600)

> 基于本机实测数据生成，2026-09-30
> 目标：为 iFlytek MS600 (SDM450 / MSM8953) 编译 TWRP Recovery

## 设备概况

| 项 | 值 |
|---|---|
| 品牌 / 型号 | iFlytek / MeetingService600 (MS600) |
| 内部代号 | MS600-M |
| SoC | 高通 SDM450 (msm8953 系列)，八核 Cortex-A53 |
| msm-id | `0x152` |
| board-id | `0x8 0x1` |
| 架构 | arm64-v8a (兼容 armeabi-v7a) |
| 系统 | Android 8.1.0 / API 27 |
| 构建 | `user` + release-keys |
| 屏幕 | 1200×1920 竖屏，density 224 |
| 触摸 | FocalTech `focaltech,fts` @ I2C 0x38 |
| 内核 | 3.18.71-perf (CodeAurora msm-3.18) |
| 分区方案 | A-only（无 A/B） |
| SELinux | Enforcing |
| Root | Magisk |

## 目录结构

```
device/iflytek/MS600/
├── AndroidProducts.mk          # 产品定义入口
├── BoardConfig.mk              # 编译配置（核心）
├── device.mk                   # 产品配置
├── omni_MS600.mk               # 产品定义
├── vendorsetup.sh              # lunch 菜单
├── twrp_MS600.mk               # TWRP 标志
├── recovery.fstab              # 分区挂载表（TWRP 格式）
├── init.recovery.qcom.rc       # recovery init（原厂提取）
├── sepolicy/
│   └── recovery.te             # SELinux 策略
└── prebuilt/
    ├── kernel                  # gzip 内核（从 recovery 分区提取，27.5MB）
    ├── dtb_ms600_live.fdt      # 运行时设备树（最权威，247KB）
    ├── dtb_ms600_origin.dtb    # 原始编译 DTB（246KB）
    └── recovery_prop.default   # 原厂 recovery 属性
```

## 素材来源（全部本机实测）

| 文件 | 来源 |
|---|---|
| `prebuilt/kernel` | recovery 分区内 kernel，gzip 流 27,559,019 字节 |
| `prebuilt/dtb_ms600_live.fdt` | `/sys/firmware/fdt` 导出（运行时设备树） |
| `prebuilt/dtb_ms600_origin.dtb` | DTB 表中唯一精确匹配项 (dtb_16) |
| `recovery.fstab` | recovery ramdisk 内 `/etc/recovery.fstab` |
| `init.recovery.qcom.rc` | recovery ramdisk 根目录 |

## 编译步骤（Linux 环境）

```bash
# 1. 初始化 TWRP 源码（minimal manifest）
repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-8.1
repo sync -j8

# 2. 放入设备树
mkdir -p device/iflytek
cp -r MS600 device/iflytek/MS600

# 3. 拉取内核源码（或使用 prebuilt，二选一）
#    方式 A：使用 prebuilt（推荐，先跑通）
#    方式 B：克隆 CodeAurora msm-3.18
#    git clone https://github.com/android-linux-stable/msm-3.18 -b kernel.lnx.3.18.r33-rel

# 4. 编译
. build/envsetup.sh
lunch omni_MS600-eng
mka recoveryimage -j$(nproc)

# 5. 产物
#    out/target/product/MS600/recovery.img
```

## 关键决策点

1. **内核用 prebuilt 还是自编译？**
   - 先用 prebuilt（保证硬件兼容），跑通后再考虑自编译
   - 自编译需要 CodeAurora msm-3.18 + 讯飞的 defconfig（未提取到）

2. **AVB1 校验**
   - 本机 recovery 有 AVB1 签名校验（`ro.expect.recovery_id`）
   - TWRP recovery.img 签名不同 → 可能需要 patch bootloader 或改 `ro.expect.recovery_id`

3. **无 EDL 救砖**
   - 尚未验证 EDL 组合键
   - 强烈建议先确认 EDL 可用，再刷 TWRP

## 已知风险

- ⚠️ 首次刷入 TWRP 前**必须备份原厂 recovery.img**（已有：`_备份/0930_初始状态/分区镜像/`）
- ⚠️ `ro.expect.recovery_id` 可能导致 TWRP 无法启动（需实测）
- ⚠️ 触摸屏需 focaltech 驱动，TWRP 内核如不含该驱动则触摸失效
