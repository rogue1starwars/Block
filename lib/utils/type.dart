enum BlockTypes {
  number,
  string,
  boolean,
  none,
  intervalList,
  timer,
  image,
}

Map<BlockTypes, dynamic> initialValue = {
  BlockTypes.number: 0,
  BlockTypes.string: 'default',
  BlockTypes.boolean: false,
  BlockTypes.none: null,
  BlockTypes.intervalList: [],
  BlockTypes.timer: null,
};

enum FieldTypes {
  number,
  string,
  dropdown,
  variableNames,
}
