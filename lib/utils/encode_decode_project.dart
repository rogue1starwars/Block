import 'dart:convert';

import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/variables.dart';

String encode(Block root, Map<String, Variable> variables) {
  try {
    final Map<String, dynamic> variablesJson = variables.map((key, value) {
      return MapEntry(key, value.toJson());
    });
    variablesJson.removeWhere((key, value) => key[0] == '_');

    final Map<String, dynamic> projectData = {
      'block_tree': root.toJson(),
      'variables': variablesJson,
    };
    return jsonEncode(projectData);
  } catch (e) {
    throw 'Failed to save block tree: $e';
  }
}

// Map<String, dynamic> decode(String projectData, Block root) {
//   try {
//     final Map<String, dynamic> projectDataMap = jsonDecode(projectData);

//     final Map<String, dynamic> blockTreeData = projectDataMap['block_tree'];
//     Block newRoot = Block.fromJson(blockTreeData);

//     final Map<String, dynamic> variablesData = projectDataMap['variables'];
//     final Map<String, Variable> variables = variablesData.map((key, value) {
//       return MapEntry(key, Variable.fromJson(value));
//     });

//     return {
//       'root': newRoot,
//       'variables': variables,
//     };
//   } catch (e) {
//     throw 'Failed to load block tree: $e';
//   }
// }
