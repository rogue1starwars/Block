import 'package:hive/hive.dart';

part 'blockTypes.g.dart';

@HiveType(typeId: 5)
enum BlockTypes {
  @HiveField(0)
  number,
  @HiveField(1)
  string,
  @HiveField(2)
  boolean,
  @HiveField(3)
  none,
  @HiveField(4)
  intervalList,
}
