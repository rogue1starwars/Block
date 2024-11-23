class Field {
  final String label;
  final String type;
  final dynamic value;
  Field({
    required this.label,
    required this.value,
    required this.type,
  });

  Field copyWith({
    String? label,
    String? type,
    dynamic value,
  }) {
    return Field(
      label: label ?? this.label,
      value: value ?? this.value,
      type: type ?? this.type,
    );
  }
}

class NumericField extends Field {
  NumericField({
    required super.label,
    required super.value,
  }) : super(type: 'number');
}

class StringField extends Field {
  StringField({
    required super.label,
    required super.value,
  }) : super(type: 'string');
}
