import 'package:flutter_riverpod/flutter_riverpod.dart';

const bool isDragging = false;

final isDraggingProvider = StateProvider<bool>((ref) => isDragging);
