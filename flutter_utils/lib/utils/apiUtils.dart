


import '../model/parameterModel.dart';
import 'utils.dart';

Future<List<ParamModel>> getParamEssential({String extraParam=""}) async{
  List<ParamModel> par= [
    ParamModel(Key: "LoginUserId", Type: "int", Value: await gL()),
    ParamModel(Key: "IsMobile", Type: "int", Value: 1),
    ParamModel(Key: "database", Type: "String", Value: await gD()),
    ParamModel(Key: "DeviceId", Type: "String", Value: await gDI()),
    ParamModel(Key: "TransactionDeviceId", Type: "String", Value: 2),

  ];
  if(extraParam.isNotEmpty){
    String a=await gE(extraParam);
    par.add(ParamModel(Key: extraParam, Type: "String", Value: a.isNotEmpty?a:null));
  }
  return par;
}

gL() async{
  String userId=await getSharedPrefStringUtil("userid");
  return userId.isEmpty?"0":userId;
}

gD() async{
  return await getSharedPrefStringUtil("DatabaseName");
}

gDI() async{
  return await getSharedPrefStringUtil("DeviceId");
}


gE(String param) async{
  return await getSharedPrefStringUtil(param);
}

gBU() async{
  return await getSharedPrefStringUtil("BaseUrl");
}


