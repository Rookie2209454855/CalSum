# CalSum - 食物热量与运动追踪器

这是一个全栈应用，用于追踪食物热量摄入和运动消耗。

## 功能特性

- 用户注册和登录
- 记录食物摄入（名称、重量、热量等）
- 记录运动消耗
- 多用户数据隔离
- 数据持久化存储（SQLite）

## 技术栈

- 前端：Vue.js, Element UI
- 后端：Node.js, Express, SQLite
- 数据库：SQLite（文件型数据库）

## 快速开始

### 环境要求

- Node.js (v14 或更高版本)
- npm

### 安装和运行

#### 1. 安装所有依赖

```bash
npm run install-all
```

#### 2. 构建应用

```bash
npm run build
```

#### 3. 启动应用

开发模式（前后端分别运行）：
```bash
npm run dev
```

或者生产模式（仅后端，前端已构建）：
```bash
npm start
```

应用将在 `http://localhost:8080` 上运行。

### 脚本说明

- `npm run install-all`: 安装根目录、前端和后端的所有依赖
- `npm run build-frontend`: 仅构建前端
- `npm run copy-frontend-to-backend`: 将前端构建产物复制到后端目录
- `npm run build`: 构建前端并复制到后端（发布前执行）
- `npm run start-backend`: 仅启动后端服务器
- `npm run start-dev`: 同时启动前后端（用于开发）
- `npm run start`: 启动全栈应用（生产模式）
- `npm run dev`: 安装依赖并启动开发模式

## 端口配置

应用默认在端口 8080 上运行。如果需要修改端口，请按以下步骤操作：

### 方法一：修改环境变量文件

1. 在根目录的 [.env](file:///d:\WorkSpace\CalSum\.env) 文件中修改 `PORT` 变量：

```
# CalSum 全局环境变量配置
PORT=8080  # 修改为你想要的端口号
DB_PATH=./backend/database.sqlite
JWT_SECRET=your_super_secret_jwt_key_for_production
```

### 方法二：通过系统环境变量覆盖

在启动应用前设置系统环境变量：

Windows:
```cmd
set PORT=3000 && npm run start
```

Linux/macOS:
```bash
PORT=3000 npm run start
```

修改端口后，应用将在新的端口上运行。

## 系统架构

- 前端位于 `./frontend` 目录
- 后端位于 `./backend` 目录
- 构建脚本位于 `./scripts` 目录
- 数据库存储在 `./backend/database.sqlite` 文件中

## 部署

1. 运行 `npm run build` 以构建前端并复制到后端
2. 确保后端依赖已安装
3. 运行 `npm start` 启动生产服务器

## 跨平台支持

此应用支持在 Windows、Linux 和 macOS 上运行。构建脚本已针对跨平台兼容性进行了优化。