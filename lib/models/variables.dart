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
    // if (value is! num && value is! String && value is! bool) {
    //   return {};
    // }
    if (type == BlockTypes.number) {
      if (value is! num) {
        return {
          'value': 0,
          'type': type.name,
          'name': name,
        };
      }
    }
    if (type == BlockTypes.string) {
      if (value is! String) {
        return {
          'value': 'default',
          'type': type.name,
          'name': name,
        };
      }
    }
    if (type == BlockTypes.boolean) {
      if (value is! bool) {
        return {
          'value': false,
          'type': type.name,
          'name': name,
        };
      }
    }
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
