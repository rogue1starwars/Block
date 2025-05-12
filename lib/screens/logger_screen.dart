import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/file_logger.dart';

class LoggerScreen extends ConsumerStatefulWidget {
  const LoggerScreen({super.key});

  @override
  ConsumerState<LoggerScreen> createState() => _LoggerScreenState();
}

class _LoggerScreenState extends ConsumerState<LoggerScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _logs = [];
  StringBuffer _logContent = StringBuffer('empty');
  StringBuffer _logContentRaw = StringBuffer('empty');

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    _logContentRaw = await readLog(ref);
    print(_logContentRaw.length);
    if (_logContentRaw.length > 10000) {
      setState(() {
        _logContent = StringBuffer('Loaded! Truncated to 10000 characters\n\n');
        _logContent.write(
            _logContentRaw.toString().substring(_logContentRaw.length - 10000));
      });
      return;
    }
    if (mounted) {
      setState(() {
        _logContent = _logContentRaw;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Logs'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadLogs,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                clearLog(ref);
                setState(() => _logs.clear());
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: _logContentRaw.toString()));
          },
          child: const Icon(Icons.copy),
        ),
        body: SelectableText(_logContent.toString()));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
