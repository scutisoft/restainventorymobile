
class ParamModel{
  String Key;
  String Type;
  dynamic Value;
  int orderBy;
  ParamModel({required this.Key, required this.Type,required this.Value,this.orderBy=1});

/*  factory ParamModel.fromJson(Map<String,dynamic> json){
    return ParamModel(
      MaterialCategoryId: json['MaterialCategoryId'],
      MaterialCategoryName: json['MaterialCategoryName'],
    );
  }*/

  Map<String, dynamic> toJson() => {
    "Key": Key,
    "Type": Type,
    "Value": Value,
    "OrderBy": orderBy,
  };
  Map<String, dynamic> toJsonHE() => {
    "key": Key,
    "value": Value,
  };
  dynamic get(String propertyName) {
    var _mapRep = toJson();
    if (_mapRep.containsKey(propertyName)) {
      return _mapRep[propertyName];
    }
    throw ArgumentError('property not found');
  }
}