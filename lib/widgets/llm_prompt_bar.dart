import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';

class LlmPromptBar extends ConsumerStatefulWidget {
  const LlmPromptBar({super.key});

  @override
  ConsumerState<LlmPromptBar> createState() => _LlmPromptBarState();
}

class _LlmPromptBarState extends ConsumerState<LlmPromptBar> {
  final TextEditingController _controller = TextEditingController();
  final _GeminiLlmClient _llmClient = _GeminiLlmClient();
  final FocusNode _focusNode = FocusNode();
  
  bool _expanded = false;
  bool _isLoading = false;
  String? _result;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  double _expandedWidth(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double desired = screenWidth * 0.6;
    const double minWidth = 320;
    const double maxWidth = 520;
    if (desired < minWidth) return minWidth;
    if (desired > maxWidth) return maxWidth;
    return desired;
  }

  Future<void> _runPrompt() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) {
      ref.read(uiProvider.notifier).showMessage('Type a prompt to generate JSON.');
      return;
    }

    _focusNode.unfocus();

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final response = await _llmClient.generate(prompt);
      setState(() {
        _result = response;
      });
    } catch (e) {
      ref.read(uiProvider.notifier).showMessage('Failed to generate: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _copyResult() async {
    if (_result == null || _result!.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _result!));
    ref.read(uiProvider.notifier).showMessage('Generated JSON copied');
  }

  @override
  Widget build(BuildContext context) {
    final double targetWidth =
        _expanded ? _expandedWidth(context) : kMinInteractiveDimension * 1.1;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOutCubicEmphasized,
      width: targetWidth,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.all(_expanded ? 12 : 0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _expanded ? _expandedView(context) : _collapsedView(),
      ),
    );
  }

  Widget _collapsedView() {
    return FloatingActionButton(
      key: const ValueKey('collapsed'),
      heroTag: null,
      tooltip: 'Search with AI',
      onPressed: () {
        setState(() {
          _expanded = true;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
           _focusNode.requestFocus();
        });
      },
      child: const Icon(Icons.auto_awesome),
    );
  }

  Widget _expandedView(BuildContext context) {
    return Column(
      key: const ValueKey('expanded'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Describe the block logic...',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                minLines: 1,
                maxLines: 3,
                onSubmitted: (_) => _runPrompt(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _runPrompt,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
            ),
            IconButton(
              tooltip: 'Close',
              onPressed: () {
                setState(() {
                  _expanded = false;
                  _result = null;
                  _controller.clear();
                });
                _focusNode.unfocus();
              },
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_isLoading) const LinearProgressIndicator(),
        if (!_isLoading && _result != null) _resultView(context),
      ],
    );
  }

  Widget _resultView(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Generated JSON',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: _copyResult,
                tooltip: 'Copy JSON',
                icon: const Icon(Icons.copy),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 80,
              maxHeight: 200,
            ),
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: SelectableText(
                  _result ?? '',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GeminiLlmClient {
  String _cleanMarkdown(String text) {
    final pattern = RegExp(r'^```(\w+)?\s*|\s*```$');
    return text.replaceAll(pattern, '').trim();
  }

  Future<String> generate(String prompt) async {

    try {
      final response = await Gemini.instance.prompt(
        model: 'gemini-1.5-flash',
        parts: [
          Part.text(
              'You are a JSON generator for PhoneDuino. Return ONLY valid, raw JSON. Do not include markdown formatting. Do not explain the code.\n\nRequest: $prompt'),
        ],
      );

      final String? output = response?.output;
      
      if (output == null || output.isEmpty) {
        throw 'Model returned empty response';
      }

      return _cleanMarkdown(output);
      
    } catch (e) {
      rethrow;
    }
  }
}
