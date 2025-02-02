import 'package:phoneduino_block/models/block.dart';
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

class NumericField extends Field {
  NumericField({
    required super.label,
    required super.value,
  }) : super(type: BlockTypes.number);

  @override
  factory NumericField.fromJson({
    required init,
    required dynamic value,
  }) {
    return NumericField(
      label: init.label,
      value: value,
    );
  }
  @override
  NumericField copyWith({
    String? label,
    BlockTypes? type,
    dynamic value,
  }) {
    return NumericField(
      label: label ?? this.label,
      value: value ?? this.value,
    );
  }
}

class StringField extends Field {
  StringField({
    required super.label,
    required super.value,
  }) : super(type: BlockTypes.string);

  @override
  factory StringField.fromJson({
    required init,
    required dynamic value,
  }) {
    return StringField(
      label: init.label,
      value: value,
    );
  }
  @override
  StringField copyWith({
    String? label,
    BlockTypes? type,
    dynamic value,
  }) {
    return StringField(
      label: label ?? this.label,
      value: value ?? this.value,
    );
  }
}
