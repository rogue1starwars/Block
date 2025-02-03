import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';

Future<String> get _localPath async {
  try {
    final directory = await getDownloadsDirectory();
    if (directory == null) {
      throw 'Failed to get downloads directory';
    }
    return directory.path;
  } catch (e) {
    throw 'Failed to get local path: $e';
  }
}

Future<File> get _localFile async {
  try {
    final path = await _localPath;
    return File('$path/log.txt');
  } catch (e) {
    throw 'Failed to get local file: $e';
  }
}

void writeLog(dynamic log, WidgetRef ref) {
  unawaited(_writeLogAsync(log, ref));
}

Future<void> _writeLogAsync(dynamic log, WidgetRef ref) async {
  try {
    final file = await _localFile;
    final IOSink sink = file.openWrite(mode: FileMode.append);

    final String timestamp = DateTime.now().toString();
    if (log is String) {
      sink.writeln('$timestamp: $log');
    } else if (log is num) {
      sink.writeln('$timestamp: ${log.toString()}');
    } else {
      throw FormatException('Invalid log type: ${log.runtimeType}');
    }

    await sink.flush();
    await sink.close();
  } catch (e) {
    print('Failed to write log: $e');
    ref.read(uiProvider.notifier).showMessage('Failed to write log: $e');
  }
}

Future<StringBuffer> readLog(WidgetRef ref) async {
  try {
    final file = await _localFile;
    final Stream<String> lines = file
        .openRead()
        .transform(const Utf8Decoder())
        .transform(const LineSplitter());

    final StringBuffer buffer = StringBuffer();
    await for (final String line in lines) {
      buffer.writeln(line);
    }

    return buffer;
  } catch (e) {
    print('Failed to read log: $e');
    ref.read(uiProvider.notifier).showMessage('Failed to read log: $e');
    return '' as StringBuffer;
  }
}

void clearLog(WidgetRef ref) {
  unawaited(_clearLogAsync(ref));
}

Future<void> _clearLogAsync(WidgetRef ref) async {
  try {
    final file = await _localFile;
    await file.writeAsString('');
  } catch (e) {
    print('Failed to clear log: $e');
    ref.read(uiProvider.notifier).showMessage('Failed to clear log: $e');
  }
}
