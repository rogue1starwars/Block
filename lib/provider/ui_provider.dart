import 'package:flutter_riverpod/flutter_riverpod.dart';

class UiState {
  final List<String> messageQueue;
  const UiState({this.messageQueue = const []});
}

class UiNotifier extends StateNotifier<UiState> {
  UiNotifier() : super(const UiState());

  void showMessage(String message) {
    state = UiState(messageQueue: [...state.messageQueue, message]);
  }

  void removeMessage() {
    if (state.messageQueue.isNotEmpty) {
      state = UiState(messageQueue: state.messageQueue.sublist(1));
    }
  }
}

final uiProvider =
    StateNotifierProvider<UiNotifier, UiState>((ref) => UiNotifier());
