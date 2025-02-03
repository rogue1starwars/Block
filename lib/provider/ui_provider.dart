import 'package:flutter_riverpod/flutter_riverpod.dart';

class UiState {
  final List<String> messageDequeue;
  const UiState({this.messageDequeue = const []});
}

class UiNotifier extends StateNotifier<UiState> {
  UiNotifier() : super(const UiState());

  void showMessage(String message) {
    final newMessages = [message, ...state.messageDequeue];
    state = UiState(
        messageDequeue:
            newMessages.length > 10 ? newMessages.sublist(0, 10) : newMessages);
  }

  void clearMessage() {
    state = const UiState(messageDequeue: []);
  }

  void removeMessage() {
    state = UiState(messageDequeue: state.messageDequeue.sublist(1));
  }
}

final uiProvider =
    StateNotifierProvider<UiNotifier, UiState>((ref) => UiNotifier());
