# CalSum - 部署指南

本指南介绍如何在生产环境中部署 CalSum 应用程序。

## 部署概述

CalSum 是一个全栈应用，包含前端（Vue.js）和后端（Node.js + Express + SQLite）。生产部署包含以下组件：
- 构建好的前端静态文件
- Node.js 后端服务
- SQLite 数据库文件

## 部署要求

### 系统要求
- Node.js v16.x 或更高版本
- npm v8.x 或更高版本
- 系统内存至少 512MB
- 至少 1GB 可用磁盘空间

### 依赖项
- `sqlite3` 模块（用于数据库）
- `express`, `cors`, `bcryptjs`, `jsonwebtoken` 模块（后端服务）
- `vue`, `vuex`, `axios`, `element-ui` 模块（前端功能）

## 创建发布包

在部署到生产服务器之前，您可以使用以下命令创建一个包含所有必要文件的发布包：

```bash
npm run create-release
```

此命令将创建一个 `release` 目录，其中包含：

```
release/
├── .env                      # 环境变量配置模板
├── package.json              # 项目配置和启动脚本
├── package-lock.json         # 依赖锁定文件
├── README.md                 # 项目说明
├── DEPLOYMENT.md             # 部署说明
├── DEPLOY_INSTRUCTIONS.txt   # 部署操作说明
├── backend/
│   ├── server.js             # 后端服务器文件
│   ├── package.json          # 后端依赖配置
│   ├── package-lock.json     # 后端依赖锁定
│   └── dist/                 # 前端构建产物
│       ├── index.html
│       ├── css/
│       ├── js/
│       └── ...
└── scripts/
    └── start-server.js       # 服务器启动脚本
```

## 部署文件清单

部署时需要以下文件和目录：

```
backend/
├── server.js                 # 主服务器文件
├── package.json              # 后端依赖配置
├── database.sqlite           # 用户数据存储文件
├── models/                   # 数据模型目录
├── routes/                   # 路由定义目录（如有）
└── dist/                     # 前端构建文件目录
```

## 部署步骤

### 1. 准备部署文件

1. 将发布包传输到目标服务器
2. 解压到目标目录（例如 `/var/www/calsum/`）

### 2. 环境变量配置

