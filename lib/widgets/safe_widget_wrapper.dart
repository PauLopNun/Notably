import 'package:flutter/material.dart';

class SafeWidgetWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onError;

  const SafeWidgetWrapper({
    super.key,
    required this.child,
    this.onError,
  });

  @override
  State<SafeWidgetWrapper> createState() => _SafeWidgetWrapperState();
}

class _SafeWidgetWrapperState extends State<SafeWidgetWrapper> {
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Set up error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      if (mounted && details.exception.toString().contains('_dependents.isEmpty')) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Widget disposal error detected';
        });
        widget.onError?.call();
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              'Se detectó un problema temporal',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Error desconocido',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _errorMessage = null;
                });
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    try {
      return widget.child;
    } catch (e) {
      if (e.toString().contains('_dependents.isEmpty')) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: Text('Reactivando componente...'),
          ),
        );
      }
      rethrow;
    }
  }

  @override
  void dispose() {
    // Reset error handler
    FlutterError.onError = FlutterError.presentError;
    super.dispose();
  }
}