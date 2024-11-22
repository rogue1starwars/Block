import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/provider/block_tree_provider.dart';

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

  _buildInputWidget(Input input) {
    if (input.block != null) {
      return BlockTree(block: input.block!);
    }
    if (input.blocks != null) {
      return Column(
        children: [
          for (final block in input.blocks!) BlockTree(block: block),
        ],
      );
    }
    return null;
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
              children: [
                Text(block.name),
                if (block.fields != null)
                  for (var field in block.fields!) Text(field.label),
              ],
            ),
          ),
        ),
        if (block.children != null)
          for (Input child in block.children!) _buildInputWidget(child),
      ],
    );
  }
}

class BlockWidget extends StatefulWidget {
  final Block block;
  const BlockWidget({super.key, required this.block});

  @override
  State<BlockWidget> createState() => _BlockWidgetState();
}

class _BlockWidgetState extends State<BlockWidget> {
  @override
  Widget build(BuildContext context) {
    return const Card(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [],
    ));
  }
}
