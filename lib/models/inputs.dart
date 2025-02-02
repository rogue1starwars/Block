import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/blockTypes.dart';
import 'package:hive/hive.dart';

part 'inputs.g.dart';

@HiveType(typeId: 1)
class Input {
  @HiveField(0)
  final String label;
  @HiveField(1)
  final Map<BlockTypes, bool>? filter;
  Input({
    required this.label,
    this.filter,
  });
}

@HiveType(typeId: 2)
class StatementInput extends Input {
  @HiveField(2)
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

@HiveType(typeId: 3)
class ValueInput extends Input {
  @HiveField(2)
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
    bool delete = false,
  }) {
    return ValueInput(
      label: label ?? this.label,
      filter: filter ?? this.filter,
      block: delete ? null : (block ?? this.block),
    );
  }
}
