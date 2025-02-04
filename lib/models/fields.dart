import 'package:phoneduino_block/utils/type.dart';

class Field {
  final String label;
  final FieldTypes type;
  final dynamic value;
  final List<String> options;

  Field({
    required this.label,
    required this.value,
    required this.type,
    this.options = const [],
  }) {
    assert(type != FieldTypes.dropdown || options.isNotEmpty,
        'Dropdown field must have options');
  }

  factory Field.fromJson({
    required Field init,
    required dynamic value,
  }) {
    return Field(
      label: init.label,
      options: init.options,
      value: value,
      type: init.type,
    );
  }

  dynamic toJson() {
    return value;
  }

  Field copyWith({
    String? label,
    FieldTypes? type,
    dynamic value,
    List<String>? options,
  }) {
    return Field(
      label: label ?? this.label,
      value: value ?? this.value,
      type: type ?? this.type,
      options: options ?? this.options,
    );
  }
}
