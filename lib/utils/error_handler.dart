import 'package:flutter/material.dart';
import 'dart:developer' as developer;

/// A utility class for handling errors consistently across the app.
/// 
/// This class provides methods for displaying error messages to users,
/// logging errors for debugging, and handling different types of errors
/// in a consistent manner.
class ErrorHandler {
  /// Displays an error dialog with a user-friendly message.
  /// 
  /// This method shows a dialog with the provided error message and an "Okay" button
  /// to dismiss the dialog.
  /// 
  /// Parameters:
  /// - [context]: The BuildContext for showing the dialog.
  /// - [message]: The user-friendly error message to display.
  /// - [title]: Optional title for the dialog. Defaults to "An Error Occurred!".
  static void showErrorDialog(
    BuildContext context, 
    String message, 
    {String title = "An Error Occurred!"}
  ) {
    // Ensure the context is still valid
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Okay'),
            ),
          ],
        ),
      );
    }
  }

  /// Shows a snackbar with an error message.
  /// 
  /// This method displays a snackbar at the bottom of the screen with the provided
  /// error message. This is useful for non-critical errors that don't require
  /// user interaction.
  /// 
  /// Parameters:
  /// - [context]: The BuildContext for showing the snackbar.
  /// - [message]: The user-friendly error message to display.
  /// - [duration]: Optional duration for how long the snackbar should be displayed.
  static void showErrorSnackBar(
    BuildContext context, 
    String message, 
    {Duration duration = const Duration(seconds: 3)}
  ) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: duration,
        ),
      );
    }
  }

  /// Logs an error for debugging purposes.
  /// 
  /// This method logs the error message and optional stack trace to the console
  /// for debugging. In a production environment, this could be extended to log
  /// to a remote service like Firebase Crashlytics.
  /// 
  /// Parameters:
  /// - [error]: The error message or exception to log.
  /// - [stackTrace]: Optional stack trace associated with the error.
  /// - [hint]: Optional additional information about the error.
  static void logError(
    dynamic error, 
    {StackTrace? stackTrace, String? hint}
  ) {
    // Log to console for debugging
    developer.log(
      'ERROR: ${error.toString()}',
      name: 'AI_CoinBox',
      error: error,
      stackTrace: stackTrace,
    );
    
    // TODO: In production, you might want to log to a service like Firebase Crashlytics
    // if (kReleaseMode) {
    //   FirebaseCrashlytics.instance.recordError(
    //     error,
    //     stackTrace,
    //     reason: hint,
    //   );
    // }
  }

  /// Handles network-related errors.
  /// 
  /// This method provides specific handling for network-related errors,
  /// such as connection timeouts or server errors.
  /// 
  /// Parameters:
  /// - [context]: The BuildContext for showing error messages.
  /// - [error]: The error that occurred.
  /// - [stackTrace]: Optional stack trace associated with the error.
  static void handleNetworkError(
    BuildContext context, 
    dynamic error, 
    {StackTrace? stackTrace}
  ) {
    logError(error, stackTrace: stackTrace, hint: 'Network Error');
    
    String message = 'A network error occurred. Please check your connection and try again.';
    
    // You can add more specific error messages based on the error type
    if (error.toString().contains('timeout')) {
      message = 'The connection timed out. Please try again later.';
    } else if (error.toString().contains('404')) {
      message = 'The requested resource was not found.';
    }
    
    showErrorSnackBar(context, message);
  }

  /// Handles authentication-related errors.
  /// 
  /// This method provides specific handling for authentication-related errors,
  /// such as invalid credentials or expired sessions.
  /// 
  /// Parameters:
  /// - [context]: The BuildContext for showing error messages.
  /// - [error]: The error that occurred.
  /// - [stackTrace]: Optional stack trace associated with the error.
  static void handleAuthError(
    BuildContext context, 
    dynamic error, 
    {StackTrace? stackTrace}
  ) {
    logError(error, stackTrace: stackTrace, hint: 'Authentication Error');
    
    String message = 'An authentication error occurred. Please try again.';
    
    // You can add more specific error messages based on the error type
    if (error.toString().contains('user-not-found')) {
      message = 'No user found with this email.';
    } else if (error.toString().contains('wrong-password')) {
      message = 'Incorrect password. Please try again.';
    } else if (error.toString().contains('invalid-email')) {
      message = 'The email address is not valid.';
    }
    
    showErrorDialog(context, message, title: 'Authentication Error');
  }

  /// Handles transaction-related errors.
  /// 
  /// This method provides specific handling for transaction-related errors,
  /// such as insufficient funds or failed transactions.
  /// 
  /// Parameters:
  /// - [context]: The BuildContext for showing error messages.
  /// - [error]: The error that occurred.
  /// - [stackTrace]: Optional stack trace associated with the error.
  static void handleTransactionError(
    BuildContext context, 
    dynamic error, 
    {StackTrace? stackTrace}
  ) {
    logError(error, stackTrace: stackTrace, hint: 'Transaction Error');
    
    String message = 'An error occurred while processing your transaction. Please try again.';
    
    // You can add more specific error messages based on the error type
    if (error.toString().contains('insufficient-funds')) {
      message = 'Insufficient funds to complete this transaction.';
    } else if (error.toString().contains('transaction-limit-exceeded')) {
      message = 'Transaction limit exceeded. Please try a smaller amount.';
    }
    
    showErrorDialog(context, message, title: 'Transaction Error');
  }
}