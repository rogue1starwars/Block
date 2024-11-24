import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/data/block_data.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/inputs.dart';

class BlockTreeNotifier extends StateNotifier<Block> {
  BlockTreeNotifier()
      : super(Block.fromBluePrint(
          block: blockData[0],
          id: '0',
        ));

  void updateFieldInput({
    Block? parent,
    required String parentId,
    required dynamic value,
    required int index,
  }) {
    parent ??= state;
    if (parent.fields == null) return;
    if (parent.fields!.length <= index) return;

    if (parent.id == parentId) {
      final newFields = [
        for (int i = 0; i < parent.fields!.length; i++)
          if (i == index)
            parent.fields![i].copyWith(value: value)
          else
            parent.fields![i]
      ];
      parent.copyWith(fields: newFields);
    } else {
      recursive(
        callback: updateFieldInput,
        parent: parent,
        parentId: parentId,
        value: value,
        index: index,
      );
    }
  }

  List<Input> createNewChildren({
    required Block parent,
    required Block block,
    required int index,
  }) {
    switch (parent.children![index]) {
      case ValueInput _:
        final ValueInput targetChild = parent.children![index] as ValueInput;
        final List<Input> newChildren = [
          for (int i = 0; i < parent.children!.length; i++)
            if (i == index)
              targetChild.copyWith(block: block)
            else
              parent.children![i]
        ];
        return newChildren;
      case StatementInput _:
        final StatementInput targetChild =
            parent.children![index] as StatementInput;
        List<Block> newBlocks = [
          ...(targetChild.blocks),
          block,
        ];
        final List<Input> newChildren = [
          for (int i = 0; i < parent.children!.length; i++)
            if (i == index)
              targetChild.copyWith(blocks: newBlocks)
            else
              parent.children![i]
        ];
        return newChildren;
      default:
        return [];
    }
  }

  void recursive({
    required Function callback,
    required Block parent,
    required String parentId,
    required dynamic value,
    required int index,
  }) {
    /*
    * This function will recursively call the callback function
    * for each child of the parent block
    */
    for (int i = 0; i < parent.children!.length; i++) {
      switch (parent.children![i]) {
        case ValueInput _:
          final ValueInput targetChild = parent.children![i] as ValueInput;
          callback(
            parent: targetChild.block,
            parentId: parentId,
            block: value,
            index: index,
          );
          break;
        case StatementInput _:
          final StatementInput targetChild =
              parent.children![i] as StatementInput;
          for (int j = 0; j < targetChild.blocks.length; j++) {
            callback(
              parent: targetChild.blocks[j],
              parentId: parentId,
              block: value,
              index: index,
            );
          }
          break;
      }
    }
  }

  Block? copyTree(Block block) {
    Block newBlock = block.copyWith();
    if (newBlock.children == null) return null;
    for (int i = 0; i < newBlock.children!.length; i++) {
      switch (newBlock.children![i]) {
        case ValueInput _:
          final ValueInput targetChild = newBlock.children![i] as ValueInput;
          copyTree(targetChild.block!);
          break;
        case StatementInput _:
          final StatementInput targetChild =
              newBlock.children![i] as StatementInput;
          for (int j = 0; j < targetChild.blocks.length; j++) {
            copyTree(targetChild.blocks[j]);
          }
          break;
      }
    }
    return newBlock;
  }

