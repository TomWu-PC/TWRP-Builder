# TWRP Builder for iFlytek MS600 (讯飞听见 L1)

用 GitHub Actions 云端编译 TWRP Recovery。**本机零负担**，无需虚拟机。

## 这是什么

一套完整的云编译工程：把本机提取的 **MS600 设备树**推到 GitHub，
用免费的云服务器（4核 16GB，Ubuntu 22.04）编译出 `recovery.img`。

## 目录结构

```
TWRP-Builder/
├── .github/workflows/
│   └── build-twrp.yml          # GitHub Actions 编译流程
├── device/iflytek/MS600/       # 设备树（本机实测生成）
│   ├── BoardConfig.mk
│   ├── omni_MS600.mk
│   ├── recovery.fstab
│   ├── prebuilt/kernel         # 实测提取的内核
│   └── ...
└── README.md
```

## 使用步骤

### 第一步：在 GitHub 新建仓库

1. 打开 https://github.com/new
2. 仓库名：`TWRP-Builder`（或任意）
3. 可见性：**Public**（私有仓库 Actions 有额度限制）或 Private 都行
4. **不要**勾选 "Add a README"（我们已有文件）
5. 点 Create

### 第二步：把本工程推上去

在你本机的 **Git Bash / CMD** 里执行（把 `你的用户名` 换成实际 GitHub 用户名）：

```bash
cd "C:/Users/TomWu/Desktop/WorkBuddy/MS600/_云编译/TWRP-Builder"

git init
git add .
git commit -m "TWRP device tree for iFlytek MS600"
git branch -M main
git remote add origin https://github.com/你的用户名/TWRP-Builder.git
git push -u origin main
```

> 如果 push 要求登录，用 **Personal Access Token**（不是密码）：
> GitHub → Settings → Developer settings → Personal access tokens → 生成勾选 `repo` 权限

### 第三步：等云端编译

push 后会自动触发。也可以手动触发：
- 仓库页面 → **Actions** 标签 → 左侧 **Build TWRP for MS600** → **Run workflow**

编译耗时约 **30~50 分钟**（首次同步源码慢）。

### 第四步：下载产物

- Actions → 点进那次运行 → 页面底部 **Artifacts**
- 下载 **twrp-recovery-MS600**（含 `recovery.img`）

### 第五步：刷入设备

```bash
# 进入 fastboot（关机后按住 音量加+电源，或 adb reboot bootloader）
fastboot devices
fastboot flash recovery recovery.img
fastboot reboot recovery    # 测试能否进 TWRP
```

⚠️ **刷之前确认**：
1. 原厂 recovery 已备份（`_备份/0930_初始状态/分区镜像/recovery.img`）✅
2. EDL 救砖通道已确认（音量加+音量减 + 插线 → 9008）✅
3. 万一失败，用 EDL 救回

## 万一编译失败怎么办

1. 下载 **build-log** artifact，看报错
2. 常见问题见下方

| 报错 | 原因 | 对策 |
|---|---|---|
| `repo sync` 失败 | GitHub 网络抖动 | 重跑 workflow（代码里有重试） |
| `No such file: device/...` | 设备树路径不对 | 检查 `device/iflytek/MS600` 是否上传 |
| 缺 `vendor/omni` | manifest 分支不对 | 改 `manifest_branch` 换分支 |
| 内核相关报错 | prebuilt 内核格式 | 检查 `prebuilt/kernel` 是否存在 |
| `error: ninja` 内存/OOM | 内存不足 | 减小 `-j` 参数 |

## 关键技术信息

| 项 | 值 |
|---|---|
| 设备 | iFlytek MS600 / MeetingService600 |
| SoC | 高通 SDM450 (msm8953) |
| 架构 | arm64-v8a |
| Android | 8.1.0 / API 27 |
| TWRP 分支 | twrp-8.1 |
| 屏幕 | 1200×1920 |
| 触摸 | FocalTech fts |
| 已救砖手段 | EDL 9008（音量加+音量减） |

## 说明

- 设备树基于本机 **实测数据** 生成（内核、DTB、fstab 均从设备提取）
- 首次编译建议先用 **prebuilt 内核**（保证硬件兼容），跑通后再考虑自编译内核
- 若 TWRP 启动后触摸失灵，需检查内核是否含 focaltech 驱动
