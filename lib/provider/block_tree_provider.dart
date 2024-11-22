import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/data/block_data.dart';
import 'package:phoneduino_block/models/block.dart';

// class Block {
//   final String id;
//   final List<dynamic> inputParameters;
//   final List<List<Block>> children;
//   final Function(List<dynamic>, List<List<Block>>) originalFunc;

//   Block({
//     required this.id,
//     required this.inputParameters,
//     required this.children,
//     required this.originalFunc,
//   });

//   dynamic execute() {
//     return originalFunc(inputParameters, children);
//   }

//   Block copyWith({
//     String? id,
//     String? name,
//     List<dynamic>? inputParameters,
//     List<List<Block>>? children,
//     Function(List<dynamic>, List<List<Block>>)? originalFunc,
//   }) {
//     return Block(
//       id: id ?? this.id,
//       inputParameters: inputParameters ?? this.inputParameters,
//       children: children ?? this.children,
//       originalFunc: originalFunc ?? this.originalFunc,
//     );
//   }
// }

class BlockTreeNotifier extends StateNotifier<Block> {
  BlockTreeNotifier() : super(blockData[0]('0'));

  // void input({
  //   required Block block,
  //   required int index,
  //   required dynamic value,
  // }) {
  //   List<dynamic> newInputParameters = [
  //     for (int i = 0; i < block.inputParameters.length; i++)
  //       if (i == index) value else block.inputParameters[i]
  //   ];
  //   state.copyWith(inputParameters: newInputParameters);
  // }

  void updateFieldInput({
    Block? parent,
    required String parentId,
    required dynamic value,
    required int index,
  }) {
    parent ??= state;
    if (parent.fields == null) return;
    if (parents.fields!.length <= index) return;

    if (parent.id == parentId) {
      final newFields = [
        for (int i = 0; i < parent.fields!.length; i++)
          if (i == index) parent.fields![i].copyWith(value: value)
          else parent.fields![i]
      ]
    } else {
      for (int i = 0; i < parent.children!.length; i++) {
        if (parent.children![i].blocks == null)  {
          updateFieldInput(
            parent: parent.children![i].block,
            parentId: parentId,
            value: value,
            index: index,
          );
        } else {
          for (int j = 0; j < parent.children![i].blocks!.length; j++) {
            updateFieldInput(
              parent: parent.children![i].blocks![j],
              parentId: parentId,
              value: value,
              index: index,
            );
          }
        }

      }
    }
  }

  void changeValueInput({
    Block? parent,
    required String parentId,
    required Block block,
    required int index,
  }) {
    parent ??= state;
    if (parent.children == null) return;
    if (parent.children!.length <= index) return;

    if (parent.id == parentId) {
      // Create new instance of a Input
      final newChild = parent.children?[index].copyWith(block: block);
      if (newChild == null) return;
      final newChildren = [
        ...parent.children!.sublist(0, index),
        newChild,
        ...parent.children!.sublist(index + 1),
      ];
      parent.copyWith(children: newChildren);
    }
    // TODO implement recursive search for blocks as well (switch between statement and value)
    else {
      for (int i = 0; i < parent.children!.length; i++) {
        changeValueInput(
          parent: parent.children![i].block,
          block: block,
          index: index,
          parentId: parentId,
        );
      }
    }
  }

  void addStatementInput({
    Block? parent,
    required String parentId,
    required Block block,
    required int index,
  }) {
    parent ??= state;
    if (parent.children == null) return;
    if (parent.children!.length <= index) return;

    if (parent.id == parentId) {
      final List<Block> newBlocks = [
        ...(parent.children![index].blocks ?? []),
        block,
      ];
      final newChild = parent.children?[index].copyWith(blocks: newBlocks);
      if (newChild == null) return;
      final newChildren = [
        ...parent.children!.sublist(0, index),
        newChild,
        ...parent.children!.sublist(index + 1),
      ];
      parent.copyWith(children: newChildren);
    }
    // TODO implement recursive search for blocks as well (switch between statement and value)
    else {
      for (int i = 0; i < parent.children!.length; i++) {
        addStatementInput(
          parent: parent.children![i].block,
          block: block,
          index: index,
          parentId: parentId,
        );
      }
    }
  }

  // void addBlock({
  //   Block? parent, // used for searching trees recursively. Default is the state
  //   required String parentId,
  //   required Block block,
  //   required int index,
  // }) {
  //   parent ??= state;

  //   if (parent.id == parentId) {
  //     List<List<Block>> newChildren = [
  //       ...parent.children[index].blocks,
  //     ];
  //     parent.copyWith(children: newChildren);
  //     return;
  //   } else {
  //     for (int i = 0; i < parent.children.length; i++) {
  //       addBlock(
  //         parent: parent.children[i][0],
  //         block: block,
  //         index: index,
  //         parentId: parentId,
  //       );
  //     }
  //   }
  // }

  // void removeBlock({Block? parent, required String id}) {
  //   parent ??= state;

  //   for (int i = 0; i < parent.children.length; i++) {
  //     for (int j = 0; j < parent.children[i].length; j++) {
  //       if (parent.children[i][j].id == id) {
  //         List<List<Block>> newChildren = [
  //           ...parent.children.sublist(0, i),
  //           [
  //             ...parent.children[i].sublist(0, j),
  //             ...parent.children[i].sublist(j + 1)
  //           ],
  //           ...parent.children.sublist(i + 1)
  //         ];
  //         parent.copyWith(children: newChildren);
  //         return;
  //       } else {
  //         removeBlock(parent: parent.children[i][0], id: id);
  //       }
  //     }
  //   }
  // }
}

final blockTreeProvider =
    StateNotifierProvider<BlockTreeNotifier, Block>((ref) {
  return BlockTreeNotifier();
});
