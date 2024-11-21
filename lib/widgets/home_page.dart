import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/provider/block_tree_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Placeholder();
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
    return Card(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(),
        
      ],
    ));
  }
}
