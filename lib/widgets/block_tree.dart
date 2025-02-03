import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/provider/is_dragging_provider.dart';
import 'package:phoneduino_block/utils/type.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/provider/block_tree_provider.dart';
import 'package:phoneduino_block/widgets/fields_widget.dart';
import 'package:phoneduino_block/widgets/add_button.dart';
import 'package:phoneduino_block/widgets/delete_button.dart';

class BlockTree extends ConsumerStatefulWidget {
  final Block block;
  const BlockTree({super.key, required this.block});

  @override
  ConsumerState<BlockTree> createState() => _BlockTreeState();
}

class _BlockTreeState extends ConsumerState<BlockTree> {
  bool _isHovering = false;

  Widget _handleInputs({
    required Block parent,
    required int index,
  }) {
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
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
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
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(input.label,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              for (var block in input.blocks) BlockTree(block: block),
              AddButton(parentBlock: parent, index: index),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _handleFields({required Block parent, required int index}) {
    final Field field = parent.fields[index];
    switch (field.type) {
      case BlockTypes.string:
        return StringFieldWidget(parent: parent, index: index);
      case BlockTypes.number:
        return NumericFieldWidget(parent: parent, index: index);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _block() => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.block.name),
                        DeleteButton(id: widget.block.id),
                      ],
                    ),
                    for (int i = 0; i < widget.block.fields.length; i++)
                      _handleFields(parent: widget.block, index: i),
                  ],
                ),
              ),
            ),
          ),
          for (int i = 0; i < widget.block.children.length; i++)
            _handleInputs(parent: widget.block, index: i),
        ],
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
            feedback: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: constraints.maxWidth,
                child: Text(
                  widget.block.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: -5,
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
                          color: _isHovering ? Colors.blue : Colors.transparent,
                          width: 2,
                        ),
                        color: _isHovering
                            ? Colors.blue.withOpacity(0.3)
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
                    ref.read(blockTreeProvider.notifier).moveBlock(
                          siblingId: widget.block.id,
                          id: id,
                        );
                  },
                )),
          )
        ],
      ),
    );
  }
}
