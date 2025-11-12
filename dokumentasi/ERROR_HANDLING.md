# Error Handling Implementation

## Overview

NDash implements comprehensive client-side error handling to provide a better user experience when PowerDNS API is unavailable or returns errors.

## Components

### 1. Error Banner

Located in `views/index.ejs`, the error banner appears at the top of the dashboard when data loading fails.

**Features:**
- Smooth slide-down animation using Alpine.js transitions
- Detailed error message from backend
- Helpful instructions for troubleshooting
- Retry button to attempt reconnection
- Close button to dismiss the banner

**Visual Design:**
- Red accent color (destructive theme)
- Left border for emphasis
- Icon indicators (alert-circle)
- Responsive layout

### 2. Enhanced loadData() Function

The `loadData()` function in the dashboard Alpine.js component handles multiple error scenarios:

```javascript
async loadData() {
  this.loading = true;
  this.error.show = false; // Hide previous errors
  
  try {
    const response = await fetch(`/api/servers/${this.serverId}/zones`);
    
    // Handle non-2xx HTTP responses
    if (!response.ok) {
      let errBody = { error: response.statusText };
      try { errBody = await response.json(); } catch (e) { /* ignore */ }
      
      this.error.message = errBody.error || `Server returned ${response.status}`;
      this.error.show = true;
      // Reset UI to safe state
      this.zones = [];
      this.stats.serverStatus = 'Error';
      return;
    }
    
    // Validate data format
    const data = await response.json();
    if (!Array.isArray(data)) {
      this.error.message = 'Received invalid data format from server';
      this.error.show = true;
      return;
    }
    
    // Update UI with valid data
    this.zones = data;
    this.stats.serverStatus = 'Online';
    
  } catch (error) {
    // Network or parsing errors
    this.error.message = error.message || 'Network error occurred';
    this.error.show = true;
    this.stats.serverStatus = 'Offline';
  } finally {
    this.loading = false;
  }
}
```

### 3. Server Status Indicator

The server status card dynamically changes color based on connection state:

- **Online** (Green): Successfully connected to PowerDNS API
- **Error** (Red): HTTP error from backend
- **Offline** (Red): Network error or connection refused

```html
<p class="text-3xl font-bold mt-2" 
   :class="{
     'text-green-600': stats.serverStatus === 'Online',
     'text-destructive': stats.serverStatus === 'Error' || stats.serverStatus === 'Offline'
   }"
   x-text="stats.serverStatus"></p>
```

## Error Types Handled

### 1. Network Errors
**Cause:** Backend server not running, network disconnected  
**Error Message:** "Network error occurred while fetching data"  
**Status:** Offline

### 2. HTTP Errors (4xx, 5xx)
**Cause:** Backend or PowerDNS API returns error response  
**Error Message:** Actual error from backend (e.g., "read ECONNRESET")  
**Status:** Error

### 3. Data Format Errors
**Cause:** API returns non-array data when array is expected  
**Error Message:** "Received invalid data format from server"  
**Status:** Error

### 4. PowerDNS API Connectivity
**Cause:** PowerDNS API not running or incorrect credentials  
**Backend Error:** "read ECONNRESET" or "Unauthorized"  
**Status:** Error

## Testing

### Manual Testing

1. **Test with API Down:**
```bash
# Stop PowerDNS
systemctl stop pdns
# Open dashboard - should show error banner
```

2. **Test with Invalid API Key:**
```bash
# Edit .env and set wrong API key
PDNS_API_KEY=wrong-key
# Restart NDash
npm start
# Open dashboard - should show Unauthorized error
```

3. **Test with Wrong API URL:**
```bash
# Edit .env
PDNS_API_URL=http://invalid-host:8081
# Restart NDash
# Open dashboard - should show connection error
```

### Automated Testing

Open the test file in browser:
```bash
file:///opt/ndash/test-error-banner.html
```

This standalone HTML file demonstrates:
- Error banner appearance/disappearance
- Different error messages
- Retry functionality
- Server status color changes

## Future Improvements

1. **Toast Notifications:** Add temporary toast for successful operations
2. **Retry Logic:** Automatic retry with exponential backoff
3. **Health Check:** Periodic background health checks
4. **Error Logging:** Send errors to monitoring service
5. **Offline Mode:** Cache data for offline viewing

## Files Modified

- `views/index.ejs` - Added error banner HTML and updated loadData()
- `README.md` - Documented error handling features
- `test-error-banner.html` - Standalone test file

## Dependencies

No additional dependencies required. Uses existing:
- Alpine.js (reactive state)
- Tailwind CSS (styling)
- Lucide Icons (icons)
