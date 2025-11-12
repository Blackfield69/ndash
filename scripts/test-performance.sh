#!/bin/bash

# Performance Test Script for NDash Dashboard
# Measures loading times and identifies bottlenecks

echo "=========================================="
echo "NDash Dashboard Performance Test"
echo "=========================================="
echo ""

BASE_URL="http://localhost:3000"
DASHBOARD_URL="${BASE_URL}/"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "1. Testing server response time..."
echo "   GET ${DASHBOARD_URL}"

# Measure server response time
START_TIME=$(date +%s.%3N)
HTTP_CODE=$(curl -s -o /tmp/ndash-perf-test.html -w "%{http_code}" "${DASHBOARD_URL}")
END_TIME=$(date +%s.%3N)
RESPONSE_TIME=$(echo "$END_TIME - $START_TIME" | bc)

if [ "$HTTP_CODE" -eq 200 ]; then
    echo -e "${GREEN}✓ Server responded in ${RESPONSE_TIME}s${NC}"

    # Check HTML size
    HTML_SIZE=$(stat -c%s /tmp/ndash-perf-test.html 2>/dev/null || stat -f%z /tmp/ndash-perf-test.html 2>/dev/null || echo "0")
    HTML_SIZE_KB=$(echo "scale=2; $HTML_SIZE / 1024" | bc)
    echo -e "${BLUE}ℹ HTML size: ${HTML_SIZE_KB} KB${NC}"

    # Check for performance issues
    if (( $(echo "$RESPONSE_TIME > 2.0" | bc -l) )); then
        echo -e "${RED}⚠ Slow server response (>2s)${NC}"
    else
        echo -e "${GREEN}✓ Fast server response${NC}"
    fi

    if (( $(echo "$HTML_SIZE_KB > 100" | bc -l) )); then
        echo -e "${YELLOW}⚠ Large HTML payload (>100KB)${NC}"
    else
        echo -e "${GREEN}✓ Reasonable HTML size${NC}"
    fi
else
    echo -e "${RED}✗ Server error: HTTP ${HTTP_CODE}${NC}"
    exit 1
fi

echo ""
echo "2. Analyzing HTML content for performance issues..."

# Check for blocking resources
EXTERNAL_SCRIPTS=$(grep -c "https://" /tmp/ndash-perf-test.html || echo "0")
echo -e "${BLUE}ℹ External scripts: ${EXTERNAL_SCRIPTS}${NC}"

if [ "$EXTERNAL_SCRIPTS" -gt 5 ]; then
    echo -e "${YELLOW}⚠ Many external scripts may slow loading${NC}"
fi

# Check for large inline scripts
INLINE_SCRIPT_SIZE=$(grep -o '<script>.*</script>' /tmp/ndash-perf-test.html | wc -c)
INLINE_SCRIPT_KB=$(echo "scale=2; $INLINE_SCRIPT_SIZE / 1024" | bc)
echo -e "${BLUE}ℹ Inline scripts: ${INLINE_SCRIPT_KB} KB${NC}"

if (( $(echo "$INLINE_SCRIPT_KB > 50" | bc -l) )); then
    echo -e "${YELLOW}⚠ Large inline scripts${NC}"
fi

# Check for Alpine.js bindings
ALPINE_BINDINGS=$(grep -c "x-" /tmp/ndash-perf-test.html || echo "0")
echo -e "${BLUE}ℹ Alpine.js bindings: ${ALPINE_BINDINGS}${NC}"

if [ "$ALPINE_BINDINGS" -gt 50 ]; then
    echo -e "${YELLOW}⚠ Many Alpine bindings may cause slow initial render${NC}"
fi

echo ""
echo "3. Testing API endpoint performance..."
API_URL="${BASE_URL}/api/servers/localhost/zones"

START_TIME=$(date +%s.%3N)
API_CODE=$(curl -s -o /tmp/ndash-api-test.json -w "%{http_code}" "${API_URL}")
END_TIME=$(date +%s.%3N)
API_TIME=$(echo "$END_TIME - $START_TIME" | bc)

if [ "$API_CODE" -eq 200 ]; then
    echo -e "${GREEN}✓ API responded in ${API_TIME}s${NC}"

    API_SIZE=$(stat -c%s /tmp/ndash-api-test.json 2>/dev/null || stat -f%z /tmp/ndash-api-test.json 2>/dev/null || echo "0")
    API_SIZE_KB=$(echo "scale=2; $API_SIZE / 1024" | bc)
    echo -e "${BLUE}ℹ API response: ${API_SIZE_KB} KB${NC}"

    if (( $(echo "$API_TIME > 1.0" | bc -l) )); then
        echo -e "${YELLOW}⚠ Slow API response (>1s)${NC}"
    else
        echo -e "${GREEN}✓ Fast API response${NC}"
    fi
else
    echo -e "${RED}✗ API error: HTTP ${API_CODE}${NC}"
fi

echo ""
echo "4. Performance Recommendations:"
echo ""

if (( $(echo "$RESPONSE_TIME > 1.0" | bc -l) )); then
    echo -e "${YELLOW}• Optimize server response time${NC}"
    echo "  - Check database queries"
    echo "  - Enable compression"
    echo "  - Use caching"
fi

if [ "$EXTERNAL_SCRIPTS" -gt 3 ]; then
    echo -e "${YELLOW}• Consider bundling external scripts${NC}"
    echo "  - Use local copies of CDN resources"
    echo "  - Implement lazy loading"
fi

if [ "$ALPINE_BINDINGS" -gt 30 ]; then
    echo -e "${YELLOW}• Optimize Alpine.js bindings${NC}"
    echo "  - Use x-show instead of v-if where possible"
    echo "  - Debounce expensive operations"
    echo "  - Use computed properties"
fi

if (( $(echo "$HTML_SIZE_KB > 50" | bc -l) )); then
    echo -e "${YELLOW}• Reduce HTML payload${NC}"
    echo "  - Minify HTML output"
    echo "  - Remove unnecessary whitespace"
    echo "  - Use CSS for styling instead of inline styles"
fi

echo ""
echo "5. Browser Performance Test:"
echo "   Open browser dev tools (F12) > Network tab"
echo "   Navigate to: ${DASHBOARD_URL}"
echo "   Look for:"
echo "   - Time to first paint"
echo "   - Time to interactive"
echo "   - Largest contentful paint"
echo "   - Any blocking resources"

echo ""
echo "=========================================="
echo "Test completed. Check recommendations above."
echo "=========================================="

# Cleanup
rm -f /tmp/ndash-perf-test.html /tmp/ndash-api-test.json