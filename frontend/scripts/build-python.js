#!/usr/bin/env node
// Cross-platform Python build script
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const isWindows = process.platform === 'win32';
const scriptPath = path.join(__dirname, '..', 'build-python.sh');

// Check if Python executables already exist
const externalsDir = path.join(__dirname, '..', 'externals', 'python');
const windowInspectorExe = path.join(externalsDir, 'window_inspector', 'dist', 'window_inspector', 'window_inspector');
const windowCaptureExe = path.join(externalsDir, 'window_capture', 'dist', 'window_capture', 'window_capture');

const windowInspectorExists = fs.existsSync(windowInspectorExe);
const windowCaptureExists = fs.existsSync(windowCaptureExe);

if (windowInspectorExists && windowCaptureExists) {
  console.log('✅ Python executables already exist, skipping build.');
  process.exit(0);
}

console.log('🚀 Starting Python build process...');

try {
  if (isWindows) {
    // On Windows, try to use Git Bash (sh) if available
    // Otherwise, try to run with WSL or skip
    try {
      execSync('sh build-python.sh', {
        cwd: path.dirname(scriptPath),
        stdio: 'inherit',
        shell: true
      });
    } catch (error) {
      console.log('⚠️  Warning: Could not run build-python.sh on Windows.');
      console.log('   This usually requires Git Bash or WSL.');
      console.log('   If Python executables are already built, you can continue.');
      console.log('   Otherwise, please install Git Bash and try again.');
      // Don't exit with error, allow build to continue
      process.exit(0);
    }
  } else {
    // On Unix-like systems, use bash directly
    execSync('bash build-python.sh', {
      cwd: path.dirname(scriptPath),
      stdio: 'inherit'
    });
  }
  console.log('✅ Python build completed successfully!');
} catch (error) {
  console.error('❌ Python build failed:', error.message);
  console.log('⚠️  Build will continue, but Python features may not work.');
  // Exit with success to allow build to continue
  process.exit(0);
}

