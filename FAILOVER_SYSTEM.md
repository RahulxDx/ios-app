# 🔄 Backend Failover System

## Overview

Your Stellantis Dealer Hygiene app now has **automatic failover** capabilities for high availability across two AWS EC2 regions:

- **Primary Region**: Singapore (ap-southeast-1) - `http://13.221.127.254`
- **Secondary Region**: Mumbai (ap-south-1) - `http://13.201.56.162`

## How It Works

### Automatic Failover

The app automatically switches between backend regions when failures occur:

```
1. App makes API request to PRIMARY backend
2. If PRIMARY fails after retries → Switch to SECONDARY
3. If SECONDARY fails → Switch back to PRIMARY
4. Both backends tried before giving up
```

### Health Checks

Both backends are continuously monitored via their `/health` endpoints:

```
GET http://13.221.127.254/health
GET http://13.201.56.162/health

Expected Response: {"status": "ok"}
```

## Configuration

### api_config.dart

```dart
static const String _primaryUrl = 'http://13.221.127.254';
static const String _secondaryUrl = 'http://13.201.56.162';
static const bool enableAutoFailover = true;
static const int maxFailoverAttempts = 2;
```

### Retry & Timeout Settings

```dart
static const Duration connectTimeout = Duration(seconds: 30);
static const Duration receiveTimeout = Duration(seconds: 60);
static const int maxRetries = 3;
static const Duration retryDelay = Duration(seconds: 2);
```

## Usage

### Automatic Mode (Default)

No code changes needed! The failover happens automatically:

```dart
// Your existing code works as-is
final authService = AuthService();
await authService.signIn(email, password);

// ApiClient automatically handles failover if primary fails
```

### Manual Controls

```dart
final apiClient = ApiClient();

// Check backend health
Map<String, bool> health = await apiClient.checkAllBackendsHealth();
print('Primary healthy: ${health['primary']}');
print('Secondary healthy: ${health['secondary']}');

// Get current status
Map<String, dynamic> status = apiClient.getBackendStatus();
print('Using secondary: ${status['isUsingSecondary']}');

// Manual failover (for testing)
apiClient.manualFailover();  // Switch to secondary
apiClient.manualRecovery();  // Switch back to primary
```

### Backend Status Widget

Add the status widget to any screen for monitoring:

```dart
import 'package:stellantis_app/widgets/backend_status_widget.dart';

// In your widget build method:
BackendStatusWidget(
  showDetails: true,      // Show URLs and details
  showHealthCheck: true,  // Show health status with refresh button
)
```

## Testing the Failover

### Test Scenario 1: Primary Backend Down

1. Stop the primary backend (Singapore)
2. Launch the app and try to login
3. Watch console logs - you'll see:
   ```
   ⚠️ Max retries reached on current backend, attempting FAILOVER...
   🔄 FAILOVER: Switched to SECONDARY backend: http://13.201.56.162
   🔄 Retry attempt 1/3 on SECONDARY backend
   ✅ [API Response] 200 /api/v1/auth/signin
   ```
4. App successfully connects to secondary backend

### Test Scenario 2: Secondary Backend Down

1. App is using secondary backend
2. Secondary backend goes down
3. App automatically switches back to primary
4. If primary is healthy, app continues working

### Test Scenario 3: Both Backends Down

1. Both backends are unreachable
2. App tries PRIMARY (3 retries)
3. App tries SECONDARY (3 retries)
4. App tries PRIMARY again
5. Shows error: "Both backend regions are unavailable"

### Manual Testing

Add this to your debug/settings screen:

```dart
BackendStatusWidget(
  showDetails: true,
  showHealthCheck: true,
)
```

Use the buttons to:
- Switch between backends manually
- Check health status in real-time
- Monitor current backend URL

## Console Output Examples

### Successful Primary Connection
```
🚀 Using PRIMARY backend: http://13.221.127.254
🚀 [API Request] POST /api/v1/auth/signin
✅ [API Response] 200 /api/v1/auth/signin
```

### Failover to Secondary
```
🚀 Using PRIMARY backend: http://13.221.127.254
❌ [API Error] /api/v1/auth/signin
🔄 Retry attempt 1/3 on PRIMARY backend
❌ [API Error] /api/v1/auth/signin
🔄 Retry attempt 2/3 on PRIMARY backend
❌ [API Error] /api/v1/auth/signin
🔄 Retry attempt 3/3 on PRIMARY backend
⚠️ Max retries reached on current backend, attempting FAILOVER...
🔄 FAILOVER: Switched to SECONDARY backend: http://13.201.56.162
🔄 ApiClient base URL updated to: http://13.201.56.162
🔄 Retry attempt 1/3 on SECONDARY backend
✅ [API Response] 200 /api/v1/auth/signin
```

