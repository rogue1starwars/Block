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

  factory Variable.fromJson(Map<String, dynamic> json) {
    return Variable(
      value: json['value'],
      type: BlockTypes.values.firstWhere(
        (element) => element.name == json['type'],
      ),
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'type': type.name,
      'name': name,
    };
  }

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
