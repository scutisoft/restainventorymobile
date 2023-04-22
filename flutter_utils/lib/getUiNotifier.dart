import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../model/parameterModel.dart';
import 'package:get/get.dart';

import 'flutter_utils_platform_interface.dart';
import 'utils/apiUtils.dart';
class GetUiNotifier {
  Future<dynamic> getUiJson(String pageId,bool isNeedUi,{String? dataJson}) async { List<ParamModel> parameters=[ ParamModel(Key: "SpName", Type: "String", Value: "USP_GetPageInfo"), ParamModel(Key: "LoginUserId", Type: "int", Value: await gL()), ParamModel(Key: "PageIdentifier", Type: "String", Value: pageId), ParamModel(Key: "DataJson", Type: "String", Value: dataJson), ParamModel(Key: "IsNeedUI", Type: "int", Value: isNeedUi), ParamModel(Key: "ActionType", Type: "String", Value: "Get"), ParamModel(Key: "database", Type: "String", Value: await gD()), ]; var body={ "Fields": parameters.map((e) => e.toJson()).toList() }; String val=""; try{ await FlutterUtilsPlatform.apiInstance.getInvoke(parameters).then((value){ if(value[0]){ val=value[1]; } else{ Get.dialog( CupertinoAlertDialog( title: Icon(Icons.error_outline,color: Colors.red,size: 50,), content: Text("${value[1]}", style: TextStyle(fontSize: 18),), )); } }); return val; }catch(e){ } } Future<dynamic> postUiJson(String pageId,String dataJson,Map clickEvent) async { List<ParamModel> parameters=[ ParamModel(Key: "SpName", Type: "String", Value: "USP_GetPageInfo"), ParamModel(Key: "LoginUserId", Type: "int", Value: await gL()), ParamModel(Key: "PageIdentifier", Type: "String", Value: pageId), ParamModel(Key: "DataJson", Type: "String", Value: dataJson), ParamModel(Key: "IsNeedUI", Type: "int", Value: false), ParamModel(Key: "ActionType", Type: "String", Value: clickEvent['actionType']), ParamModel(Key: "database", Type: "String", Value:await gD()), ]; var val=[]; try{ await FlutterUtilsPlatform.apiInstance.getInvoke(parameters).then((value){ val=value; }); return val; }catch(e){ } }
}