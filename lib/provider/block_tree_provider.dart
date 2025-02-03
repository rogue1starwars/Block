import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/data/block_data.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:uuid/uuid.dart';

class BlockTreeNotifier extends StateNotifier<Block> {
  BlockTreeNotifier()
      : super(Block.fromBluePrint(
          block: blockData[0],
          id: '0',
        ));

  void updateRoot(Block value) {
    state = value;
  }

  void updateField({
    required String parentId,
    required dynamic value,
    required int index,
  }) {
    Block? updateFieldHelper({
      required Block parent,
      required String parentId,
      required dynamic value,
      required int index,
    }) {
      if (parent.id == parentId) {
        final newFields = [
          for (int i = 0; i < parent.fields.length; i++)
            if (i == index)
              parent.fields[i].copyWith(value: value)
            else
              parent.fields[i]
        ];
        return parent.copyWith(fields: newFields);
      } else {
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
    switch (parent.children[index]) {
      case ValueInput _:
        final ValueInput targetChild = parent.children[index] as ValueInput;
        final List<Input> newChildren = [
          for (int i = 0; i < parent.children.length; i++)
            if (i == index)
              targetChild.copyWith(block: value)
            else
              parent.children[i]
        ];
        return newChildren;
      case StatementInput _:
        final StatementInput targetChild =
            parent.children[index] as StatementInput;
        List<Block> newBlocks = [
          ...(targetChild.blocks),
          value,
        ];
        final List<Input> newChildren = [
          for (int i = 0; i < parent.children.length; i++)
            if (i == index)
              targetChild.copyWith(blocks: newBlocks)
            else
              parent.children[i]
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
    for (int i = 0; i < parent.children.length; i++) {
      switch (parent.children[i]) {
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
                  ...parent.children.sublist(0, i),
                  input.copyWith(block: result),
                  ...parent.children.sublist(i + 1),
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
                  ...parent.children.sublist(0, i),
                  input.copyWith(blocks: [
                    ...input.blocks.sublist(0, j),
                    result,
                    ...input.blocks.sublist(j + 1),
                  ]),
                  ...parent.children.sublist(i + 1),
                ],
              );
            }
          }
      }
    }
    return null;
  }

  Block? findBlock({required String id}) {
    Block? findBlockHelper({
      required String id,
      required Block parent,
    }) {
      if (parent.children.isEmpty) return null;

      if (parent.id == id) {
        return parent;
      }

      for (int i = 0; i < parent.children.length; i++) {
        switch (parent.children[i]) {
          case ValueInput input:
            if (input.block == null) continue;
            if (input.block!.id == id) {
              return input.block;
            }
            final result = findBlockHelper(
              id: id,
              parent: input.block!,
            );
            if (result != null) return result;
            break;
          case StatementInput input:
            for (int j = 0; j < input.blocks.length; j++) {
              if (input.blocks[j].id == id) {
                return input.blocks[j];
              }
              final result = findBlockHelper(
                id: id,
                parent: input.blocks[j],
              );
              if (result != null) return result;
            }
        }
      }
      return null;
    }

    final result = findBlockHelper(id: id, parent: state);
    if (result != null) {
      return result;
    }
    return null;
  }

  void moveBlock({
    required String id,
    required String siblingId,
  }) {
    Block? targetBlock = findBlock(id: id);
    if (targetBlock == null) return;

    targetBlock =
        targetBlock.copyWith(id: const Uuid().v4()); // copy with new id

    bool inserted = insertBlock(siblingId: siblingId, value: targetBlock);
    if (inserted) deleteBlock(id: id);
    targetBlock = state;
  }

