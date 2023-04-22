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
    setFrmValuesV2(widgets, valueArray);
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
    String spName="USP_GetMasterDetail",String extraParam="",bool needToDisable=false,Function(dynamic)? resCb})async{
      fillTreeDrp(widgets, key,refId: refId,page: page,clearValues: clearValues,refType: refType,toggleRequired: toggleRequired,
      hierarchicalId: hierarchicalId,spName: spName,extraParam: extraParam,needToDisable: needToDisable,resCb: resCb);
  }

  @override
  void clearAllV4(widgets){
    clearAllV2(widgets);
  }

  @override
  void sysSubmitV1(dynamic widgets,{
    Function? successCallback,
    String action="",
    bool isEdit=false,
    bool needCustomValidation=false,
    Function? onCustomValidation,
    bool clearFrm=true,
    bool closeFrmOnSubmit=true,
    DevelopmentMode developmentMode= DevelopmentMode.traditional,
    TraditionalParam? traditionalParam,
    bool needSuccessCb=false, RxBool? loader,String extraParam=""
  }) async{
    sysSubmit(widgets,successCallback: successCallback,action: action,isEdit: isEdit,needCustomValidation: needCustomValidation,
        onCustomValidation: onCustomValidation,clearFrm: clearFrm,closeFrmOnSubmit: closeFrmOnSubmit,developmentMode: developmentMode,traditionalParam: traditionalParam,
        needSuccessCb: needSuccessCb,loader: loader,extraParam: extraParam);
  }


  @override
  void foundWidgetByKeyV1(var widgets,String key,{bool needSetValue=false,dynamic value}){
    foundWidgetByKey(widgets, key,needSetValue: needSetValue,value: value);
  }

  @override
  void clearOnDisposeV1(){
    clearOnDispose();
  }


  @override
  void sysDeleteHE_ListViewV1(dynamic he_listViewBody,String primaryKey,{Function? successCallback,String dataJson="",
    String content="Are you sure want to delete ?",DevelopmentMode developmentMode=DevelopmentMode.traditional,
    TraditionalParam? traditionalParam,RxBool? loader,bool isCustomDialog=false}){
    sysDeleteHE_ListView(he_listViewBody, primaryKey,successCallback: successCallback,dataJson: dataJson,
        developmentMode: developmentMode,content: content,traditionalParam: traditionalParam,loader:loader,isCustomDialog: isCustomDialog);
  }


}

