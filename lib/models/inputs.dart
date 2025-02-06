import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/utils/type.dart';

class Input {
  final String label;
  final List<BlockTypes>? filter;
  // factory Input.fromJson(Map<String, dynamic> json) {
  //   if (json.containsKey('blocks')) {
  //     return StatementInput(
  //       label: json['label'],
  //       blocks: (json['blocks'] as List)
  //           .map((block) => Block.fromJson(block))
  //           .toList(),
  //     );
  //   } else {
  //     return ValueInput(
  //       label: json['label'],
  //       block: Block.fromJson(json['block']),
  //     );
  //   }
  // }
  Input({
    required this.label,
    this.filter,
  });
}

class StatementInput extends Input {
  final List<Block> blocks;
  factory StatementInput.fromJson({
    required StatementInput init,
    required List<Map<String, dynamic>> json,
  }) {
    /*
      json format
      [
        {
          "id": "2",
          "name": "Serial Begin",
          "fields": [
            {
              "value": 9600,
            }
          ],
        }
        {
          "id": "3",
          "name": "Serial Begin",
          "fields": [
            {
              "value": 9600,
            }
          ],
        }
      ]
    */
    return StatementInput(
      label: init.label,
      filter: init.filter,
      blocks: json.map((block) => Block.fromJson(block)).toList(),
    );
  }
  StatementInput({
    required super.label,
    required this.blocks,
    super.filter,
  });

  List<Map<String, dynamic>> toJson() {
    return blocks.map((block) => block.toJson()).toList();
  }

  StatementInput copyWith({
    String? label,
    List<BlockTypes>? filter,
    List<Block>? blocks,
  }) {
    return StatementInput(
      label: label ?? this.label,
      filter: filter ?? this.filter,
      blocks: blocks ?? this.blocks,
    );
  }
}

class ValueInput extends Input {
  final Block? block;
  factory ValueInput.fromJson({
    required ValueInput init,
    required Map<String, dynamic> json,
  }) {
    /*
      json format
      {
        "id": "2",
        "name": "Serial Begin",
        "fields": [
          {
            "value": 9600,
          }
        ],
      }
    */
    return ValueInput(
      label: init.label,
      filter: init.filter,
      block: Block.fromJson(json),
    );
  }
  ValueInput({
    required super.label,
    super.filter,
    required this.block,
  });

  Map<String, dynamic>? toJson() {
    if (block == null) {
      return null;
    }
    return block!.toJson();
  }

  ValueInput copyWith({
    String? label,
    List<BlockTypes>? filter,
    Block? block,
    bool delete = false,
  }) {
    return ValueInput(
      label: label ?? this.label,
      filter: filter ?? this.filter,
      block: delete ? null : (block ?? this.block),
    );
  }
}
