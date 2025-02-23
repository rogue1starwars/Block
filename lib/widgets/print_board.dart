import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';

class PrintBoard extends ConsumerWidget {
  const PrintBoard({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(uiProvider);
    return ListView.builder(
      itemCount: uiState.messageDequeue.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: SelectableText(uiState.messageDequeue[index]),
        );
      },
    );
  }
}
