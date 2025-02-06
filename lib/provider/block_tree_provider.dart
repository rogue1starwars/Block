import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/data/block_data.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/utils/type.dart';
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

  void removeVariable({
    required String name,
  }) {
    bool removeVariableInFields(List<Field> fields) {
      for (int i = 0; i < fields.length; i++) {
        if (fields[i].type == FieldTypes.variableNames &&
            fields[i].value == name) {
          print("Removing variable from field from removeVariableInFields");
          return true;
        }
      }
      return false;
    }

    Block? removeVariableHelper({
      required String name,
      required Block parent,
    }) {
      if (parent.children.isEmpty) return null;

      final Map<int, Input> newChildren = {};
      for (int i = 0; i < parent.children.length; i++) {
        switch (parent.children[i]) {
          case ValueInput input:
            if (input.block == null) continue;
            final bool isInField = removeVariableInFields(input.block!.fields);
            if (isInField) {
              print("Removing variable from field");
              newChildren[i] = input.copyWith(delete: true);
              continue;
            }
            final result = removeVariableHelper(
              name: name,
              parent: input.block!,
            );
            if (result == null) continue;
            newChildren[i] = input.copyWith(block: result);
          case StatementInput input:
            List<Block> newStatementBlocks = [];
            for (int j = 0; j < input.blocks.length; j++) {
              final bool isInField =
                  removeVariableInFields(input.blocks[j].fields);
              if (isInField) {
                continue;
              }
              final result = removeVariableHelper(
                name: name,
                parent: input.blocks[j],
              );
              if (result == null) {
                newStatementBlocks = [...newStatementBlocks, input.blocks[j]];
                continue;
              }
              newStatementBlocks = [...newStatementBlocks, result];
            }

            newChildren[i] = input.copyWith(blocks: newStatementBlocks);
        }
      }
      if (newChildren.isEmpty) return null;
      return parent.copyWith(children: [
        for (int i = 0; i < parent.children.length; i++)
          if (newChildren.containsKey(i))
            newChildren[i]!
          else
            parent.children[i]
      ]);
    }

    final newBlock = removeVariableHelper(name: name, parent: state);
    if (newBlock != null) {
      state = newBlock;
    }
  }

  void renameVariable({
    required String oldName,
    required String newName,
  }) {
    List<Field>? renameVariableInFields(List<Field> fields) {
      for (int i = 0; i < fields.length; i++) {
        if (fields[i].type == FieldTypes.variableNames &&
            fields[i].value == oldName) {
          return [
            for (Field field in fields)
              if (field.type == FieldTypes.variableNames &&
                  field.value == oldName)
                field.copyWith(value: newName)
              else
                field
          ];
        }
      }
      return null;
    }

    Block? renameVariableHelper({
      required String oldName,
      required String newName,
      required Block parent,
    }) {
      if (parent.children.isEmpty) return null;

      Map<int, Input> newChildren = {};
      for (int i = 0; i < parent.children.length; i++) {
        switch (parent.children[i]) {
          case ValueInput input:
            if (input.block == null) continue;
            final List<Field>? newFields = renameVariableInFields(input.block!
                .fields); // new fields which can be null, or has a new value when update needed
            final result = renameVariableHelper(
              oldName: oldName,
              newName: newName,
              parent: input.block!,
            ); // result, which can be null, or has a new value when update needed

            // if newfields or result is not null, return the new parent with updated children
            if (result == null && newFields == null) continue;

            final Block newBlock = result ?? input.block!;

            newChildren[i] =
                input.copyWith(block: newBlock.copyWith(fields: newFields));

          case StatementInput input:
            List<Block> newStatementBlocks = [];
            for (int j = 0; j < input.blocks.length; j++) {
              // new fields which can be null, or has a new value when update needed
              final List<Field>? newFields =
                  renameVariableInFields(input.blocks[j].fields);
              final result = renameVariableHelper(
                oldName: oldName,
                newName: newName,
                parent: input.blocks[j],
              );
              if (result == null && newFields == null) {
                newStatementBlocks = [...newStatementBlocks, input.blocks[j]];
                continue;
              }
              final newBlock = result ?? input.blocks[j];
              newStatementBlocks = [
                ...newStatementBlocks,
                newBlock.copyWith(fields: newFields)
              ];
            }
            newChildren[i] = input.copyWith(blocks: newStatementBlocks);
        }
      }
      if (newChildren.isEmpty) return null;
      return parent.copyWith(children: [
        for (int i = 0; i < parent.children.length; i++)
          if (newChildren.containsKey(i))
            newChildren[i]!
          else
            parent.children[i]
      ]);
    }

    final newBlock = renameVariableHelper(
      oldName: oldName,
      newName: newName,
      parent: state,
    );
    if (newBlock != null) {
      state = newBlock;
    }
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
    final Block? targetBlock = findBlock(id: id);
    if (targetBlock == null) return;

    final targetBlockCopied =
        targetBlock.copyWith(id: const Uuid().v4()); // copy with new id

    bool inserted = insertBlock(siblingId: siblingId, value: targetBlockCopied);
    if (inserted) deleteBlock(id: id);
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
                if (!input.filter!.contains(value.returnType)) {
                  continue;
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
                if (input.filter != null) {
                  if (!input.filter!.contains(value.returnType)) {
                    continue;
                  }
                }
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
