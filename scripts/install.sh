#!/bin/bash

# NDash Installation Script
# This script helps you set up NDash PowerDNS Dashboard

set -e

echo "================================================"
echo "NDash - PowerDNS Admin Dashboard Installation"
echo "================================================"
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed!"
    echo "Please install Node.js v16 or higher from https://nodejs.org/"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 16 ]; then
    echo "❌ Node.js version is too old (v$NODE_VERSION)"
    echo "Please upgrade to Node.js v16 or higher"
    exit 1
fi

echo "✅ Node.js $(node -v) detected"

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed!"
    exit 1
fi

echo "✅ npm $(npm -v) detected"
echo ""

# Install dependencies
echo "📦 Installing dependencies..."
npm install

echo ""
echo "✅ Dependencies installed successfully!"
echo ""

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cp .env.example .env
    echo "✅ .env file created from .env.example"
    echo ""
    echo "⚠️  IMPORTANT: Please edit .env file and configure:"
    echo "   - PDNS_API_URL: Your PowerDNS API URL"
    echo "   - PDNS_API_KEY: Your PowerDNS API key"
    echo "   - SESSION_SECRET: A random secret key"
    echo ""
else
    echo "ℹ️  .env file already exists"
    echo ""
fi

# Create public directories if they don't exist
mkdir -p public/css
mkdir -p public/js

echo "================================================"
echo "🎉 Installation complete!"
echo "================================================"
echo ""
echo "Next steps:"
echo "1. Edit .env file: nano .env"
echo "2. Configure your PowerDNS API settings"
echo "3. Start the application:"
echo "   - Development: npm run dev"
echo "   - Production:  npm start"
echo ""
echo "The dashboard will be available at http://localhost:3000"
echo ""
echo "For more information, see README.md"
echo ""
