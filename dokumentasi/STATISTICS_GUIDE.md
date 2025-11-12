# Statistics Page - Features & Guide

## Overview
The Statistics page provides comprehensive monitoring and analysis of PowerDNS server performance and operational metrics.

## Features

### 1. Main Statistics Grid
- **Key Metrics Display**: Shows 6 most important statistics in grid view:
  - Backend Queries
  - Corrupt Packets
  - Query Cache Hit
  - Packet Cache Hit
  - Queue Size
  - Recursion Unanswered

- **Auto-refresh**: Data refreshes automatically every 30 seconds
- **Manual Refresh**: Click "Refresh" button to manually update

### 2. Detailed Statistics Section
Organized into 4 tabs for easy navigation:

#### Tab: All Statistics
- Complete list of all 111 PowerDNS statistics
- Shows statistic name and current value
- Search/filter functionality to find specific metrics

#### Tab: Queries
- Query-related statistics
- Includes: queries, questions, answers, recursion metrics
- Highlights top 3 metrics in mini cards

#### Tab: Cache
- Cache performance metrics
- Includes: query cache, packet cache, deferred operations
- Shows cache hit rates and sizes

#### Tab: Performance
- System performance metrics
- Includes: latency, CPU usage, uptime
- I/O wait, CPU steal, time metrics

### 3. Search & Filter
- Real-time search across all statistics
- Filter by statistic name or value
- Works across all tabs

## Key Metrics Explanation

### Query Statistics
- **backend-queries**: Total queries to backend database
- **query-cache-hit**: Number of cache hits
- **recursion-unanswered**: Recursive queries without answer

### Cache Statistics
- **packet-cache-hit**: Packet cache hit count
- **deferred-cache-***: Cache operations that were deferred
- **query-cache-***: Query cache operations

### Performance Metrics
- **backend-latency**: Response time from backend (ms)
- **cache-latency**: Cache lookup latency
- **cpu-iowait**: CPU time waiting for I/O
- **cpu-steal**: CPU stolen by hypervisor

### System Statistics
- **corrupt-packets**: Packets that failed to parse
- **qsize-q**: Current queue size
- **uptime**: Server uptime in seconds

## How to Use

### 1. View Current Statistics
- Navigate to Statistics from sidebar
- Automatically loads current server metrics
- Data updates every 30 seconds

### 2. Monitor Specific Metrics
1. Click on relevant tab (Queries, Cache, Performance)
2. Mini cards show top 3 metrics
3. Full table shows all related statistics

### 3. Search for Metrics
1. Use search box with keywords: "cache", "query", "latency", etc.
2. Results filter in real-time
3. Clear search box to reset

### 4. Manual Refresh
- Click "Refresh" button for immediate update
- Useful when monitoring specific event

## Auto-Refresh Feature
- Automatically refreshes data every 30 seconds
- Useful for continuous monitoring
- Background refresh won't interrupt your interaction

## Data Format
- All numeric values formatted with thousand separators for readability
- Example: `1000000` displays as `1,000,000`
- Values shown in current/accumulated format (varies by metric type)

## API Endpoint
The statistics page uses: `/api/servers/localhost/statistics`

This endpoint returns array of statistics objects:
```json
[
  {
    "name": "backend-queries",
    "type": "StatisticItem",
    "value": "465"
  },
  ...
]
```

## Performance Tips
- Use tabs to focus on specific metric categories
- Use search for finding specific statistics
- Check Performance tab to identify bottlenecks
- Monitor Cache tab for cache efficiency

## Common Metrics to Monitor

### Health Check
- Check backend-latency (should be low)
- Monitor corrupt-packets (should be 0 or very low)
- Verify qsize-q (queue shouldn't grow indefinitely)

### Performance Optimization
- Cache hit rates (query-cache-hit, packet-cache-hit)
- Latency metrics (backend-latency, cache-latency)
- CPU metrics (cpu-iowait, cpu-steal)

### Troubleshooting
- High corrupt-packets: Network issues or malformed queries
- High qsize-q: Server overloaded
- Low cache hits: May need to adjust cache settings
- High latency: Backend database performance issue
