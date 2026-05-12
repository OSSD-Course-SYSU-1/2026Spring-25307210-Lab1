# oh-bill-master 工程代码解析文档（任务2）

## 1. 项目概述
本项目是基于 OpenHarmony ArkTS 开发的「易记账」应用，采用 Stage 模型构建，实现了收支记录、分类管理、数据展示等核心功能，是一个结构规范、可直接运行的鸿蒙应用工程。

## 2. 项目整体目录结构
oh-bill-master/
├── .hvigor/ # 构建系统缓存与配置目录
├── .idea/ # DevEco Studio 项目配置文件
├── AppScope/ # 应用级配置模块
├── common/ # 公共模块（工具、通用组件）
├── entry/ # 主应用模块（程序入口）
├── screenshots/ # 应用截图资源
├── .gitignore # Git 忽略文件配置
├── build-profile.json5 # 项目构建配置
├── hvigorfile.ts # 构建系统入口脚本
├── oh-package.json5 # 项目依赖配置
└── README.md # 项目说明文档


## 3. 核心目录与文件解析
### 3.1 AppScope/ 应用级配置模块
- `resources/`：存放应用级资源文件（如多语言字符串、颜色、尺寸定义）
- `app.json5`：应用级配置文件，定义应用包名、版本号、权限等全局信息

### 3.2 common/ 公共模块
- `build/`：公共模块的构建配置文件
- `src/`：存放通用工具类、公共组件、常量定义，可被多个页面复用

### 3.3 entry/ 主应用模块（核心）
这是项目的主模块，包含了应用的核心代码，结构如下：
entry/
├── build/ # 模块构建输出目录
├── oh_modules/ # 第三方依赖库目录
└── src/main/ets/ # ArkTS 核心代码目录
├── pages/ # 应用页面文件
├── model/ # 数据模型定义
├── utils/ # 工具类（如数据存储、格式化工具）
└── entryability.ts # 应用入口 Ability 文件


#### 3.3.1 entryability.ts
- 应用的入口文件，负责应用启动时的初始化
- 管理应用生命周期，设置页面路由规则，加载首页

#### 3.3.2 pages/ 页面目录
存放应用所有业务页面，常见文件包括：
- `Index.ets`：应用首页，展示账单列表、收支统计概览
- `AddBill.ets`：新增/编辑账单页面，处理表单输入与数据提交
- `Statistics.ets`：数据统计页面，展示收支趋势、分类占比等

#### 3.3.3 model/ 数据模型目录
定义项目中使用的数据结构，例如：
- `Bill.ets`：账单数据模型，包含 `id`、`amount`、`type`（收入/支出）、`category`（分类）、`date`、`remark` 等字段

#### 3.3.4 utils/ 工具类目录
封装通用工具方法，例如：
- `DataStore.ets`：数据存储工具，封装本地数据的读写操作，实现数据持久化
- `DateUtil.ets`：日期格式化工具，处理时间戳与日期字符串的转换

### 3.4 screenshots/ 截图资源目录
存放应用运行截图，用于文档说明、演示，包含 `Screenshot_2023-08-12Txxxxxx.png` 等文件

### 3.5 根目录配置文件
- `build-profile.json5`：项目构建配置，定义模块信息、编译参数、依赖版本
- `hvigorfile.ts`：Hvigor 构建工具的入口脚本，配置项目构建流程
- `oh-package.json5`：项目依赖配置文件，声明项目依赖的第三方库及其版本

## 4. 核心技术点
- **ArkTS 声明式 UI**：使用 `@Component`、`@State` 等装饰器实现响应式界面开发
- **Stage 模型**：基于 AbilityStage 的应用生命周期管理
- **本地数据存储**：使用 OpenHarmony 提供的 `Preferences` 或 `RelationalStore` 实现数据持久化
- **路由跳转**：通过 `router.pushUrl()` 实现页面间的跳转与参数传递

## 5. 项目运行流程
1. 应用启动 → `entryability.ts` 初始化，加载应用配置
2. 进入 `Index.ets` 首页 → 调用 `DataStore.ets` 读取本地账单数据，渲染列表
3. 用户点击「添加账单」→ 跳转到 `AddBill.ets`，输入并保存账单信息
4. 数据提交 → 调用 `DataStore.ets` 将新账单写入本地存储
5. 返回首页 → 自动刷新列表，显示新增账单
6. 用户进入 `Statistics.ets` → 聚合账单数据，生成统计图表