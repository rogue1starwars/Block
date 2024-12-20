import 'package:phoneduino_block/utils/type.dart';

class Variable {
  dynamic value;
  final BlockTypes type;
  final String name;

  Variable({
    this.value,
    required this.type,
    required this.name,
  });
}
