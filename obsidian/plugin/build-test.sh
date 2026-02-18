#!/usr/bin/env bash
set -e

echo "🔨 Obsidian Plugin Build Test Script"
echo "======================================"
echo ""

# Check we're in the right directory
if [[ ! -f "package.json" ]]; then
    echo "❌ Error: Must run from provisioning/obsidian/plugin directory"
    exit 1
fi

echo "📦 Step 1: Clean previous build..."
rm -rf node_modules main.js main.js.map
echo "   ✓ Cleaned"
echo ""

echo "📥 Step 2: Install dependencies..."
export HOME=$(mktemp -d)
export npm_config_cache=$HOME/npm-cache
npm ci --ignore-scripts --no-audit --no-fund
echo "   ✓ Dependencies installed"
echo ""

echo "🔧 Step 3: Run build..."
npm run build
echo "   ✓ Build complete"
echo ""

echo "📋 Step 4: Check outputs..."
if [[ -f "main.js" ]]; then
    SIZE=$(ls -lh main.js | awk '{print $5}')
    echo "   ✓ main.js ($SIZE)"
else
    echo "   ❌ main.js not found!"
    exit 1
fi

if [[ -f "manifest.json" ]]; then
    echo "   ✓ manifest.json"
else
    echo "   ❌ manifest.json not found!"
    exit 1
fi

echo ""
echo "✅ Build successful!"
echo ""
echo "Files generated:"
ls -lh main.js manifest.json
