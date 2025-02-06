import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/data/block_data.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/provider/block_tree_provider.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';
import 'package:phoneduino_block/utils/fildter.dart';
import 'package:uuid/uuid.dart';

class AddButton extends ConsumerStatefulWidget {
  final Block parentBlock;
  final int index;

  const AddButton({
    super.key,
    required this.parentBlock,
    required this.index,
  });

  @override
  ConsumerState<AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends ConsumerState<AddButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => Stack(
        children: [
          DragTarget(
            builder: (context, candidateData, rejectedData) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => _dialogBuilder(context),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 60,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isHovering
                          ? Colors.blue
                          : Colors.black.withOpacity(0.1),
                      width: 2,
                    ),
                    color: _isHovering
                        ? Colors.blue.withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                  ),
                  child: const Center(
                    child: Icon(Icons.add),
                  ),
                ),
              ),
            ),
            onMove: (_) => setState(() => _isHovering = true),
            onLeave: (_) => setState(() => _isHovering = false),
            onAcceptWithDetails: (details) {
              setState(() => _isHovering = false);
              final id = details.data as String;
              Block? targetBlock =
                  ref.read(blockTreeProvider.notifier).findBlock(id: id);
              if (targetBlock == null) return;
              targetBlock = targetBlock.copyWith(
                id: const Uuid().v4(),
              );

              final bool added = ref.read(blockTreeProvider.notifier).addBlock(
                    parentId: widget.parentBlock.id,
                    value: targetBlock,
                    index: widget.index,
                  );
              if (added) {
                ref.read(blockTreeProvider.notifier).deleteBlock(id: id);
              } else {
                ref.read(uiProvider.notifier).showMessage(
                      'Failed to add block',
                    );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    final filter = widget.parentBlock.children[widget.index].filter;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add a new block"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (BlockBluePrint block in filterBlockData(filter, blockData))
                  ListTile(
                    title: Text(block.name),
                    onTap: () {
                      var uuid = const Uuid();
                      final String newId = uuid.v4();
                      ref.read(blockTreeProvider.notifier).addBlock(
                            parentId: widget.parentBlock.id,
                            value: Block.fromBluePrint(block: block, id: newId),
                            index: widget.index,
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
