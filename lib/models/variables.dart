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
    final BlockTypes type = BlockTypes.values.firstWhere(
      (element) => element.name == json['type'],
    );
    return Variable(
      value: initialValue[type],
      type: type,
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'name': name,
    };
  }

  Variable copyWith({
    dynamic value,
    BlockTypes? type,
    String? name,
    bool delete = false,
  }) {
    if (delete) {
      return Variable(
        value: null,
        type: type ?? this.type,
        name: name ?? this.name,
      );
    }
    return Variable(
      value: value ?? this.value,
      type: type ?? this.type,
      name: name ?? this.name,
    );
  }
}
