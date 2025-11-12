#!/bin/bash

# Comprehensive PowerDNS Authentication Test
# Tests the complete NDash -> PowerDNS authentication flow

echo "=========================================="
echo "PowerDNS Authentication Test Suite"
echo "=========================================="
echo ""

BASE_URL="http://localhost:3000"
PDNS_URL="http://localhost:8081"
API_KEY="Bijikuda100"

echo "1. Testing PowerDNS API Direct Access..."
echo "   GET ${PDNS_URL}/api/v1/servers"

PDNS_RESPONSE=$(curl -s -w "HTTPSTATUS:%{http_code}" -H "X-API-Key: ${API_KEY}" "${PDNS_URL}/api/v1/servers")
PDNS_HTTP_CODE=$(echo "$PDNS_RESPONSE" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
PDNS_BODY=$(echo "$PDNS_RESPONSE" | sed -e 's/HTTPSTATUS:.*//g')

if [ "$PDNS_HTTP_CODE" -eq 200 ]; then
    echo "✓ PowerDNS API accessible (HTTP 200)"
    if echo "$PDNS_BODY" | grep -q "localhost"; then
        echo "✓ Server information retrieved"
    else
        echo "⚠ Unexpected response format"
    fi
else
    echo "✗ PowerDNS API failed (HTTP ${PDNS_HTTP_CODE})"
    echo "   Response: ${PDNS_BODY}"
    exit 1
fi

echo ""
echo "2. Testing NDash Server Environment..."
echo "   Checking if .env variables are loaded"

cd /opt/ndash
NODE_ENV=development node -e "
require('dotenv').config();
console.log('PDNS_API_URL:', process.env.PDNS_API_URL || 'NOT SET');
console.log('PDNS_API_KEY:', process.env.PDNS_API_KEY ? '***' + process.env.PDNS_API_KEY.slice(-4) : 'NOT SET');
" 2>/dev/null

echo ""
echo "3. Testing NDash API Endpoint..."
echo "   GET ${BASE_URL}/api/servers/localhost/zones"

NDASH_RESPONSE=$(curl -s -w "HTTPSTATUS:%{http_code}" "${BASE_URL}/api/servers/localhost/zones")
NDASH_HTTP_CODE=$(echo "$NDASH_RESPONSE" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
NDASH_BODY=$(echo "$NDASH_RESPONSE" | sed -e 's/HTTPSTATUS:.*//g')

if [ "$NDASH_HTTP_CODE" -eq 200 ]; then
    echo "✓ NDash API accessible (HTTP 200)"
    if [ "$NDASH_BODY" = "[]" ]; then
        echo "✓ Empty zones array (expected - no zones configured)"
    else
        echo "✓ Response: ${NDASH_BODY}"
    fi
else
    echo "✗ NDash API failed (HTTP ${NDASH_HTTP_CODE})"
    echo "   Response: ${NDASH_BODY}"
fi

echo ""
echo "4. Checking PowerDNS Logs for Authentication Errors..."
echo "   Recent authentication failures:"

AUTH_ERRORS=$(journalctl -u pdns --since "5 minutes ago" --no-pager 2>/dev/null | grep -c "Authentication by API Key failed" || echo "0")
if [ "$AUTH_ERRORS" -gt 0 ]; then
    echo "⚠ Found ${AUTH_ERRORS} authentication failure(s) in recent logs"
    echo "   Check PowerDNS webserver-allow-from configuration"
else
    echo "✓ No recent authentication failures"
fi

echo ""
echo "5. Testing Dashboard Page Load..."
echo "   GET ${BASE_URL}/"

DASHBOARD_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${BASE_URL}/")
if [ "$DASHBOARD_CODE" -eq 200 ]; then
    echo "✓ Dashboard page loads (HTTP 200)"
else
    echo "✗ Dashboard page failed (HTTP ${DASHBOARD_CODE})"
fi

echo ""
echo "6. Configuration Summary:"
echo "   PowerDNS API URL: ${PDNS_URL}"
echo "   PowerDNS API Key: ***${API_KEY: -4}"
echo "   NDash Server: ${BASE_URL}"
echo "   PowerDNS webserver-allow-from: $(grep 'webserver-allow-from' /etc/powerdns/pdns.conf | cut -d'=' -f2)"

echo ""
echo "=========================================="
if [ "$PDNS_HTTP_CODE" -eq 200 ] && [ "$NDASH_HTTP_CODE" -eq 200 ] && [ "$AUTH_ERRORS" -eq 0 ]; then
    echo "✅ ALL TESTS PASSED - Authentication working correctly!"
else
    echo "❌ Some tests failed - Check configuration above"
fi
echo "=========================================="

# Cleanup
rm -f /tmp/ndash-test-* 2>/dev/null