import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/data/block_data.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/inputs.dart';

class BlockTreeNotifier extends StateNotifier<Block> {
  BlockTreeNotifier() : super(blockData[0]('0'));

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

  void addBlock({
    Block? parent,
    required String parentId,
    required Block block,
    required int index,
  }) {
    parent ??= state;
    if (parent.children == null) return;
    if (parent.children!.length <= index) return;

    if (parent.id == parentId) {
      final newChildren = createNewChildren(
        parent: parent,
        block: block,
        index: index,
      );
      parent.copyWith(children: newChildren);
    } else {
      recursive(
        callback: addBlock,
        parent: parent,
        parentId: parentId,
        value: block,
        index: index,
      );
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
