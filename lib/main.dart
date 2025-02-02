import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/models/variables.dart';
import 'package:phoneduino_block/models/blockTypes.dart';
import 'package:phoneduino_block/widgets/home_page.dart';

late Box<Block> blocks;
void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(BlockTypesAdapter());
  Hive.registerAdapter(BlockAdapter());
  Hive.registerAdapter(FieldAdapter());
  Hive.registerAdapter(StringFieldAdapter());
  Hive.registerAdapter(NumericFieldAdapter());
  Hive.registerAdapter(InputAdapter());
  Hive.registerAdapter(ValueInputAdapter());
  Hive.registerAdapter(StatementInputAdapter());
  Hive.registerAdapter(VariableAdapter());

  blocks = await Hive.openBox<Block>('blocks');

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
