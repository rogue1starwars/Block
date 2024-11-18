import 'package:flutter_riverpod/flutter_riverpod.dart';

class Block {
  final String id;
  final List<dynamic> inputParameters;
  final List<List<Block>> children;
  final Function(List<dynamic>, List<List<Block>>) originalFunc;

  Block({
    required this.id,
    required this.inputParameters,
    required this.children,
    required this.originalFunc,
  });

  dynamic execute() {
    return originalFunc(inputParameters, children);
  }

  Block copyWith({
    String? id,
    List<dynamic>? inputParameters,
    List<List<Block>>? children,
    Function(List<dynamic>, List<List<Block>>)? originalFunc,
  }) {
    return Block(
      id: id ?? this.id,
      inputParameters: inputParameters ?? this.inputParameters,
      children: children ?? this.children,
      originalFunc: originalFunc ?? this.originalFunc,
    );
  }
}

class BlockTreeNotifier extends StateNotifier<Block> {
  BlockTreeNotifier()
      : super(Block(
            id: '0',
            inputParameters: [],
            children: [],
            originalFunc:
                (List<dynamic> inputParameters, List<List<Block>> children) {
              for (int i = 0; i < children[0].length; i++) {
                children[0][i].execute();
              }
            }));

  void addBlock({
    Block? parent,
    required Block block,
    required int index,
    required String parentId,
  }) {
    parent ??= state;

    if (parent.id == parentId) {
      List<List<Block>> newChildren = [
        for (int i = 0; i < parent.children.length; i++)
          if (i == index) [...parent.children[i], block] else parent.children[i]
      ];
      parent.copyWith(children: newChildren);
      return;
    } else {
      for (int i = 0; i < parent.children.length; i++) {
        addBlock(
          parent: parent.children[i][0],
          block: block,
          index: index,
          parentId: parentId,
        );
      }
    }
  }

  void removeBlock({Block? parent, required String id}) {
    parent ??= state;

    for (int i = 0; i < parent.children.length; i++) {
      for (int j = 0; j < parent.children[i].length; j++) {
        if (parent.children[i][j].id == id) {
          List<List<Block>> newChildren = [
            ...parent.children.sublist(0, i),
            [
              ...parent.children[i].sublist(0, j),
              ...parent.children[i].sublist(j + 1)
            ],
            ...parent.children.sublist(i + 1)
          ];
          parent.copyWith(children: newChildren);
          return;
        } else {
          removeBlock(parent: parent.children[i][0], id: id);
        }
      }
    }
  }
}
