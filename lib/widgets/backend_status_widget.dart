// ============================================================================
// FILE: backend_status_widget.dart
// DESCRIPTION: Widget to display backend status and health information
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: AI Assistant
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../services/api_client.dart';

/// Widget to display current backend status and health information
/// Useful for debugging and monitoring failover status
class BackendStatusWidget extends StatefulWidget {
  final bool showDetails;
  final bool showHealthCheck;

  const BackendStatusWidget({
    Key? key,
    this.showDetails = true,
    this.showHealthCheck = true,
  }) : super(key: key);

  @override
  State<BackendStatusWidget> createState() => _BackendStatusWidgetState();
}

class _BackendStatusWidgetState extends State<BackendStatusWidget> {
  final ApiClient _apiClient = ApiClient();
  Map<String, bool>? _healthStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.showHealthCheck) {
      _checkHealth();
    }
  }

  Future<void> _checkHealth() async {
    setState(() => _isLoading = true);
    try {
      final status = await _apiClient.checkAllBackendsHealth();
      setState(() {
        _healthStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error checking backend health: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _apiClient.getBackendStatus();

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      status['isUsingSecondary'] 
                          ? Icons.backup 
                          : Icons.cloud_done,
                      color: status['isUsingSecondary'] 
                          ? Colors.orange 
                          : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Backend Status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                if (widget.showHealthCheck)
                  IconButton(
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    onPressed: _isLoading ? null : _checkHealth,
                    tooltip: 'Check Health',
                  ),
              ],
            ),
            const Divider(),

            // Current backend
            _buildStatusRow(
              'Active Backend',
              status['isUsingSecondary'] ? 'SECONDARY' : 'PRIMARY',
              status['isUsingSecondary'] ? Colors.orange : Colors.green,
            ),

            if (widget.showDetails) ...[
              const SizedBox(height: 8),
              _buildStatusRow(
                'Current URL',
                status['currentBackend'],
                Colors.blue,
              ),
              _buildStatusRow(
                'Primary',
                status['primaryUrl'],
                Colors.grey,
              ),
              _buildStatusRow(
                'Secondary',
                status['secondaryUrl'],
                Colors.grey,
              ),
              _buildStatusRow(
                'Failover',
                status['failoverEnabled'] ? 'ENABLED' : 'DISABLED',
                status['failoverEnabled'] ? Colors.green : Colors.red,
              ),
            ],

            // Health status
            if (widget.showHealthCheck && _healthStatus != null) ...[
              const Divider(),
              const SizedBox(height: 4),
              Text(
                'Health Status:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _buildHealthRow(
                'Primary',
                _healthStatus!['primary'] ?? false,
              ),
              _buildHealthRow(
                'Secondary',
                _healthStatus!['secondary'] ?? false,
              ),
            ],

            // Manual controls
            if (widget.showDetails) ...[
              const Divider(),
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: status['isUsingSecondary']
                        ? () {
                            _apiClient.manualRecovery();
                            setState(() {});
                          }
                        : null,
                    icon: const Icon(Icons.cloud_done, size: 16),
                    label: const Text('Use Primary'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: !status['isUsingSecondary']
                        ? () {
                            _apiClient.manualFailover();
                            setState(() {});
                          }
                        : null,
                    icon: const Icon(Icons.backup, size: 16),
                    label: const Text('Use Secondary'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRow(String backend, bool isHealthy) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isHealthy ? Icons.check_circle : Icons.error,
            color: isHealthy ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            backend,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 8),
          Text(
            isHealthy ? 'Healthy' : 'Unhealthy',
            style: TextStyle(
              color: isHealthy ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// END OF FILE: backend_status_widget.dart
// ============================================================================
