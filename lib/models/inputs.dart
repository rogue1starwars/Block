import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/utils/type.dart';

class Input {
  final String label;
  final Map<BlockTypes, bool>? filter;
  Input({
    required this.label,
    this.filter,
  });
}

class StatementInput extends Input {
  final List<Block> blocks;
  StatementInput({
    required super.label,
    required this.blocks,
    super.filter,
  });

  StatementInput copyWith({
    String? label,
    Map<BlockTypes, bool>? filter,
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
  ValueInput({
    required super.label,
    super.filter,
    required this.block,
  });

  ValueInput copyWith({
    String? label,
    Map<BlockTypes, bool>? filter,
    Block? block,
  }) {
    return ValueInput(
      label: label ?? this.label,
      filter: filter ?? this.filter,
      block: block ?? this.block,
    );
  }
}
