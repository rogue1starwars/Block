import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class IntervalList {
  final List<Timer> intervals;
  const IntervalList({required this.intervals});
}

class IntervalNotifier extends StateNotifier<IntervalList> {
  IntervalNotifier() : super(const IntervalList(intervals: []));

  void addInterval(Timer interval) {
    state = IntervalList(intervals: [...state.intervals, interval]);
  }

  void removeInterval(Timer interval) {
    state = IntervalList(
        intervals:
            state.intervals.where((element) => element != interval).toList());
    interval.cancel();
  }

  void clearInterval() {
    for (var interval in state.intervals) {
      interval.cancel();
    }
    state = const IntervalList(intervals: []);
  }
}

final intervalProvider = StateNotifierProvider<IntervalNotifier, IntervalList>(
    (ref) => IntervalNotifier());
