import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as l;

/// App-wide logger. Filtered to debug builds; release builds are silent
/// to avoid leaking patient data into device logs.
final log = l.Logger(
  level: kDebugMode ? l.Level.debug : l.Level.warning,
  printer: l.PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 4,
    lineLength: 100,
    colors: true,
    printEmojis: false,
    dateTimeFormat: l.DateTimeFormat.onlyTimeAndSinceStart,
  ),
);
