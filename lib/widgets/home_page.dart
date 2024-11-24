import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/data/block_data.dart';
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

  Widget _handleInputs({
    required Block parent,
    required int index,
  }) {
    final Input input = parent.children![index];
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
          for (int i = 0; i < block.children!.length; i++)
            _handleInputs(parent: block, index: i),
      ],
    );
  }
}

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
    return IconButton(
        onPressed: () => _dialogBuilder(context, ref),
        icon: const Icon(Icons.add));
  }

  Future<void> _dialogBuilder(BuildContext context, WidgetRef ref) {
    final filter = parentBlock.children![index].filter;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add a new block"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (BlockBluePrint block in filterBlockData(filter))
                ListTile(
                  title: Text(block.name),
                  onTap: () {
                    ref.read(blockTreeProvider.notifier).addBlock(
                          parentId: parentBlock.id,
                          value: Block.fromBluePrint(block: block, id: ''),
                          index: index,
                        );
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
