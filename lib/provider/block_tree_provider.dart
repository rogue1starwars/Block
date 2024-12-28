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

  void updateField({
    required String parentId,
    required dynamic value,
    required int index,
  }) {
    print("\n\n\n");
    print("Updating field");
    print("Parent ID: $parentId");
    print("Value: $value");
    print("\n\n\n");
    Block? updateFieldHelper({
      required Block parent,
      required String parentId,
      required dynamic value,
      required int index,
    }) {
      if (parent.fields != null && parent.id == parentId) {
        final newFields = [
          for (int i = 0; i < parent.fields!.length; i++)
            if (i == index)
              parent.fields![i].copyWith(value: value)
            else
              parent.fields![i]
        ];
        return parent.copyWith(fields: newFields);
      } else {
        if (parent.children == null) return null;
        return recursive(
          callback: updateFieldHelper,
          parent: parent,
          parentId: parentId,
          value: value,
          index: index,
        );
      }
    }

    final newBlock = updateFieldHelper(
      parent: state,
      parentId: parentId,
      value: value,
      index: index,
    );

    if (newBlock != null) {
      state = newBlock;
    }
  }

  List<Input> createNewChildren({
    required Block parent,
    required Block value,
    required int index,
  }) {
    switch (parent.children![index]) {
      case ValueInput _:
        final ValueInput targetChild = parent.children![index] as ValueInput;
        final List<Input> newChildren = [
          for (int i = 0; i < parent.children!.length; i++)
            if (i == index)
              targetChild.copyWith(block: value)
            else
              parent.children![i]
        ];
        return newChildren;
      case StatementInput _:
        final StatementInput targetChild =
            parent.children![index] as StatementInput;
        List<Block> newBlocks = [
          ...(targetChild.blocks),
          value,
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

  Block? recursive({
    required Function callback,
    required Block parent,
    required String parentId,
    required dynamic value,
    required int index,
  }) {
    for (int i = 0; i < parent.children!.length; i++) {
      switch (parent.children![i]) {
        case ValueInput input:
          if (input.block != null) {
            final result = callback(
              parent: input.block!,
              parentId: parentId,
              value: value,
              index: index,
            );
            if (result != null) {
              return parent.copyWith(
                children: [
                  ...parent.children!.sublist(0, i),
                  input.copyWith(block: result),
                  ...parent.children!.sublist(i + 1),
                ],
              );
            }
          }
        case StatementInput input:
          for (int j = 0; j < input.blocks.length; j++) {
            final result = callback(
              parent: input.blocks[j],
              parentId: parentId,
              value: value,
              index: index,
            );
            if (result != null) {
              return parent.copyWith(
                children: [
                  ...parent.children!.sublist(0, i),
                  input.copyWith(blocks: [
                    ...input.blocks.sublist(0, j),
                    result,
                    ...input.blocks.sublist(j + 1),
                  ]),
                  ...parent.children!.sublist(i + 1),
                ],
              );
            }
          }
      }
    }
    return null;
  }

  void addBlock({
    required String parentId,
    required Block value,
    required int index,
  }) {
    Block? addBlockHelper({
      required Block parent,
      required String parentId,
      required Block value,
      required int index,
    }) {
      if (parent.children == null) return null;
      if (parent.children!.length <= index) return null;

      if (parent.id == parentId) {
        print("Adding block");
        final newChildren = createNewChildren(
          parent: parent,
          value: value,
          index: index,
        );
        // Just for testing...
        final newParent = parent.copyWith(children: newChildren);
        return newParent;
      } else {
        return recursive(
          callback: addBlockHelper,
          parent: parent,
          parentId: parentId,
          value: value,
          index: index,
        );
        // return null;
      }
    }

    final newBlock = addBlockHelper(
      parent: state,
      parentId: parentId,
      value: value,
      index: index,
    );
    if (newBlock != null) {
      state = newBlock;
    }
  }

  void deleteBlock({
    required String id,
  }) {
    Block? deleteBlockHelper({
      required String id,
      required Block parent,
    }) {
      if (parent.children == null) return null;
      if (parent.id == id) {
        return null;
      }

      for (int i = 0; i < parent.children!.length; i++) {
        switch (parent.children![i]) {
          case ValueInput input:
            if (input.block == null) return null;
            if (input.block!.id == id) {
              final newParent = parent.copyWith(children: [
                ...parent.children!.sublist(0, i),
                input.copyWith(delete: true),
                ...parent.children!.sublist(i + 1),
              ]);
              return newParent;
            }
            final result = deleteBlockHelper(
              id: id,
              parent: input.block!,
            );
            if (result == null) return null;
            return parent.copyWith(
              children: [
                ...parent.children!.sublist(0, i),
                input.copyWith(block: result),
                ...parent.children!.sublist(i + 1),
              ],
            );
          case StatementInput input:
            for (int j = 0; j < input.blocks.length; j++) {
              if (input.blocks[j].id == id) {
                return parent.copyWith(children: [
                  ...parent.children!.sublist(0, i),
                  input.copyWith(blocks: [
                    ...input.blocks.sublist(0, j),
                    ...input.blocks.sublist(j + 1),
                  ]),
                  ...parent.children!.sublist(i + 1),
                ]);
              }
              final result = deleteBlockHelper(
                id: id,
                parent: input.blocks[j],
              );
              if (result != null) {
                return parent.copyWith(
                  children: [
                    ...parent.children!.sublist(0, i),
                    input.copyWith(blocks: [
                      ...input.blocks.sublist(0, j),
                      result,
                      ...input.blocks.sublist(j + 1),
                    ]),
                    ...parent.children!.sublist(i + 1),
                  ],
                );
              }
            }
        }
      }
      return null;
    }

    state = deleteBlockHelper(id: id, parent: state) ?? state;
  }
}

final blockTreeProvider =
    StateNotifierProvider<BlockTreeNotifier, Block>((ref) {
  return BlockTreeNotifier();
});
