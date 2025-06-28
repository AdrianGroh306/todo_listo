import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppError {
  final String code;
  final String message;
  final String? details;
  final StackTrace? stackTrace;

  AppError({
    required this.code,
    required this.message,
    this.details,
    this.stackTrace,
  });
}

class ErrorHandler {
  static void logError(String message, [dynamic error, StackTrace? stackTrace]) {
    debugPrint('ERROR: $message');
    if (error != null) {
      debugPrint('Details: $error');
    }
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }

  static AppError handleFirebaseError(dynamic error) {
    String code = 'unknown';
    String message = 'An unexpected error occurred';

    if (error.toString().contains('network-request-failed')) {
      code = 'network_error';
      message = 'Please check your internet connection and try again';
    } else if (error.toString().contains('permission-denied')) {
      code = 'permission_denied';
      message = 'You don\'t have permission to perform this action';
    } else if (error.toString().contains('not-found')) {
      code = 'not_found';
      message = 'The requested data was not found';
    } else if (error.toString().contains('already-exists')) {
      code = 'already_exists';
      message = 'This item already exists';
    } else if (error.toString().contains('invalid-argument')) {
      code = 'invalid_data';
      message = 'The provided data is invalid';
    }

    return AppError(
      code: code,
      message: message,
      details: error.toString(),
    );
  }

  static void showErrorDialog(BuildContext context, AppError error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            const Text('Error'),
          ],
        ),
        content: Text(error.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, AppError error) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onError,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(error.message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () => messenger.hideCurrentSnackBar(),
        ),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message),
            ],
          ],
        ),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  static void hapticFeedback() {
    HapticFeedback.lightImpact();
  }
}
