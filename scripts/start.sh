#!/bin/bash

# NDash Startup Script
# Quick launcher for NDash PowerDNS Dashboard

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print banner
echo -e "${BLUE}"
cat << "EOF"
   _   _  ____             _     
  | \ | ||  _ \  __ _ ___| |__  
  |  \| || | | |/ _` / __| '_ \ 
  | |\  || |_| | (_| \__ \ | | |
  |_| \_||____/ \__,_|___/_| |_|
                                
  PowerDNS Admin Dashboard v1.0.0
EOF
echo -e "${NC}"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  Warning: .env file not found!${NC}"
    echo -e "Creating from .env.example..."
    cp .env.example .env
    echo -e "${GREEN}✅ .env file created${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Please edit .env and configure:${NC}"
    echo "   - PDNS_API_URL"
    echo "   - PDNS_API_KEY"
    echo "   - SESSION_SECRET"
    echo ""
    read -p "Press Enter to edit .env now, or Ctrl+C to exit..."
    ${EDITOR:-nano} .env
fi

# Check if node_modules exists
if [ ! -d node_modules ]; then
    echo -e "${YELLOW}📦 Installing dependencies...${NC}"
    npm install
    echo -e "${GREEN}✅ Dependencies installed${NC}"
    echo ""
fi

# Check if PowerDNS API is accessible (optional check)
if [ -f .env ]; then
    source .env
    if [ ! -z "$PDNS_API_URL" ] && [ ! -z "$PDNS_API_KEY" ]; then
        echo -e "${BLUE}🔍 Testing PowerDNS API connection...${NC}"
        if curl -s -f -H "X-API-Key: $PDNS_API_KEY" "$PDNS_API_URL/api/v1/servers" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ PowerDNS API is accessible${NC}"
        else
            echo -e "${YELLOW}⚠️  Cannot connect to PowerDNS API${NC}"
            echo -e "   URL: $PDNS_API_URL"
            echo -e "   Make sure PowerDNS is running and API is enabled"
        fi
        echo ""
    fi
fi

# Ask which mode to run
echo -e "${BLUE}Select startup mode:${NC}"
echo "1) Development (with auto-reload)"
echo "2) Production"
echo "3) Exit"
echo ""
read -p "Enter choice [1-3]: " choice

case $choice in
    1)
        echo ""
        echo -e "${GREEN}🚀 Starting NDash in development mode...${NC}"
        echo -e "${BLUE}📍 Dashboard will be available at: http://localhost:${PORT:-3000}${NC}"
        echo ""
        npm run dev
        ;;
    2)
        echo ""
        echo -e "${GREEN}🚀 Starting NDash in production mode...${NC}"
        echo -e "${BLUE}📍 Dashboard will be available at: http://localhost:${PORT:-3000}${NC}"
        echo ""
        npm start
        ;;
    3)
        echo -e "${YELLOW}👋 Goodbye!${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}❌ Invalid choice${NC}"
        exit 1
        ;;
esac