在部署之前，需要配置环境变量。不要将包含敏感信息的实际 [.env](file:///d:\WorkSpace\CalSum\.env) 文件部署到生产环境，而是：

#### 方法一：创建生产环境的 [.env](file:///d:\WorkSpace\CalSum\.env) 文件

在服务器上创建 [.env](file:///d:\WorkSpace\CalSum\.env) 文件：

```
# 服务器端口配置
PORT=8080

# 数据库路径配置
DB_PATH=./backend/database.sqlite

# JWT密钥配置（在生产环境中应使用更强的密钥）
JWT_SECRET=a_very_secure_jwt_secret_key_for_production
```

#### 方法二：使用系统环境变量

在启动应用前设置环境变量：

Linux/macOS:
```bash
export PORT=8080
export JWT_SECRET=a_very_secure_jwt_secret_key
npm run start
```

Windows:
```cmd
set PORT=8080
set JWT_SECRET=a_very_secure_jwt_secret_key
npm run start
```

### 3. 安装依赖

在服务器上安装所有依赖：

```bash
# 安装所有依赖（前端、后端）
npm run install-all
```

### 4. 启动生产服务

```bash
# 启动生产服务器
npm run start
```

服务器将在配置的端口上运行（默认 http://localhost:8080）

## 服务器配置

### 端口配置

- 默认端口：从环境变量 [PORT](file://d:\WorkSpace\CalSum\backend\server.js#L621-L621) 读取，默认 8080
- 如需修改，请编辑 [.env](file:///d:\WorkSpace\CalSum\.env) 文件中的端口设置

### 数据库配置

- 使用 SQLite 数据库：通过 `DB_PATH` 环境变量指定
- 数据库连接池：默认配置已优化用于生产环境

### 静态文件服务

- 前端构建文件：`backend/dist/`
- 所有静态资源通过 Express 的 `static` 中间件提供服务
- 支持前端路由的通配符处理

## 环境变量说明

以下是可用的环境变量：

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `PORT` | 服务器监听端口 | 8080 |
| `DB_PATH` | 数据库文件路径 | ./backend/database.sqlite |
| `JWT_SECRET` | JWT 令牌密钥 | your_default_secret_key |

## 安全注意事项

- **不要**将包含敏感信息的 [.env](file:///d:\WorkSpace\CalSum\.env) 文件提交到版本控制系统
- 在生产环境中使用强随机的 JWT 密钥
- 定期轮换密钥
- 确保数据库文件不在公共可访问目录中
- 限制对服务器的 SSH 访问
- 定期备份数据

### 环境变量安全

- 使用足够长且随机的 JWT 密钥（至少32个字符）
- 在生产环境中，考虑使用专门的密钥管理系统
- 定期更新敏感密钥

## 守护进程配置（推荐）

为了在生产环境中保持服务持续运行，建议使用以下任一工具：

### 使用 PM2

```bash
# 安装 PM2
npm install -g pm2

# 启动应用
pm2 start scripts/start-server.js --name "calsum-app"

# 查看应用状态
pm2 status

# 查看应用日志
pm2 logs calsum-app
```

### 使用 systemd（Linux）

创建 systemd 服务文件 `/etc/systemd/system/calsum.service`：

```
[Unit]
Description=CalSum Application
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/path/to/calsum
ExecStart=/usr/bin/npm run start
Restart=always
RestartSec=10
Environment=PORT=8080
Environment=JWT_SECRET=your_prod_secret_here

[Install]
WantedBy=multi-user.target
```

启用并启动服务：

```bash
sudo systemctl enable calsum
sudo systemctl start calsum
```

## 数据备份与恢复

### 备份数据库

定期备份 SQLite 数据库文件：

```bash
cp backend/database.sqlite /backup/location/database-backup-$(date +%Y%m%d).sqlite
```

### 恢复数据库

停止服务，替换数据库文件，重启服务：

```bash
# 停止服务
npm run stop  # 如果有停止脚本

# 或使用 PM2
pm2 stop calsum-app

# 替换数据库文件
cp /backup/location/database-backup-date.sqlite backend/database.sqlite

# 重启服务
npm run start
# 或使用 PM2
pm2 start scripts/start-server.js --name "calsum-app"
```

## 监控与日志

### 应用日志

- 应用程序日志输出到控制台
- 使用 PM2 时可通过 `pm2 logs` 查看

### 性能监控

- 监控内存使用情况（正常情况下应低于 200MB）
- 监控 CPU 使用率
- 监控响应时间

## 故障排除

### 服务无法启动

1. 检查端口是否已被占用
2. 检查数据库文件权限
3. 确认依赖项已正确安装

### 前端资源加载失败

1. 确认 `backend/dist/` 目录存在且包含前端构建文件
2. 检查 Express 静态文件中间件配置

### 数据库连接问题

1. 确认数据库文件存在且可写
2. 检查文件权限设置

## 版本升级

### 升级步骤

1. 备份当前数据库
2. 下载新版本代码
3. 安装新版本依赖
4. 根据需要更新环境变量配置
5. 构建前端
6. 重启服务

```bash
# 备份数据库
cp backend/database.sqlite backup-database.sqlite

# 停止当前服务
pm2 stop calsum-app  # 或其他停止方式

# 拉取新版本代码
git pull origin master

# 重新安装依赖
npm run install-all

# 根据需要更新环境变量
# 编辑 .env 文件或设置系统环境变量

# 重新构建
npm run build

# 启动服务
npm run start
# 或使用 PM2
pm2 start scripts/start-server.js --name "calsum-app"
```