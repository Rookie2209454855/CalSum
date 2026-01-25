const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

// Determine the operating system
const os = require('os');
const platform = os.platform();

function startServer() {
  console.log('Starting CalSum fullstack application...');
  
  // 读取根目录的 .env 文件并设置环境变量
  const envFilePath = path.join(__dirname, '..', '.env');
  if (fs.existsSync(envFilePath)) {
    const envContent = fs.readFileSync(envFilePath, 'utf8');
    envContent.split('\n').forEach(line => {
      if (line.trim() && !line.startsWith('#')) {
        const [key, ...value] = line.split('=');
        if (key && value) {
          process.env[key.trim()] = value.join('=').trim();
        }
      }
    });
  }
  
  // Change to backend directory and start the server
  const backendPath = path.join(__dirname, '..', 'backend');
  
  let serverProcess;
  
  if (platform === 'win32') {
    // On Windows
    serverProcess = spawn('node', ['server.js'], {
      cwd: backendPath,
      stdio: 'inherit',
      shell: true,
      env: process.env  // 传递当前进程的环境变量
    });
  } else {
    // On Unix-like systems (Linux, macOS)
    serverProcess = spawn('node', ['server.js'], {
      cwd: backendPath,
      stdio: 'inherit',
      env: process.env  // 传递当前进程的环境变量
    });
  }
  
  serverProcess.on('error', (err) => {
    console.error('Failed to start server:', err);
  });
  
  serverProcess.on('close', (code) => {
    console.log(`Server process exited with code ${code}`);
  });
}

startServer();