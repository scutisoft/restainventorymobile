


import '../model/parameterModel.dart';
import 'utils.dart';

Future<List<ParamModel>> getParamEssential({String extraParam=""}) async{
  List<ParamModel> par= [
    ParamModel(Key: "LoginUserId", Type: "int", Value: await getLoginUserId()),
    ParamModel(Key: "IsMobile", Type: "int", Value: 1),
    ParamModel(Key: "database", Type: "String", Value: await getDatabaseName()),
    ParamModel(Key: "DeviceId", Type: "String", Value: await getDeviceIdUtil()),
    ParamModel(Key: "TransactionDeviceId", Type: "String", Value: 2),

  ];
  if(extraParam.isNotEmpty){
    String a=await getExtraParamUtil(extraParam);
    par.add(ParamModel(Key: extraParam, Type: "String", Value: a.isNotEmpty?a:null));
  }
  return par;
}

getLoginUserId() async{
  String userId=await getSharedPrefStringUtil("userid");
  return userId.isEmpty?"0":userId;
}

getDatabaseName() async{
  return await getSharedPrefStringUtil("DatabaseName");
}

getDeviceIdUtil() async{
  return await getSharedPrefStringUtil("DeviceId");
}


getExtraParamUtil(String param) async{
  return await getSharedPrefStringUtil(param);
}

getBaseUrlUtil() async{
  return await getSharedPrefStringUtil("BaseUrl");
}


