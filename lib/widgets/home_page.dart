import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/provider/block_tree_provider.dart';
import 'package:phoneduino_block/widgets/fields_widget.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Block root = ref.watch(blockTreeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('PhoneDuino Block'),
      ),
      body: BlockTree(block: root),
    );
  }
}

class BlockTree extends ConsumerWidget {
  final Block block;
  const BlockTree({super.key, required this.block});

  Widget _handleInputs(Input input) {
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
                : SizedBox.shrink(), // TODO Create a add button
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
            //TODO Create a add button
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _handleFields(Field field) {
    switch (field) {
      case StringField _:
        return StringFieldWidget(
            parent: block, index: block.fields!.indexOf(field));
      case NumericField _:
        return NumericFieldWidget(
            parent: block, index: block.fields!.indexOf(field));
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(block.name),
                if (block.fields != null)
                  for (var field in block.fields!) _handleFields(field),
              ],
            ),
          ),
        ),
        if (block.children != null)
          for (Input child in block.children!) _handleInputs(child),
      ],
    );
  }
}

class AddButton extends ConsumerWidget {
  final String parentId;
  final Block block;
  final int index;
  const AddButton({
    super.key,
    required this.parentId,
    required this.block,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
        onPressed: () {
          ref.read(blockTreeProvider.notifier).addBlock(
                parentId: parentId,
                block: block,
                index: index,
              );
        },
        icon: const Icon(Icons.add));
  }
}
