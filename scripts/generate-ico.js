// Simple script to note that ICO generation is needed
// electron-builder will generate ICO from PNG during build
// OR use an online tool like https://convertio.co/png-ico/ or https://redketchup.io/icon-converter
// Place the generated icon.ico in frontend/build/icon.ico

const fs = require('fs');
const path = require('path');

const iconPng = path.join(__dirname, '..', 'frontend', 'build', 'icon.png');
const iconIco = path.join(__dirname, '..', 'frontend', 'build', 'icon.ico');

console.log('Note: For Inno Setup, you need an ICO file.');
console.log('Option 1: Use electron-builder to build the app first, it will generate ICO files');
console.log('Option 2: Convert PNG to ICO using an online tool:');
console.log('  - https://convertio.co/png-ico/');
console.log('  - https://redketchup.io/icon-converter');
console.log('Then place the generated icon.ico in: frontend/build/icon.ico');
console.log('');
if (fs.existsSync(iconPng)) {
  console.log('✓ PNG icon found at:', iconPng);
} else {
  console.log('✗ PNG icon NOT found at:', iconPng);
}
if (fs.existsSync(iconIco)) {
  console.log('✓ ICO icon found at:', iconIco);
} else {
  console.log('✗ ICO icon NOT found at:', iconIco);
  console.log('   You need to create this file before building the installer.');
}

