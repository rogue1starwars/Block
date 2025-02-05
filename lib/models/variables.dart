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

  Variable copyWith({
    dynamic value,
    BlockTypes? type,
    String? name,
  }) {
    return Variable(
      value: value ?? this.value,
      type: type ?? this.type,
      name: name ?? this.name,
    );
  }
}
