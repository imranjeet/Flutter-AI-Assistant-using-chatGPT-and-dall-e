import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class CustomLogger {
  ///The singleton instance of the logger
  static CustomLogger? _instance;

  ///Logger object with calling stack information
  late Logger _logger;

  ///Logger object without calling stack information
  late Logger _loggerNoStack;

  ///init needs to be called in the main.dart
  factory CustomLogger.init() {
    _instance ??= CustomLogger._();
    return CustomLogger();
  }

  ///Dummy constructor
  CustomLogger();

  ///This is the getter for the singleton logger instance
  static CustomLogger get instance {
    return _instance ?? CustomLogger();
  }

  ///Private constructor for initializing the logger
  CustomLogger._() {
    if (!kReleaseMode) {
      initializeLogger();
    }
  }

  ///Initializing Console only logger
  void initializeLogger() {
    _logger = Logger(printer: PrettyPrinter(printTime: false));
    _loggerNoStack = Logger(printer: PrettyPrinter(methodCount: 0));
  }

  void debug(String message, [BuildContext? context]) {
    if (!kReleaseMode) {
      if (context != null) {
        _logger.d("${context.widget}: $message");
      } else {
        _logger.d("$message");
      }
    }
  }

  void info(String message, [BuildContext? context]) {
    if (!kReleaseMode) {
      if (context != null) {
        _logger.i("${context.widget}: $message");
      } else {
        _logger.i("$message");
      }
    }
  }

  void warning(String message, [BuildContext? context]) {
    if (!kReleaseMode) {
      if (context != null) {
        _logger.w("${context.widget}: $message");
      } else {
        _logger.w("$message");
      }
    }
  }

  void error(String? message, [BuildContext? context]) {
    if (!kReleaseMode) {
      if (context != null) {
        _logger.e("${context.widget}: $message");
      } else {
        _logger.e("$message");
      }
    }
  }

  severe(String message, [BuildContext? context]) {
    if (!kReleaseMode) {
      if (context != null) {
        _logger.wtf("${context.widget}: $message");
      } else {
        _logger.wtf("$message");
      }
    }
  }

  void response(dynamic response) {
    if (!kReleaseMode) {
      _loggerNoStack.v(response);
    }
  }

  void singleLine(String? message, [BuildContext? context]) {
    if (!kReleaseMode) {
      if (context != null) {
        _loggerNoStack.i("${context.widget}: $message");
      } else {
        _loggerNoStack.i("$message");
      }
    }
  }
}
