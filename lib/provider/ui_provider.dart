import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class UiState {
  final List<String> messageDequeue;
  static const List<Color> colors = [Colors.red, Colors.green, Colors.blue, Colors.yellow, Colors.purple];
  final int? colorIndex;
  const UiState({this.messageDequeue = const [], this.colorIndex });

  UiState copyWith({List<String>? messageDequeue, int? colorIndex}) {
    return UiState(
        messageDequeue: messageDequeue ?? this.messageDequeue,
        colorIndex: colorIndex ?? this.colorIndex);
  }
}

class UiNotifier extends StateNotifier<UiState> {
  UiNotifier() : super(UiState());

  void changeColor(int colorIndex) {
    state = state.copyWith(colorIndex: colorIndex);
  }

  void showMessage(String message) {
    final newMessages = [message, ...state.messageDequeue];
    state = state.copyWith(messageDequeue: newMessages.length > 10
        ? newMessages.sublist(0, 10)
        : newMessages);
  }

  void clearMessage() {
    state =  UiState();
  }

  void removeMessage() {
    if (state.messageDequeue.isEmpty) return;
    state = state.copyWith(messageDequeue: state.messageDequeue.sublist(1));
  }
}

final uiProvider =
    StateNotifierProvider<UiNotifier, UiState>((ref) => UiNotifier());
