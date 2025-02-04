// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class ModifyVariables extends ConsumerStatefulWidget {
//   const ModifyVariables({super.key});

//   @override
//   ConsumerState<ModifyVariables> createState() => _ModifyVariablesState();
// }

// class _ModifyVariablesState extends ConsumerState<ModifyVariables> {
//   Future<void> _showDialog(BuildContext context) {
//     return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Add Variable'),
//           content: ,
//           actions: <Widget>[
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 if (_controller.text.isNotEmpty) {
//                   ref.read(variablesProvider.notifier).setVariable(
//                         _controller.text,
//                         null,
//                         _selectedType,
//                       );
//                   Navigator.pop(context);
//                 }
//               },
//               child: const Text('Add'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }
