import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/provider/block_tree_provider.dart';
import 'package:phoneduino_block/models/fields.dart';

// class TextFieldWidget extends ConsumerWidget {
//   final TextField field;
//   const TextFieldWidget({super.key, required this.field});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Row(
//         children: [
//           Text(field.label),
          
//         ],
//       )
//   }
// }

class TextFieldWidget extends ConsumerStatefulWidget {
  const TextFieldWidget({super.key, required this.field});

  @override
  _TextFieldWidgetState createState() => _TextFieldWidgetState();
}

class TextFieldWidget extends ConsumerState<TextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.field.label),
        TextField(
          onChanged: (value) {
            // TODO implement this by getting the parent block as a parameter
            ref.read(blockTreeProvider.notifier).updateFieldInput(
            );
          },
        ),
      ],
    );
  }
}

