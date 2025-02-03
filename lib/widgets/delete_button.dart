import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/provider/block_tree_provider.dart';

class DeleteButton extends ConsumerWidget {
  final String id;
  const DeleteButton({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () {
        ref.read(blockTreeProvider.notifier).deleteBlock(id: id);
      },
      icon: const Icon(Icons.close_rounded),
    );
  }
}
