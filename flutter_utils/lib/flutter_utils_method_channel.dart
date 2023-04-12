import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_utils/utils/apiUtils.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'flutter_utils_platform_interface.dart';
import 'model/parameterModel.dart';


class MethodChannelFlutterUtils  extends FlutterUtilsPlatform with HappyExtensionHelper{

  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_utils');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<List<ParamModel>> getFrmCol(var widgets) async{
    return getFrmCollection(widgets);
  }

  @override
  void setFrmValuesV1(var widgets,List valueArray,{bool fromClearAll=false}){
    setFrmValues(widgets, valueArray,fromClearAll: fromClearAll);
  }

  @override
  void parseJsonV1(var widgets,String pageIdentifier,{String? dataJson,bool needToSetValue=true,
    DevelopmentMode developmentMode= DevelopmentMode.traditional,TraditionalParam? traditionalParam,Function(dynamic)? resCb,
    RxBool? loader,bool fromUrl=true,String extraParam=""})async{
    parseJson(widgets, pageIdentifier,dataJson: dataJson,needToSetValue: needToSetValue,developmentMode: developmentMode,traditionalParam: traditionalParam,
    resCb: resCb,loader: loader,fromUrl: fromUrl,extraParam: extraParam);
  }

  @override
  void fillTreeDrpV1(var widgets,String key,{var refId,var page,bool clearValues=true,var refType,bool toggleRequired=false,var hierarchicalId,
    String spName="USP_GetMasterDetail",String extraParam=""})async{
      fillTreeDrp(widgets, key,refId: refId,page: page,clearValues: clearValues,refType: refType,toggleRequired: toggleRequired,
      hierarchicalId: hierarchicalId,spName: spName,extraParam: extraParam);
  }
}

class ApiManger extends FlutterUtilsPlatform{
  int timeOut=30;

  onTme(RxBool loader){
    loader.value=false;
    return [false,"Connection TimeOut"];
  }

  onTme2(){
    return [false,"Connection TimeOut"];
  }

  @override
  Future<List> getInvoke(List<ParamModel> parameterList,{ String url="",RxBool? loader}) async {
    loader!.value=true;
    try{
      if(url.isEmpty){
        url=await getBaseUrlUtil();
        url="$url/api/Mobile/GetInvoke";
      }
      var body={
        "Fields": parameterList.map((e) => e.toJson()).toList()
      };
      final response = await http.post(Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: json.encode(body)
      ).timeout(Duration(seconds: timeOut),onTimeout: ()=>onTme(loader));
      loader.value=false;
      print(response.body);
      if(response.statusCode==200){

        return [true,response.body];
      }
      else{
        var msg;
        msg=json.decode(response.body);
        return [false,msg['Message']];
      }
    }
    catch(e){
      loader.value=false;
      return [false,"Catch Api"];
    }
  }

  @override
  Future<List> getInvokeLazy(List<ParamModel> parameterList,{ String url="/api/Mobile/GetInvoke"}) async {
    try{
      url=await getBaseUrlUtil();
      url="$url/api/Mobile/GetInvoke";
      var body={
        "Fields": parameterList.map((e) => e.toJson()).toList()
      };
      final response = await http.post(Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: json.encode(body)
      ).timeout(Duration(seconds: timeOut),onTimeout: ()=>onTme2());
      print(response.body);
      if(response.statusCode==200){
        return [true,response.body];
      }
      else{
        var msg;
        msg=json.decode(response.body);
        return [false,msg['Message']];
      }
    }
    catch(e){
      return [false,"Catch Api"];
    }
  }
}