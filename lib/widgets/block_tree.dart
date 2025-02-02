import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/models/block.dart';
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
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              child: Text(input.label),
            ),
            (input.block != null)
                ? BlockTree(block: input.block!)
                : AddButton(parentBlock: parent, index: index)
          ],
        );
      case StatementInput _:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              child: Text(input.label),
            ),
            for (var block in input.blocks) BlockTree(block: block),
            AddButton(parentBlock: parent, index: index),
          ],
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

  Widget _block() => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: double.infinity),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.block.name),
                    DeleteButton(id: widget.block.id),
                    for (int i = 0; i < widget.block.fields!.length; i++)
                      _handleFields(parent: widget.block, index: i),
                  ],
                ),
              ),
            ),
            for (int i = 0; i < widget.block.children!.length; i++)
              _handleInputs(parent: widget.block, index: i),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DragTarget(
          builder: (context, candidateData, rejectedData) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: _isHovering ? 100 : 50,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isHovering ? Colors.blue : Colors.transparent,
                  width: 2,
                ),
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
        ),
        LongPressDraggable(
          data: widget.block.id,
          dragAnchorStrategy: pointerDragAnchorStrategy,
          feedback: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
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
          onDragCompleted: () {
            print("Drag completed");
          },
        ),
      ],
    );
  }
}
