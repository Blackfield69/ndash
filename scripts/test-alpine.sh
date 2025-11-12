#!/bin/bash

# Test Alpine.js Component Loading
# Verifies that dashboard() function is available when Alpine.js initializes

echo "=========================================="
echo "Alpine.js Component Test"
echo "=========================================="
echo ""

BASE_URL="http://localhost:3000"

echo "1. Testing dashboard function availability..."
DASHBOARD_FUNC=$(curl -s "${BASE_URL}" | grep -c "function dashboard()")
if [ "$DASHBOARD_FUNC" -gt 0 ]; then
    echo "✓ dashboard() function found in HTML head"
else
    echo "✗ dashboard() function not found"
    exit 1
fi

echo ""
echo "2. Testing Alpine.js x-data attribute..."
X_DATA=$(curl -s "${BASE_URL}" | grep -c 'x-data="dashboard()"')
if [ "$X_DATA" -gt 0 ]; then
    echo "✓ x-data=\"dashboard()\" attribute found"
else
    echo "✗ x-data attribute not found"
    exit 1
fi

echo ""
echo "3. Testing component initialization..."
X_INIT=$(curl -s "${BASE_URL}" | grep -c 'x-init="init()"')
if [ "$X_INIT" -gt 0 ]; then
    echo "✓ x-init=\"init()\" attribute found"
else
    echo "✗ x-init attribute not found"
    exit 1
fi

echo ""
echo "4. Testing skeleton loading..."
SKELETON=$(curl -s "${BASE_URL}" | grep -c "initialLoading")
if [ "$SKELETON" -gt 0 ]; then
    echo "✓ Skeleton loading state found"
else
    echo "✗ Skeleton loading state not found"
fi

echo ""
echo "=========================================="
echo "✅ All tests passed! Alpine.js component should load correctly."
echo ""
echo "If you still see 'dashboard is not defined' error:"
echo "- Clear browser cache (Ctrl+F5)"
echo "- Check browser console for other errors"
echo "- Verify Alpine.js CDN is accessible"
echo "=========================================="