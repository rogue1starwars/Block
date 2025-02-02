import 'package:phoneduino_block/utils/type.dart';

class Field {
  final String label;
  final BlockTypes type;
  final dynamic value;

  Field({
    required this.label,
    required this.value,
    required this.type,
  });

  factory Field.fromJson({
    required init,
    required dynamic value,
  }) {
    return Field(
      label: init.label,
      value: value,
      type: init.type,
    );
  }

  dynamic toJson() {
    return value;
  }

  Field copyWith({
    String? label,
    BlockTypes? type,
    dynamic value,
  }) {
    return Field(
      label: label ?? this.label,
      value: value ?? this.value,
      type: type ?? this.type,
    );
  }
}
