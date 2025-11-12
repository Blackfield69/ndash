#!/bin/bash

# Error Handling Test Script for NDash
# Tests various error scenarios to ensure error banner works correctly

echo "=========================================="
echo "NDash Error Handling Test Suite"
echo "=========================================="
echo ""

BASE_URL="http://localhost:3000"
API_URL="${BASE_URL}/api/servers/localhost/zones"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "1. Testing API endpoint availability..."
echo "   GET ${API_URL}"
echo ""

HTTP_CODE=$(curl -s -o /tmp/ndash-test-response.json -w "%{http_code}" "${API_URL}")

if [ "$HTTP_CODE" -eq 200 ]; then
    echo -e "${GREEN}✓ API returned 200 OK${NC}"
    RESPONSE=$(cat /tmp/ndash-test-response.json)
    echo "   Response: ${RESPONSE}"
    
    # Check if response is valid JSON array
    if echo "$RESPONSE" | jq empty 2>/dev/null; then
        echo -e "${GREEN}✓ Valid JSON response${NC}"
        
        # Check if it's an array
        if echo "$RESPONSE" | jq -e 'type == "array"' > /dev/null 2>&1; then
            COUNT=$(echo "$RESPONSE" | jq 'length')
            echo -e "${GREEN}✓ Response is array with ${COUNT} items${NC}"
            echo -e "${GREEN}✓ Error banner should NOT be visible${NC}"
        else
            echo -e "${YELLOW}⚠ Response is not an array${NC}"
            echo -e "${YELLOW}⚠ Error banner SHOULD be visible${NC}"
        fi
    else
        echo -e "${RED}✗ Invalid JSON response${NC}"
        echo -e "${YELLOW}⚠ Error banner SHOULD be visible${NC}"
    fi
elif [ "$HTTP_CODE" -eq 500 ]; then
    echo -e "${RED}✗ API returned 500 Internal Server Error${NC}"
    RESPONSE=$(cat /tmp/ndash-test-response.json)
    echo "   Response: ${RESPONSE}"
    echo -e "${YELLOW}⚠ Error banner SHOULD be visible with message:${NC}"
    echo "   $(echo $RESPONSE | jq -r '.error' 2>/dev/null || echo 'Unknown error')"
else
    echo -e "${RED}✗ API returned ${HTTP_CODE}${NC}"
    echo -e "${YELLOW}⚠ Error banner SHOULD be visible${NC}"
fi

echo ""
echo "2. Testing dashboard page..."
DASHBOARD_CODE=$(curl -s -o /tmp/ndash-dashboard.html -w "%{http_code}" "${BASE_URL}")

if [ "$DASHBOARD_CODE" -eq 200 ]; then
    echo -e "${GREEN}✓ Dashboard page loaded (${DASHBOARD_CODE})${NC}"
    
    # Check if error banner HTML exists
    if grep -q "Error Banner" /tmp/ndash-dashboard.html; then
        echo -e "${GREEN}✓ Error banner HTML present in page${NC}"
    else
        echo -e "${RED}✗ Error banner HTML NOT found${NC}"
    fi
    
    # Check if error state exists
    if grep -q "error.show" /tmp/ndash-dashboard.html; then
        echo -e "${GREEN}✓ Error state management code present${NC}"
    else
        echo -e "${RED}✗ Error state management NOT found${NC}"
    fi
    
    # Check if retry button exists
    if grep -q "Retry" /tmp/ndash-dashboard.html; then
        echo -e "${GREEN}✓ Retry button present${NC}"
    else
        echo -e "${RED}✗ Retry button NOT found${NC}"
    fi
else
    echo -e "${RED}✗ Dashboard page failed to load (${DASHBOARD_CODE})${NC}"
fi

echo ""
echo "3. Testing PowerDNS API direct connection..."
PDNS_URL=$(grep PDNS_API_URL .env 2>/dev/null | cut -d'=' -f2 | tr -d ' ')
PDNS_KEY=$(grep PDNS_API_KEY .env 2>/dev/null | cut -d'=' -f2 | tr -d ' ')

if [ -z "$PDNS_URL" ]; then
    PDNS_URL="http://localhost:8081"
fi

echo "   PowerDNS API: ${PDNS_URL}/api/v1/servers"

if [ -n "$PDNS_KEY" ]; then
    PDNS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -H "X-API-Key: ${PDNS_KEY}" "${PDNS_URL}/api/v1/servers")
else
    PDNS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${PDNS_URL}/api/v1/servers")
fi

if [ "$PDNS_CODE" -eq 200 ]; then
    echo -e "${GREEN}✓ PowerDNS API is accessible${NC}"
    echo -e "${GREEN}✓ Error banner should NOT be visible${NC}"
elif [ "$PDNS_CODE" -eq 401 ]; then
    echo -e "${YELLOW}⚠ PowerDNS API returned 401 Unauthorized${NC}"
    echo -e "${YELLOW}⚠ Check PDNS_API_KEY in .env file${NC}"
    echo -e "${YELLOW}⚠ Error banner SHOULD be visible${NC}"
elif [ "$PDNS_CODE" -eq 000 ]; then
    echo -e "${RED}✗ PowerDNS API is not reachable (connection refused)${NC}"
    echo -e "${YELLOW}⚠ Error banner SHOULD be visible with 'read ECONNRESET' or similar${NC}"
else
    echo -e "${RED}✗ PowerDNS API returned ${PDNS_CODE}${NC}"
    echo -e "${YELLOW}⚠ Error banner SHOULD be visible${NC}"
fi

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo ""
echo "Expected Behavior:"
echo "- If all tests pass: Dashboard shows data, no error banner"
echo "- If PowerDNS API fails: Dashboard shows error banner with retry button"
echo "- Server status card shows 'Online' (green) or 'Error/Offline' (red)"
echo ""
echo "Manual Testing:"
echo "1. Open browser: ${BASE_URL}"
echo "2. Check if error banner appears at top of dashboard"
echo "3. Click 'Retry' button to test retry functionality"
echo "4. Check server status card color (green = OK, red = Error)"
echo ""
echo "Test file for UI testing:"
echo "   file:///opt/ndash/test-error-banner.html"
echo ""

# Cleanup
rm -f /tmp/ndash-test-response.json /tmp/ndash-dashboard.html
