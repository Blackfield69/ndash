# Settings Page - User Guide

## Overview
The Settings page provides configuration options for the NDash dashboard and displays important system information about your PowerDNS server.

## Sections

### 1. Server Information
Displays real-time information about your PowerDNS server:

- **Server Name**: The name of your PowerDNS server instance
- **Server ID**: Unique identifier for the server (usually "localhost")
- **Server Type**: Type of PowerDNS server (Native, Master, Slave, etc.)
- **Status**: Current connection status to the PowerDNS API
  - Green badge: Server is online and responding
  - Red badge: Server is offline or unreachable

### 2. PowerDNS Configuration
Read-only settings that show your current PowerDNS API configuration:

- **API Server URL**: PowerDNS API endpoint (e.g., http://localhost:8001)
- **API Key**: Your PowerDNS API authentication key (masked for security)
- **Server ID**: The server ID being used for API calls

**Note**: These settings are read-only and configured through environment variables.

### 3. Application Settings
Configurable options for the NDash dashboard:

#### Auto-Refresh Interval
- **Default**: 30 seconds
- **Range**: 5 - 300 seconds
- **Purpose**: Controls how often data automatically refreshes on pages like Statistics and Zones
- **Example**: Set to 60 seconds to refresh statistics every minute

#### Dark Mode
- **Default**: Off (Light theme)
- **Purpose**: Enable dark theme for reduced eye strain
- **Storage**: Saved in browser's localStorage

#### Enable Notifications
- **Default**: On
- **Purpose**: Show notification toasts for important events and actions
- **Storage**: Saved in browser's localStorage

**Saving Settings**:
- Click "Save Settings" button to persist changes to localStorage
- Settings will persist across browser sessions
- Click "Reset to Defaults" to restore original configuration

### 4. Maintenance

#### Clear Cache
- **Purpose**: Remove all cached data from browser storage
- **Use When**:
  - You suspect stale data is being displayed
  - You want to refresh all DNS zone information
  - You're troubleshooting display issues
- **Warning**: This will force reload all data on next page visit

#### Application Version
- Shows current NDash version and build information
- Currently: v1.0.0

### 5. About
Information about NDash, including:

- **Project Description**: Modern PowerDNS management dashboard
- **Key Features**: Complete list of dashboard capabilities
- **Technology Stack**: Technologies and frameworks used
- **Useful Links**: Links to GitHub repository and PowerDNS official site

## Features

### Settings Persistence
- Application settings are saved in browser's localStorage
- Settings persist across browser sessions
- Each browser/device has separate settings

### Data Storage
Settings are stored as JSON in browser's localStorage under key: `ndash-settings`

Example:
```json
{
  "autoRefresh": 30,
  "darkMode": false,
  "notifications": true
}
```

### Server Information Refresh
- Server information is fetched on page load from `/api/servers` endpoint
- Shows current status of PowerDNS server connection
- Automatically detects if server is online/offline

## How to Use

### 1. Change Auto-Refresh Interval
1. Go to Settings page
2. Find "Application Settings" section
3. Modify "Auto-Refresh Interval" value (5-300 seconds)
4. Click "Save Settings"

### 2. Enable Dark Mode
1. Go to Settings page
2. Check the "Dark Mode" checkbox in Application Settings
3. Click "Save Settings"
4. Page theme will update (feature coming soon)

### 3. Manage Notifications
1. Go to Settings page
2. Check/uncheck "Enable Notifications" in Application Settings
3. Click "Save Settings"

### 4. Clear Cache
1. Go to Settings page
2. Navigate to "Maintenance" section
3. Click "Clear Cache" button
4. Confirm the action in the popup dialog
5. Page will show success message

### 5. Reset All Settings
1. Go to Settings page
2. Find "Application Settings" section
3. Click "Reset to Defaults" button
4. Confirm the reset action
5. All settings return to defaults

## Environment Configuration

Settings that require environment variables (configured during deployment):

| Variable | Purpose | Example |
|----------|---------|---------|
| `PDNS_API_URL` | PowerDNS API endpoint | http://localhost:8001 |
| `PDNS_API_KEY` | Authentication key | sOmE_aPi_KeY_123 |
| `NODE_ENV` | Application environment | production/development |
| `PORT` | Server port | 3000 |

These are displayed as read-only in the PowerDNS Configuration section.

## Browser Storage

### localStorage Keys
- `ndash-settings`: Stores application preferences (auto-refresh, dark mode, notifications)

### Clear Browser Data
To completely reset all settings:
1. Press F12 to open Developer Tools
2. Go to Application/Storage tab
3. Find localStorage
4. Delete `ndash-settings` entry
5. Refresh the page

## Troubleshooting

### Settings Not Saving
- **Cause**: Browser's localStorage is disabled or full
- **Solution**: 
  - Check browser privacy settings
  - Clear browser cache
  - Try a different browser
  - Check available storage space

### Server Shows Offline
- **Cause**: PowerDNS API is unreachable
- **Solution**:
  - Verify PowerDNS service is running
  - Check `PDNS_API_URL` is correct
  - Check `PDNS_API_KEY` is valid
  - Verify network connectivity

### Settings Revert on Refresh
- **Cause**: localStorage disabled or private browsing mode
- **Solution**:
  - Disable private browsing mode
  - Check browser privacy settings
  - Enable localStorage access for this domain

## Best Practices

1. **Auto-Refresh Interval**:
   - Use 30-60 seconds for normal monitoring
   - Use 10-15 seconds for intensive monitoring
   - Use 60-120 seconds for low-traffic monitoring

2. **Performance**:
   - Longer refresh intervals = better performance
   - Shorter refresh intervals = more up-to-date data

3. **Notifications**:
   - Keep enabled for important operations
   - Disable if notifications are distracting

4. **Caching**:
   - Only clear cache if you suspect stale data
   - Normal operation: cache improves performance

## API Endpoints

Settings page uses these API endpoints:

- `GET /api/servers` - Fetch all PowerDNS servers
- `GET /api/servers/localhost` - Get specific server info (implicit in server list)

No configuration changes are made through the API (all settings are browser-local).
