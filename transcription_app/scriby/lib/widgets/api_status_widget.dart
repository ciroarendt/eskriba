import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ApiStatusWidget extends StatefulWidget {
  const ApiStatusWidget({Key? key}) : super(key: key);

  @override
  State<ApiStatusWidget> createState() => _ApiStatusWidgetState();
}

class _ApiStatusWidgetState extends State<ApiStatusWidget> {
  bool _isConnected = false;
  bool _isLoading = true;
  String _statusMessage = 'Checking connection...';
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _checkApiConnection();
  }

  Future<void> _checkApiConnection() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing API connection...';
    });

    try {
      final apiService = ApiService();
      await apiService.initialize();
      
      // Try to get recordings to test connectivity
      await apiService.getRecordings();
      
      setState(() {
        _isConnected = true;
        _isLoading = false;
        _statusMessage = 'Connected to Eskriba API';
        _currentUrl = ApiService.baseUrl;
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _isLoading = false;
        _statusMessage = 'Connection failed: ${e.toString()}';
        _currentUrl = ApiService.fallbackUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  _isLoading 
                    ? Icons.sync 
                    : _isConnected 
                      ? Icons.cloud_done 
                      : Icons.cloud_off,
                  color: _isLoading 
                    ? Colors.orange 
                    : _isConnected 
                      ? Colors.green 
                      : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'API Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _statusMessage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (_currentUrl.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Endpoint: $_currentUrl',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _checkApiConnection,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Test Again'),
                ),
                if (!_isConnected && !_isLoading)
                  TextButton.icon(
                    onPressed: () {
                      // Show debug info
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Connection Debug'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Primary URL: ${ApiService.baseUrl}'),
                              const SizedBox(height: 8),
                              Text('Fallback URL: ${ApiService.fallbackUrl}'),
                              const SizedBox(height: 8),
                              Text('Error: $_statusMessage'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Debug'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
