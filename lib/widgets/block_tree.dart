import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/provider/is_dragging_provider.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';
import 'package:phoneduino_block/utils/type.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/provider/block_tree_provider.dart';
import 'package:phoneduino_block/widgets/fields_widget.dart';
import 'package:phoneduino_block/widgets/add_button.dart';
import 'package:phoneduino_block/widgets/delete_button.dart';
import 'package:uuid/uuid.dart';

class BlockTree extends ConsumerStatefulWidget {
  final Block block;
  const BlockTree({super.key, required this.block});

  @override
  ConsumerState<BlockTree> createState() => _BlockTreeState();
}

class _BlockTreeState extends ConsumerState<BlockTree> {
  bool _isHovering = false;
  @override
  void initState() {
    super.initState();
  }

  Widget _handleInputs({
    required int index,
  }) {
    final Block parent = widget.block;
    final Input input = parent.children[index];
    switch (input) {
      case ValueInput _:
        return Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                child: Text(input.label,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              (input.block != null)
                  ? BlockTree(block: input.block!)
                  : AddButton(parentBlock: parent, index: index)
            ],
          ),
        );
      case StatementInput _:
        return Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(input.label,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              for (var block in input.blocks) BlockTree(block: block),
              AddButton(parentBlock: parent, index: index)
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _handleFields({required int index}) {
    final Block parent = widget.block;
    final Field field = parent.fields[index];
    switch (field.type) {
      case FieldTypes.string:
        return StringFieldWidget(parent: parent, index: index);
      case FieldTypes.number:
        return NumericFieldWidget(parent: parent, index: index);
      case FieldTypes.variableNames:
        return VariableNamesFieldWidget(parent: parent, index: index);
      case FieldTypes.dropdown:
        return DropdownFieldWidget(parent: parent, index: index);
    }
  }

  Widget toggleButton() {
    return IconButton(
      onPressed: () {
        setState(() {
          ref.read(blockTreeProvider.notifier).trigger(widget.block.id);
        });
      },
      icon: Icon(
        widget.block.isClosed
            ? Icons.keyboard_arrow_right_rounded
            : Icons.keyboard_arrow_down_rounded,
      ),
    );
  }

  Widget _block() => widget.block.isClosed
      ? _blockSimple()
      : Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                // shadowColor: Theme.of(context).colorScheme.primary,
                borderOnForeground: true,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          toggleButton(),
                          Text(widget.block.name),
                          DeleteButton(id: widget.block.id),
                        ],
                      ),
                      for (int i = 0; i < widget.block.fields.length; i++)
                        _handleFields(index: i),
                    ],
                  ),
                ),
              ),
            ),
            for (int i = 0; i < widget.block.children.length; i++)
              _handleInputs(index: i),
          ],
        );

  Widget _blockSimple() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          // shadowColor: Theme.of(context).colorScheme.primary,
          borderOnForeground: true,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                toggleButton(),
                Text(widget.block.name),
                DeleteButton(id: widget.block.id),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final bool isDragging = ref.watch(isDraggingProvider);
    if (widget.block.id == '0') {
      return _block();
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => Stack(
        clipBehavior: Clip.none,
        children: [
          LongPressDraggable(
            data: widget.block.id,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            hitTestBehavior: HitTestBehavior.translucent,
            feedback: SizedBox(
              width: 300,
              child: Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shadowColor: Theme.of(context).colorScheme.primary,
                elevation: 7,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    widget.block.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            child: _block(),
            onDragStarted: () {
              ref.read(isDraggingProvider.notifier).state = true;
            },
            onDragEnd: (details) {
              ref.read(isDraggingProvider.notifier).state = false;
            },
            onDragCompleted: () {
              print("Drag completed");
            },
          ),
          Positioned(
            top: -50,
            child: IgnorePointer(
                ignoring: !isDragging,
                child: DragTarget(
                  builder: (context, candidateData, rejectedData) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 100,
                      width: constraints.maxWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isHovering
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                        color: _isHovering
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3)
                            : Colors.transparent,
                      ),
                    );
                  },
                  onMove: (data) {
                    setState(() => _isHovering = true);
                  },
                  onLeave: (data) {
                    setState(() => _isHovering = false);
                  },
                  onAcceptWithDetails: (detail) {
                    setState(() => _isHovering = false);
                    final id = detail.data as String;
                    final Block? targetBlock =
                        ref.read(blockTreeProvider.notifier).findBlock(id: id);
                    if (targetBlock == null) return;

                    final targetBlockCopied = targetBlock.copyWith(
                        id: const Uuid().v4()); // copy with new id
                    bool inserted = ref
                        .read(blockTreeProvider.notifier)
                        .insertBlock(
                            siblingId: widget.block.id,
                            value: targetBlockCopied);
                    if (inserted) {
                      ref.read(blockTreeProvider.notifier).deleteBlock(id: id);
                    } else {
                      ref.read(uiProvider.notifier).showMessage(
                            'Failed to add block',
                          );
                    }
                  },
                )),
          )
        ],
      ),
    );
  }
}