### Both Backends Down
```
❌ [API Error] /api/v1/auth/signin
⚠️ Max retries reached on current backend, attempting FAILOVER...
🔄 FAILOVER: Switched to SECONDARY backend: http://13.201.56.162
❌ [API Error] /api/v1/auth/signin
❌ Max retries and failover attempts exhausted
Exception: Network error. Please check your connection. Both backend regions are unavailable.
```

## Health Monitoring

### Programmatic Health Checks

```dart
// Check specific backend
bool primaryHealthy = await ApiConfig.checkHealth('http://13.221.127.254');
bool secondaryHealthy = await ApiConfig.checkHealth('http://13.201.56.162');

// Check all backends
Map<String, bool> healthStatus = await ApiConfig.checkAllBackends();
// Returns: {'primary': true, 'secondary': false}

// Ensure healthy backend (auto-switch if needed)
bool hasHealthyBackend = await ApiConfig.ensureHealthyBackend();
```

### Monitoring Best Practices

1. **Regular Health Checks**: Check backend health daily
2. **Pre-Demo Testing**: Always verify both backends before demos
3. **Post-Deployment**: Check health after any backend deployment
4. **User Reports**: If users report issues, check backend health first

## Architecture

```
┌─────────────────┐
│  Mobile App     │
│  (Flutter)      │
└────────┬────────┘
         │
    ┌────▼─────┐
    │ ApiClient │ ◄──── Handles all HTTP requests
    │ (Dio)     │       Automatic retries & failover
    └────┬─────┘
         │
    ┌────▼─────────┐
    │  ApiConfig    │ ◄──── Manages backend URLs
    │               │       Health checks
    │               │       URL switching
    └────┬──────┬──┘
         │      │
    ┌────▼──┐ ┌▼──────┐
    │Primary│ │Secondary│
    │Backend│ │Backend  │
    │(SG)   │ │(Mumbai) │
    └───────┘ └─────────┘
```

## Key Features

✅ **Zero Configuration**: Works automatically, no changes to existing code
✅ **Transparent Failover**: Services don't need to know about multiple backends
✅ **Smart Retries**: Retries on same backend before switching
✅ **Health Monitoring**: Built-in health check system
✅ **Manual Override**: Can manually switch backends for testing
✅ **Detailed Logging**: Console logs show all failover activities
✅ **Error Messages**: Clear messages when both backends fail

## Files Modified

1. **lib/config/api_config.dart** - Backend URLs and health checks
2. **lib/services/api_client.dart** - Failover logic and retry mechanism
3. **lib/widgets/backend_status_widget.dart** - Status monitoring UI (NEW)

## Error Handling

The app provides clear error messages:

- **Single backend down**: Automatically fails over, user sees no error
- **Both backends down**: "Network error. Both backend regions are unavailable."
- **Timeout**: "Connection timeout. (Both primary and secondary backends tried)"  
- **Network error**: "Network error. Both backend regions are unavailable."

## Production Recommendations

1. **Set up monitoring** on both EC2 instances (CloudWatch, Datadog, etc.)
2. **Configure alerts** for backend health failures
3. **Database replication** between regions (if using RDS)
4. **Load balancer** consideration for automatic failover at DNS level
5. **Regular testing** of failover mechanism
6. **Document procedures** for manual backend recovery

## Troubleshooting

### App keeps failing over
- Check both backend health endpoints manually
- Verify EC2 instances are running
- Check security groups allow traffic on port 80
- Review backend logs for errors

### Failover not working
- Verify `enableAutoFailover = true` in api_config.dart
- Check console logs for failover messages
- Ensure both URLs are correct

### Health checks failing
- Test URLs directly: `curl http://13.221.127.254/health`
- Verify `/health` endpoint returns `{"status": "ok"}`
- Check network connectivity from mobile device

## Support

For issues or questions:
1. Check console logs for detailed error messages
2. Use BackendStatusWidget to monitor real-time status
3. Manually test health endpoints
4. Review backend logs on EC2 instances

---

**Last Updated**: February 12, 2026  
**Version**: 2.0.0  
**Status**: ✅ Production Ready
