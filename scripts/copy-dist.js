const fs = require('fs-extra');
const path = require('path');

// Define source and destination paths
const frontendDistPath = path.join(__dirname, '..', 'frontend', 'dist');
const backendDistPath = path.join(__dirname, '..', 'backend', 'dist');

async function copyDist() {
  try {
    // Check if frontend dist directory exists
    if (!await fs.pathExists(frontendDistPath)) {
      console.error('Error: Frontend dist directory does not exist. Please run "npm run build" in the frontend directory first.');
      process.exit(1);
    }

    // Remove old backend dist directory if it exists
    if (await fs.pathExists(backendDistPath)) {
      await fs.remove(backendDistPath);
    }

    // Copy frontend dist to backend dist
    await fs.copy(frontendDistPath, backendDistPath);
    
    console.log('Successfully copied frontend dist to backend dist directory.');
  } catch (err) {
    console.error('Error copying dist directory:', err);
    process.exit(1);
  }
}

copyDist();