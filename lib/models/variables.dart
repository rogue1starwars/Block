import 'package:phoneduino_block/models/blockTypes.dart';

import 'package:hive/hive.dart';

part 'variables.g.dart';

@HiveType(typeId: 4)
class Variable {
  @HiveField(0)
  dynamic value;
  @HiveField(1)
  final BlockTypes type;
  @HiveField(2)
  final String name;

  Variable({
    this.value,
    required this.type,
    required this.name,
  });
}
