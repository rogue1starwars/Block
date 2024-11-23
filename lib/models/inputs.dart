import 'package:phoneduino_block/models/block.dart';

class Input {
  final String label;
  final String? type;
  // final List<Block>? blocks;
  // final Block? block;
  Input({
    required this.label,
    // this.block,
    // this.blocks,
    this.type,
  });
}

class StatementInput extends Input {
  final List<Block> blocks;
  StatementInput({
    required super.label,
    required this.blocks,
    super.type,
  });

  StatementInput copyWith({
    String? label,
    String? type,
    List<Block>? blocks,
  }) {
    return StatementInput(
      label: label ?? this.label,
      type: type ?? this.type,
      blocks: blocks ?? this.blocks,
    );
  }
}

class ValueInput extends Input {
  final Block? block;
  ValueInput({
    required super.label,
    super.type,
    required this.block,
  });

  ValueInput copyWith({
    String? label,
    String? type,
    Block? block,
  }) {
    return ValueInput(
      label: label ?? this.label,
      type: type ?? this.type,
      block: block ?? this.block,
    );
  }
}
