import 'package:phoneduino_block/data/block_data.dart';
import 'package:phoneduino_block/models/blockTypes.dart';

List<BlockBluePrint> filterBlockData(Map<BlockTypes, bool>? filter) {
  if (filter == null) {
    return blockData;
  }

  return blockData.where((block) {
    return filter.containsKey(block.returnType)
        ? filter[block.returnType]!
        : true;
  }).toList();
}