  void addBlock({
    required String parentId,
    required Block block,
    required int index,
  }) {
    Block? _addBlockHelper({
      required Block parent,
      required String parentId,
      required Block block,
      required int index,
    }) {
      if (parent.children == null) return null;
      if (parent.children!.length <= index) return null;

      if (parent.id == parentId) {
        print("Adding block");
        final newChildren = createNewChildren(
          parent: parent,
          block: block,
          index: index,
        );
        // Just for testing...
        final newParent = parent.copyWith(children: newChildren);
        return newParent;
      } else {
        // recursive(
        //   callback: addBlock,
        //   parent: parent,
        //   parentId: parentId,
        //   value: block,
        //   index: index,
        // );
        for (Input input in parent.children!) {
          switch (input) {
            case ValueInput _:
              if (input.block == null) return null;
              final result = _addBlockHelper(
                parent: input.block!,
                parentId: parentId,
                block: block,
                index: index,
              );
              if (result != null) {
                final List<Input> newChildren = [
                  for (int i = 0; i < parent.children!.length; i++)
                    if (i == index)
                      input.copyWith(block: block)
                    else
                      parent.children![i]
                ];
                return parent.copyWith(children: newChildren);
              }
            case StatementInput _:
              for (Block childBlock in input.blocks) {
                final result = _addBlockHelper(
                  parent: childBlock,
                  parentId: parentId,
                  block: block,
                  index: index,
                );
                if (result != null) {
                  final List<Block> newBlocks = [
                    ...(input.blocks),
                    block,
                  ];
                  final List<Input> newChildren = [
                    for (int i = 0; i < parent.children!.length; i++)
                      if (i == index)
                        input.copyWith(blocks: newBlocks)
                      else
                        parent.children![i]
                  ];
                  return parent.copyWith(children: newChildren);
                }
              }
          }
        }
        return null;
      }
    }

    final newBlock = _addBlockHelper(
      parent: state,
      parentId: parentId,
      block: block,
      index: index,
    );
    if (newBlock != null) {
      state = newBlock;
    }
  }

  // void changeValueInput({
  //   Block? parent,
  //   required String parentId,
  //   required Block block,
  //   required int index,
  // }) {
  //   parent ??= state;
  //   if (parent.children == null) return;
  //   if (parent.children!.length <= index) return;

  //   if (parent.id == parentId) {
  //     // Create new instance of a Input
  //     final newChildren = [
  //       for (int i = 0; i < parent.children!.length; i++)
  //         if (i == index)
  //           parent.children![i].copyWith(block: block)
  //         else
  //           parent.children![i]
  //     ];
  //     parent.copyWith(children: newChildren);
  //   } else {
  //     for (int i = 0; i < parent.children!.length; i++) {
  //       if (parent.children![i].runtimeType == ValueInput) {
  //         changeValueInput(
  //           parent: parent.children![i].block,
  //           parentId: parentId,
  //           block: block,
  //           index: index,
  //         );
  //       } else {
  //         for (int j = 0; j < parent.children![i].blocks!.length; j++) {
  //           changeValueInput(
  //             parent: parent.children![i].blocks![j],
  //             parentId: parentId,
  //             block: block,
  //             index: index,
  //           );
  //         }
  //       }
  //     }
  //   }
  // }

  // void addStatementInput({
  //   Block? parent,
  //   required String parentId,
  //   required Block block,
  //   required int index,
  // }) {
  //   parent ??= state;
  //   if (parent.children == null) return;
  //   if (parent.children!.length <= index) return;

  //   if (parent.id == parentId) {
  //     final List<Block> newBlocks = [
  //       ...(parent.children![index].blocks ?? []),
  //       block,
  //     ];
  //     final newChild = parent.children?[index].copyWith(blocks: newBlocks);
  //     if (newChild == null) return;
  //     final newChildren = [
  //       ...parent.children!.sublist(0, index),
  //       newChild,
  //       ...parent.children!.sublist(index + 1),
  //     ];
  //     parent.copyWith(children: newChildren);
  //   } else {
  //     for (int i = 0; i < parent.children!.length; i++) {
  //       if (parent.children![i].runtimeType == ValueInput) {
  //         addStatementInput(
  //           parent: parent.children![i].block,
  //           parentId: parentId,
  //           block: block,
  //           index: index,
  //         );
  //       } else {
  //         for (int j = 0; j < parent.children![i].blocks!.length; j++) {
  //           addStatementInput(
  //             parent: parent.children![i].blocks![j],
  //             parentId: parentId,
  //             block: block,
  //             index: index,
  //           );
  //         }
  //       }
  //     }
  //   }
  // }
}

final blockTreeProvider =
    StateNotifierProvider<BlockTreeNotifier, Block>((ref) {
  return BlockTreeNotifier();
});
