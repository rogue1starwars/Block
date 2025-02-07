import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/data/block_data_core.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/provider/block_tree_provider.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';
import 'package:phoneduino_block/utils/filter.dart';
import 'package:phoneduino_block/utils/type.dart';
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
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return BlockListDialog(
                          filter:
                              widget.parentBlock.children[widget.index].filter,
                          parentId: widget.parentBlock.id,
                          index: widget.index,
                        );
                      });
                },
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 60,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _isHovering
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.1),
                        width: 2,
                      ),
                      color: _isHovering
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3)
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.1),
                    ),
                    child: const Center(child: Icon(Icons.add))),
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
}

class BlockListDialog extends ConsumerStatefulWidget {
  final List<BlockTypes>? filter;
  final String parentId;
  final int index;
  const BlockListDialog({
    super.key,
    required this.filter,
    required this.parentId,
    required this.index,
  });

  @override
  ConsumerState<BlockListDialog> createState() => _BlockListDialogState();
}

class _BlockListDialogState extends ConsumerState<BlockListDialog> {
  String _category = blockData.keys.elementAt(1);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Block List'),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      content: SingleChildScrollView(
        child: Column(
          children: [
            DropdownMenu(
              initialSelection: _category,
              dropdownMenuEntries: [
                for (String category in blockData.keys)
                  DropdownMenuEntry(
                    value: category,
                    label: category,
                  ),
              ],
              onSelected: (String? value) {
                if (value != null) {
                  setState(() {
                    _category = value;
                  });
                }
              },
            ),
            for (BlockBluePrint block in filterBlockData(
              widget.filter,
              blockData[_category] ?? blockData[blockData.keys.elementAt(1)]!,
            ))
              ListTile(
                title: Text(block.name),
                onTap: () {
                  final String newId = const Uuid().v4();
                  final bool succeded =
                      ref.read(blockTreeProvider.notifier).addBlock(
                            parentId: widget.parentId,
                            value: Block.fromBluePrint(block: block, id: newId),
                            index: widget.index,
                          );
                  if (succeded) {
                    Navigator.of(context).pop();
                  } else {
                    ref.read(uiProvider.notifier).showMessage(
                          'Failed to add block',
                        );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
