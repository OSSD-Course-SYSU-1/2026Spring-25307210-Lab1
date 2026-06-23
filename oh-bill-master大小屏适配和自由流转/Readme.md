# oh-bill-master - 大小屏适配与自由流转功能升级说明

本项目基于 **oh-bill-master** 开源记账应用进行扩展，遵循 木兰宽松许可证第2版（Mulan PSL v2）。为了提升应用在多端协同生态下的用户体验，本次升级重点引入了一次开发，多端部署（大小屏响应式自适应）**以及**自由流转（跨端迁移）两大核心分布式能力。

---

## 🛠️ 核心变更与功能特性

### 1. 响应式布局与大小屏适配

放弃了原本单一的纵向线性堆叠结构，引入方舟UI（ArkUI）的**媒体查询（Media Query）**与**栅格系统（GridRow / GridCol）**：

* **小屏设备（sm，如手机）：** 保持原有的紧凑上下堆叠视图，操作逻辑完全不变。
* **折叠屏展开态（md）：** 自动转换为双栏平铺布局，左侧显示资产看板与快捷入口，右侧显示账单列表，消除屏幕两侧的空白。
* **大屏设备（lg，如平板/2in1）：** 自动按 $4:8$ 的黄金比例划分为左侧看板区与右侧列表区，充分榨干大屏的视觉空间，大幅提高数据资产的阅读效率。

### 2. 自由流转（跨端状态迁移）

利用鸿蒙分布式任务调度能力，打通了设备间的状态壁垒。用户在手机上操作到一半时，可无缝迁移至平板继续使用：

* **数据无缝衔接：** 流转触发时，系统会自动将当前页面选中的日期状态（`selectedDate` 时间戳）打包。
* **多实例完美恢复：** 无论目标端应用是处于冷启动（`onCreate` 阶段）还是后台热活状态（`onNewWant` 阶段），均能通过绑定的 `LocalStorage` 完美恢复至迁移前的账单视图。

---

## 📂 修改文件清单

| 文件路径 | 变更类型 | 核心修改点 |
| --- | --- | --- |
| `entry/src/main/module.json5` | **配置更新** | 增加 `tablet` 与 `2in1` 支持；为 `EntryAbility` 开启 `"continuable": true` 标签。 |
| `entry/src/main/ets/entryability/EntryAbility.ets` | **业务重构** | 实现 `onContinue` 状态打包钩子，并在 `onCreate` 与 `onNewWant` 中捕获流转上下文，注入 `LocalStorage`。 |
| `entry/src/main/ets/pages/Index.ets` | **UI与状态重构** | 接入 `@ohos.mediaquery` 监听断点；使用 `GridRow/GridCol` 重构 `build()` 根布局；挂载 `@LocalStorageProp` 接收并恢复日期状态。 |
