import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/data/block_data.dart';
import 'package:phoneduino_block/models/ble_info.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/provider/block_tree_provider.dart';
import 'package:phoneduino_block/utils/type.dart';
import 'package:phoneduino_block/widgets/ble/ble_home.dart';
import 'package:phoneduino_block/widgets/fields_widget.dart';
import 'package:uuid/uuid.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Block root = ref.watch(blockTreeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('PhoneDuino Block'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const BleHome(),
              IconButton(
                  onPressed: () {
                    final BleInfo bleInfo = ref.watch(bleProvider);
                    Block.setVariable(
                      "_ble",
                      bleInfo,
                      BlockTypes.ble,
                    );
                    Block.setVariable(
                      "_context",
                      context,
                      BlockTypes.context,
                    );
                    root.execute();
                  },
                  icon: const Icon(Icons.play_arrow)),
            ],
          ),
          BlockTree(block: root),
        ],
      ),
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

  Widget _handleFields({required Block parent, required int index}) {
    final Field field = parent.fields![index];
    switch (field) {
      case StringField _:
        return StringFieldWidget(parent: parent, index: index);
      case NumericField _:
        return NumericFieldWidget(parent: parent, index: index);
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
                  for (int i = 0; i < block.fields!.length; i++)
                    _handleFields(parent: block, index: i),
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
        );
      },
    );
  }
}
