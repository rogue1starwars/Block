import 'package:phoneduino_block/models/block.dart';

class Input {
  final String label;
  final String? type;
  final List<Block>? blocks;
  final Block? block;
  Input({
    required this.label,
    this.block,
    this.blocks,
    this.type,
  });

  Input copyWith({
    String? label,
    String? type,
    List<Block>? blocks,
    Block? block,
  }) {
    return Input(
      label: label ?? this.label,
      type: type ?? this.type,
      blocks: blocks ?? this.blocks,
      block: block ?? this.block,
    );
  }
}

class StatementInput extends Input {
  StatementInput({
    required super.label,
    super.type,
    required super.blocks,
  });
}

class ValueInput extends Input {
  ValueInput({
    required super.label,
    super.type,
    required super.block,
  });
}