  bool insertBlock({
    required String siblingId,
    required Block value,
  }) {
    Block? insertBlockHelper({
      required Block parent,
      required String siblingId,
      required Block value,
    }) {
      if (parent.id == siblingId) {
        return null;
      }

      for (int i = 0; i < parent.children.length; i++) {
        switch (parent.children[i]) {
          case ValueInput input:
            if (input.block == null) return null;
            if (input.block!.id == siblingId) {
              if (input.filter != null) {
                if (input.filter!.containsKey(value.returnType)) {
                  if (input.filter![value.returnType] == false) {
                    continue;
                  }
                }
              }
              final newParent = parent.copyWith(children: [
                ...parent.children.sublist(0, i),
                input.copyWith(block: value),
                ...parent.children.sublist(i + 1),
              ]);
              return newParent;
            }
            final result = insertBlockHelper(
              siblingId: siblingId,
              value: value,
              parent: input.block!,
            );
            if (result == null) continue;
            return parent.copyWith(
              children: [
                ...parent.children.sublist(0, i),
                input.copyWith(block: result),
                ...parent.children.sublist(i + 1),
              ],
            );
          case StatementInput input:
            for (int j = 0; j < input.blocks.length; j++) {
              if (input.blocks[j].id == siblingId) {
                return parent.copyWith(children: [
                  ...parent.children.sublist(0, i),
                  input.copyWith(blocks: [
                    ...input.blocks.sublist(0, j),
                    value,
                    ...input.blocks.sublist(j),
                  ]),
                  ...parent.children.sublist(i + 1),
                ]);
              }
              final result = insertBlockHelper(
                siblingId: siblingId,
                value: value,
                parent: input.blocks[j],
              );
              if (result != null) {
                return parent.copyWith(
                  children: [
                    ...parent.children.sublist(0, i),
                    input.copyWith(blocks: [
                      ...input.blocks.sublist(0, j),
                      result,
                      ...input.blocks.sublist(j + 1),
                    ]),
                    ...parent.children.sublist(i + 1),
                  ],
                );
              }
            }
        }
      }
      return null;
    }

    final newBlock = insertBlockHelper(
      parent: state,
      siblingId: siblingId,
      value: value,
    );
    if (newBlock != null) {
      state = newBlock;
      return true;
    }
    return false;
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
      if (parent.children.length <= index) return null;

      if (parent.id == parentId) {
        print("Adding block");
        final newChildren = createNewChildren(
          parent: parent,
          value: value,
          index: index,
        );
        return parent.copyWith(children: newChildren);
      } else {
        return recursive(
          callback: addBlockHelper,
          parent: parent,
          parentId: parentId,
          value: value,
          index: index,
        );
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
      if (parent.id == id) {
        return null;
      }

      for (int i = 0; i < parent.children.length; i++) {
        switch (parent.children[i]) {
          case ValueInput input:
            if (input.block == null) continue;
            if (input.block!.id == id) {
              final newParent = parent.copyWith(children: [
                ...parent.children.sublist(0, i),
                input.copyWith(delete: true),
                ...parent.children.sublist(i + 1),
              ]);
              return newParent;
            }
            final result = deleteBlockHelper(
              id: id,
              parent: input.block!,
            );
            if (result == null) continue;
            return parent.copyWith(
              children: [
                ...parent.children.sublist(0, i),
                input.copyWith(block: result),
                ...parent.children.sublist(i + 1),
              ],
            );
          case StatementInput input:
            for (int j = 0; j < input.blocks.length; j++) {
              if (input.blocks[j].id == id) {
                return parent.copyWith(children: [
                  ...parent.children.sublist(0, i),
                  input.copyWith(blocks: [
                    ...input.blocks.sublist(0, j),
                    ...input.blocks.sublist(j + 1),
                  ]),
                  ...parent.children.sublist(i + 1),
                ]);
              }
              final result = deleteBlockHelper(
                id: id,
                parent: input.blocks[j],
              );
              if (result != null) {
                return parent.copyWith(
                  children: [
                    ...parent.children.sublist(0, i),
                    input.copyWith(blocks: [
                      ...input.blocks.sublist(0, j),
                      result,
                      ...input.blocks.sublist(j + 1),
                    ]),
                    ...parent.children.sublist(i + 1),
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
