import 'package:phoneduino_block/data/block_data_core.dart';
import 'package:phoneduino_block/utils/type.dart';

List<BlockBluePrint> filterBlockData(
    List<BlockTypes>? filter, List<BlockBluePrint> blockData) {
  if (filter == null) {
    return blockData;
  }

  return blockData.where((block) {
    return filter.contains(block.returnType);
  }).toList();
}
