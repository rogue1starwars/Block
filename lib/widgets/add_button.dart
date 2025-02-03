import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/data/block_data.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/provider/block_tree_provider.dart';
import 'package:phoneduino_block/utils/fildter.dart';
import 'package:uuid/uuid.dart';

class AddButton extends ConsumerWidget {
  final Block parentBlock;
  final int index;
  const AddButton({
    super.key,
    required this.parentBlock,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget(
      builder: (context, candidateData, rejectedData) => IconButton(
        onPressed: () => _dialogBuilder(context, ref),
        icon: const Icon(Icons.add),
      ),
      onAcceptWithDetails: (details) {
        final id = details.data as String;
        Block? targetBlock =
            ref.read(blockTreeProvider.notifier).findBlock(id: id);
        if (targetBlock == null) return;
        targetBlock = targetBlock.copyWith(
          id: const Uuid().v4(),
        );

        ref.read(blockTreeProvider.notifier).addBlock(
              parentId: parentBlock.id,
              value: targetBlock,
              index: index,
            );
        ref.read(blockTreeProvider.notifier).deleteBlock(id: id);
      },
    );
    // return IconButton(
    //     onPressed: () => _dialogBuilder(context, ref),
    //     icon: const Icon(Icons.add));
  }

  Future<void> _dialogBuilder(BuildContext context, WidgetRef ref) {
    final filter = parentBlock.children[index].filter;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add a new block"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (BlockBluePrint block in filterBlockData(filter))
                  ListTile(
                    title: Text(block.name),
                    onTap: () {
                      var uuid = const Uuid();
                      final String newId = uuid.v4();
                      ref.read(blockTreeProvider.notifier).addBlock(
                            parentId: parentBlock.id,
                            value: Block.fromBluePrint(block: block, id: newId),
                            index: index,
                          );
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
