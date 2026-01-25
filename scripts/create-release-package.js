const fs = require('fs');
const path = require('path');
const fse = require('fs-extra'); // 需要确保已安装fs-extra

// 确保发布目录存在
const releaseDir = path.join(__dirname, '..', 'release');
if (!fs.existsSync(releaseDir)) {
  fs.mkdirSync(releaseDir, { recursive: true });
}

// 清空之前的发布目录
fse.emptyDirSync(releaseDir);

console.log('开始创建发布包...');

// 源目录和目标目录
const sourceRoot = path.join(__dirname, '..');
const targetRoot = releaseDir;

// 复制根目录文件
const rootFiles = ['.env.example', 'README.md', 'DEPLOYMENT.md', 'package.json', 'package-lock.json'];
rootFiles.forEach(file => {
  const sourcePath = path.join(sourceRoot, file);
  if (fs.existsSync(sourcePath)) {
    fse.copySync(sourcePath, path.join(targetRoot, file));
    console.log(`已复制: ${file}`);
  }
});

// 创建发布用的 .env 文件模板
const envTemplate = `# CalSum 生产环境配置
# 请在服务器上根据实际情况修改此文件

# 服务器端口配置
PORT=8080

# 数据库路径配置
DB_PATH=./backend/database.sqlite

# JWT密钥配置（在生产环境中应使用更强的密钥）
JWT_SECRET=your_strong_production_secret_key_here

# 日志级别
LOG_LEVEL=info
`;

const envPath = path.join(targetRoot, '.env');
fs.writeFileSync(envPath, envTemplate);
console.log('已创建 .env 配置模板');

// 复制 backend 目录
const backendSource = path.join(sourceRoot, 'backend');
const backendTarget = path.join(targetRoot, 'backend');
if (fs.existsSync(backendSource)) {
  fse.copySync(backendSource, backendTarget);
  console.log('已复制: backend 目录');
}

// 复制 scripts 目录
const scriptsSource = path.join(sourceRoot, 'scripts');
const scriptsTarget = path.join(targetRoot, 'scripts');
if (fs.existsSync(scriptsSource)) {
  // 只复制必要的脚本文件
  const scriptsToCopy = ['start-server.js'];
  if (!fs.existsSync(scriptsTarget)) {
    fs.mkdirSync(scriptsTarget, { recursive: true });
  }
  scriptsToCopy.forEach(script => {
    const sourceScript = path.join(scriptsSource, script);
    if (fs.existsSync(sourceScript)) {
      fse.copySync(sourceScript, path.join(scriptsTarget, script));
      console.log(`已复制: scripts/${script}`);
    }
  });
}

// 检查前端构建产物是否存在
const frontendDist = path.join(backendTarget, 'dist');
if (!fs.existsSync(frontendDist) || fs.readdirSync(frontendDist).length === 0) {
  console.log('警告: 前端构建产物不存在或为空，请先运行 npm run build');
  console.log('提示: 在服务器上运行 "npm run build" 来构建前端并复制到后端');
} else {
  console.log('前端构建产物已包含在发布包中');
}

// 创建部署说明
const deployInstructions = `# CalSum 部署说明

## 部署步骤

1. 将此包解压到目标目录
2. 根据服务器环境修改 .env 文件中的配置
3. 安装依赖: npm run install-all
4. 启动应用: npm run start

## 环境配置

请根据生产环境修改 .env 文件中的配置:
- PORT: 服务器监听端口
- DB_PATH: 数据库文件路径
- JWT_SECRET: JWT 加密密钥（请使用强密钥）

## 服务管理

- 启动服务: npm run start
- 查看日志: 服务日志将输出到控制台
- 使用 PM2 管理进程 (推荐): 
  - 安装: npm install -g pm2
  - 启动: pm2 start scripts/start-server.js --name "calsum-app"
  - 状态: pm2 status
  - 日志: pm2 logs

## 注意事项

- 首次部署时，系统会自动创建数据库文件
- 生产环境中请使用强密码的 JWT_SECRET
- 定期备份 database.sqlite 数据库文件
`;

const deployInstructionPath = path.join(targetRoot, 'DEPLOY_INSTRUCTIONS.txt');
fs.writeFileSync(deployInstructionPath, deployInstructions);
console.log('已创建部署说明文件');

// 计算发布包大小
const getDirSize = (dir) => {
  let size = 0;
  const walk = (dir) => {
    const files = fs.readdirSync(dir);
    for (const file of files) {
      const filePath = path.join(dir, file);
      const stat = fs.statSync(filePath);
      if (stat.isDirectory()) {
        walk(filePath);
      } else {
        size += stat.size;
      }
    }
  };
  walk(dir);
  return size;
};

const sizeInMB = (getDirSize(releaseDir) / (1024 * 1024)).toFixed(2);
console.log(`\n发布包创建完成!\n位置: ${releaseDir}\n大小: ${sizeInMB} MB`);

console.log('\n发布包内容:');
const listDir = (dir, prefix = '') => {
  const items = fs.readdirSync(dir);
  items.forEach(item => {
    const itemPath = path.join(dir, item);
    const stat = fs.statSync(itemPath);
    if (stat.isDirectory()) {
      console.log(`${prefix}📁 ${item}/`);
      listDir(itemPath, prefix + '  ');
    } else {
      const size = (stat.size / 1024).toFixed(2);
      console.log(`${prefix}📄 ${item} (${size} KB)`);
    }
  });
};
listDir(releaseDir);