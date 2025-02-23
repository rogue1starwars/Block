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

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logcontentTemp = await readLog(ref);
    if (mounted) {
      setState(() {
        _logContent = logcontentTemp;
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
        Clipboard.setData(ClipboardData(text: _logContent.toString()));
      }, 
      child: const Icon(Icons.copy),
      ),
      body: SelectableText(_logContent.toString())
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
