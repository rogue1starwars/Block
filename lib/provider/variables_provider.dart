import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/models/variables.dart';
import 'package:phoneduino_block/utils/type.dart';

class VariablesNotifier extends StateNotifier<Map<String, Variable>> {
  VariablesNotifier()
      : super({
          'x': Variable(value: 0, type: BlockTypes.number, name: 'x'),
          'y': Variable(value: 'default', type: BlockTypes.string, name: 'y'),
          'z': Variable(value: 'default2', type: BlockTypes.string, name: 'z'),
        });

  void updateAllVariables(Map<String, Variable> newVariables) {
    state = newVariables;
  }

  void clearAllVariables() {
    print('Clearing all variables');
    final Map<String, Variable> newState = {...state};
    for (var key in newState.keys) {
      if (newState[key]?.value == null) {
        continue;
      }
      print(newState[key]?.value);
      if (newState[key]?.value is StreamSubscription) {
        print(key);
        newState[key]?.value.cancel();
      }
      if (newState[key]?.value is Timer) {
        print(key);
        newState[key]?.value.cancel();
      }
    }
    newState.removeWhere((key, value) => key[0] == '_');
    newState.forEach((key, value) {
      newState[key] = value.copyWith(delete: true);
    });
    state = newState;
  }

  void renameVariable(String oldName, String newName) {
    if (hasVariable(oldName)) {
      final Variable variable = state[oldName]!.copyWith(name: newName);
      state = {...state}..remove(oldName);
      state = {...state}..[newName] = variable;
    }
  }

  bool hasVariable(String name) {
    return state.containsKey(name);
  }

  BlockTypes? getVariableType(String name) {
    if (!hasVariable(name)) {
      return null;
    }
    return state[name]!.type;
  }

  void deleteVariable(String name) {
    if (hasVariable(name)) {
      state = {...state}..remove(name);
    }
  }

  void setVariable(String name, dynamic value, BlockTypes type) {
    state = {...state}..[name] = Variable(value: value, type: type, name: name);
  }

  void updateVariable(String name, dynamic value) {
    if (hasVariable(name)) {
      state = {...state}..[name]!.value = value;
    }
  }

  dynamic getVariable(String name) {
    if (!hasVariable(name)) {
      return null;
    }
    return state[name]!.value;
  }
}

final variablesProvider =
    StateNotifierProvider<VariablesNotifier, Map<String, Variable>>(
        (ref) => VariablesNotifier());
