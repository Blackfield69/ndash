#!/bin/bash

# Bundle external resources for better performance
# This script downloads and bundles CDN resources locally

echo "=========================================="
echo "NDash Resource Bundler"
echo "=========================================="
echo ""

BUNDLE_DIR="/opt/ndash/public/js"
mkdir -p "$BUNDLE_DIR"

echo "1. Downloading Alpine.js..."
curl -s -o "$BUNDLE_DIR/alpine.js" "https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"
if [ $? -eq 0 ]; then
    echo "✓ Alpine.js downloaded"
else
    echo "✗ Failed to download Alpine.js"
fi

echo ""
echo "2. Downloading Lucide icons..."
curl -s -o "$BUNDLE_DIR/lucide.js" "https://unpkg.com/lucide@latest/dist/umd/lucide.js"
if [ $? -eq 0 ]; then
    echo "✓ Lucide icons downloaded"
else
    echo "✗ Failed to download Lucide icons"
fi

echo ""
echo "3. Creating bundle info..."
cat > "$BUNDLE_DIR/bundle-info.json" << EOF
{
  "bundled": true,
  "timestamp": "$(date -Iseconds)",
  "resources": [
    {
      "name": "Alpine.js",
      "url": "https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js",
      "local": "/js/alpine.js",
      "size": "$(stat -c%s "$BUNDLE_DIR/alpine.js" 2>/dev/null || echo "0")"
    },
    {
      "name": "Lucide Icons",
      "url": "https://unpkg.com/lucide@latest/dist/umd/lucide.js",
      "local": "/js/lucide.js",
      "size": "$(stat -c%s "$BUNDLE_DIR/lucide.js" 2>/dev/null || echo "0")"
    }
  ]
}
EOF

echo "✓ Bundle info created"

echo ""
echo "4. To use bundled resources, update views/partials/header.ejs:"
echo "   Replace CDN URLs with local paths:"
echo "   - https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js → /js/alpine.js"
echo "   - https://unpkg.com/lucide@latest → /js/lucide.js"
echo ""
echo "   And add integrity checks for production use."

echo ""
echo "=========================================="
echo "Bundling completed!"
echo "=========================================="