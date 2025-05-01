import 'package:logger/logger.dart';

class Log {
  static final Logger logger = Logger();

  static void logInfo(String message) {
    logger.i(message);
  }

  static void logError(String message) {
    logger.e(message);
  }
}
