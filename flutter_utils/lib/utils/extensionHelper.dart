import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../flutter_utils_platform_interface.dart';
import '../getUiNotifier.dart';
import '../model/parameterModel.dart';
import 'alertDialog.dart';
import 'apiUtils.dart';
import 'extensionUtils.dart';

bool needLog=false;
enum WT{
  list,
  map
}

enum DevelopmentMode{
  json,
  traditional
}

class TraditionalParam{
  List<ParamModel> paramList;
  String insertSp;
  String updateSp;
  String getByIdSp;
  String? executableSp;
  TraditionalParam({this.paramList=const [],this.getByIdSp="",this.insertSp="",this.updateSp="",this.executableSp});
}

abstract class ExtensionCallback {
  String getType();
  getValue();
  setValue(var value);
  bool validate();
  String getDataName();
  void clearValues();
  int getOrderBy();
  setOrderBy(int oBy);
  void triggerChange();
}


abstract class HappyExtensionHelperCallback{
  void assignWidgets() async{}
}

abstract class HappyExtensionHelperCallback2{
  String getPageIdentifier();
}

mixin HappyExtensionHelper implements HappyExtensionHelperCallback2{
  Future<List<ParamModel>> getFrmCollection(var ws) async{ List<bool> a=[]; List<ParamModel> b=[]; bool c=false; Future d(var f) async{ String g=""; try{ g=f.getType(); }catch(e){} if(g=='inputTextField' || g=='HE_Text'){ if(f.hasInput??false){ if(f.required??false){ c=f.validate(); a.add(c); if(c){ b.add(ParamModel(Key: f.getDataName(), Type: 'string', Value: f.getValue(), orderBy: f.getOrderBy())); } } else{ b.add(ParamModel(Key: f.getDataName(), Type: 'string', Value: f.getValue(), orderBy: f.getOrderBy())); } } } if(g=='searchDrp' || g=='searchDrp2'){ if(f.hasInput??false){ if(f.required??false){ c=f.validate(); a.add(c); if(c){ b.add(ParamModel(Key: f.getDataName(), Type: 'string', Value: f.getValue(), orderBy: f.getOrderBy())); } } else{ b.add(ParamModel(Key: f.getDataName(), Type: 'string', Value: f.getValue(), orderBy: f.getOrderBy())); } } } if(g=='hidden'){ if(f.hasInput??false){ b.add(ParamModel(Key: f.getDataName(), Type: 'string', Value: f.getValue(), orderBy: f.getOrderBy())); } } if(g=='locationPicker'){ if(f.hasInput??false){ if(f.required??false){ c=f.validate(); a.add(c); if(c){ b.add(ParamModel(Key: f.getDataName(), Type: 'string', Value: f.getValue(), orderBy: f.getOrderBy())); } } else{ b.add(ParamModel(Key: f.getDataName(), Type: 'string', Value: f.getValue(), orderBy: f.getOrderBy())); } } } if(g=='multiImage' || g=='singleImagePicker'){ if(f.hasInput??false){ if(f.required??false){ c=f.validate(); a.add(c); if(c){ b.add(ParamModel(Key: f.getDataName(), Type: 'string', Value: await f.getValue(), orderBy: f.getOrderBy())); } } else{ b.add(ParamModel(Key: f.getDataName(), Type: 'string', Value: await f.getValue(), orderBy: f.getOrderBy())); } } } } WT wt=getWT(ws); if(wt==WT.list){ for (var w in ws){ await d(w); } } else if(wt==WT.map){ for (var w in ws.entries){ await d(w.value); } } bool h=!a.any((element) => element==false); return h?b:[]; }
  setFrmValuesV2(var ws,List r){ void d(a,b){ String c=""; try{ c=b.getType(); if(c.isNotEmpty){ b.setValue(a); } }catch(e){} } if (r!=null && r.isNotEmpty) { for(int i=0;i<r.length;i++){ r[i].forEach((k,v){ var g=null; WT wt=getWT(ws); if(wt==WT.list){ var h=ws.where((x) => x.getDataName()==k).toList(); if(h.length==1){ g=h[0]; } } else if(wt==WT.map){ g=ws[k.toString()]; } if(g!=null){ d(v, g); } }); } } }
  setFrmValues(var ws,List v,{bool fromClearAll=false}){void a(x,y){ String z=""; try{ z=y.getType(); if(z.isNotEmpty){ if(fromClearAll){ y.clearValues(); } y.setValue(x['value']); y.setOrderBy(x['orderBy']??1); } }catch(e){ } } if (v!=null && v.isNotEmpty) { for (var m in v) { var n=null; WT wt=getWT(ws); if(wt==WT.list){ var o=ws.where((x) => x.getDataName()==m['key']).toList(); if(o.length==1){ n=o[0]; } } else if(wt==WT.map){ n=ws[m['key'].toString()]; } if(n!=null){ a(m, n); } } }}
  var parsedJson;
  List<dynamic> valueArray=[];
  parseJson(var widgets,String pageIdentifier,{String? dataJson,bool needToSetValue=true, DevelopmentMode developmentMode= DevelopmentMode.traditional,TraditionalParam? traditionalParam,Function(dynamic)? resCb, RxBool? loader,bool fromUrl=true,String extraParam=""}) async{ if(developmentMode==DevelopmentMode.json){ if(fromUrl){ await getUIFromDb(widgets,pageIdentifier, dataJson); } else{ String data = await DefaultAssetBundle.of(Get.context!).loadString(pageIdentifier); parsedJson=jsonDecode(data); if(parsedJson.containsKey('valueArray')){ valueArray=parsedJson['valueArray']; } if(valueArray.isNotEmpty){ setFrmValues(widgets, valueArray); } } } else if(developmentMode==DevelopmentMode.traditional){ bool a=(dataJson!=null && dataJson!=''); if(traditionalParam != null && (traditionalParam.executableSp!=null || a)){ List<ParamModel> b=traditionalParam.paramList.isNotEmpty?traditionalParam.paramList:[]; b.add(ParamModel(Key: "SpName", Type: "String", Value:a?traditionalParam.getByIdSp: traditionalParam.executableSp)); if(a){ var parsedDataJson=jsonDecode(dataJson); if(HE_IsMap(parsedDataJson)){ parsedDataJson.forEach((key, value) { b.add(ParamModel(Key: key, Type: "String", Value: value)); }); } } b.addAll(await getParamEssential(extraParam: extraParam)); await FlutterUtilsPlatform.apiInstance.getInvoke(b,loader: loader).then((c){ if(c[0]){ var d=jsonDecode(c[1]); if(d['Table']!=null){ if(a && needToSetValue){ setFrmValuesV2(widgets, d['Table']); } } if(resCb!=null){ resCb(d); } else{ valueArray=d['Table']; } } else{ CustomAlertUtil().cupertinoAlert(c[1]); } }); } } }
  Future<void> getUIFromDb(var a,String b,String? c) async{ await GetUiNotifier().getUiJson(b,true,dataJson: c).then((d){ if(d!="null" && d.toString().isNotEmpty){ var f=jsonDecode(d); parsedJson=jsonDecode(f['Table'][0]['PageJson']); if(parsedJson.containsKey('valueArray')){ valueArray=parsedJson['valueArray']; } if(valueArray.isNotEmpty){ setFrmValues(a, valueArray); } } }); }
  Future<void> postUIJson(String pageIdentifier,String dataJson,String action,{Function? successCallback, DevelopmentMode developmentMode= DevelopmentMode.traditional,TraditionalParam? traditionalParam,RxBool? loader ,String extraParam=""}) async{ if(developmentMode==DevelopmentMode.json){ await GetUiNotifier().postUiJson( pageIdentifier, "N'$dataJson'", {"actionType":action}).then((a){ if(a[0]){ var b=jsonDecode(a[1]); String errorMsg=b["TblOutPut"][0]["@Message"]??""; if(successCallback!=null){ successCallback(b); } else{ addNotifications(NotificationType.success,msg: errorMsg); } } else{ CustomAlertUtil().cupertinoAlert(a[1]); } }); } else if(developmentMode==DevelopmentMode.traditional){ if(traditionalParam != null && traditionalParam.executableSp!=null){ List<ParamModel> g=traditionalParam.paramList.isNotEmpty?traditionalParam.paramList:[]; g.add(ParamModel(Key: "SpName", Type: "String", Value: traditionalParam.executableSp)); g.addAll(await getParamEssential(extraParam: extraParam)); if(dataJson.isNotEmpty){ var h=jsonDecode(dataJson); if(HE_IsMap(h)){ h.forEach((k, l) { g.add(ParamModel(Key: k, Type: "String", Value: l)); }); } } await FlutterUtilsPlatform.apiInstance.getInvoke(g,loader: loader).then((o){ if(o[0]){ var p=jsonDecode(o[1]); String q=p["TblOutPut"][0]["@Message"]??""; if(successCallback!=null){ successCallback(p); } else{ addNotifications(NotificationType.success,msg: q); } } else{ CustomAlertUtil().cupertinoAlert(o[1]); } }); } else{ assignWidgetErrorToast("Params Not Found...", ""); } } }
  void sysSubmit(dynamic widgets,{ Function? successCallback, String action="", bool isEdit=false, bool needCustomValidation=false, Function? onCustomValidation, bool clearFrm=true, bool closeFrmOnSubmit=true, DevelopmentMode developmentMode= DevelopmentMode.traditional, TraditionalParam? traditionalParam, bool needSuccessCb=false,required RxBool? loader ,String extraParam="" }) async{ void r(e){ String f=e["TblOutPut"][0]["@Message"]??""; if(closeFrmOnSubmit){ Get.back(); } addNotifications(NotificationType.success,msg: f); if(clearFrm){ clearAll(widgets); } if(successCallback!=null && e['Table']!=null && e['Table'].length>0){ successCallback(e); } else if(needSuccessCb){ successCallback!(e); } } bool a=true; if(needCustomValidation){ a=onCustomValidation!(); } List<ParamModel> b= await getFrmCollection(widgets); if(b.isNotEmpty && a){ if(a){ try{ b.sort((x,y)=>x.orderBy.compareTo(y.orderBy)); }catch(e){ CustomAlertUtil().cupertinoAlert("Error HE002 $e"); } if(developmentMode==DevelopmentMode.json){ postUIJson(getPageIdentifier(), jsonEncode(b.map((e) => e.toJsonHE()).toList()), action.isNotEmpty?action: isEdit?"Update":"Insert", successCallback: r, developmentMode: developmentMode ); } else if(developmentMode==DevelopmentMode.traditional){ if(traditionalParam==null){ assignWidgetErrorToast("Traditional Params not found...", ""); return; } traditionalParam.executableSp=isEdit?traditionalParam.updateSp:traditionalParam.insertSp; traditionalParam.paramList=b; postUIJson(getPageIdentifier(), "", "", successCallback: r, developmentMode: developmentMode, traditionalParam: traditionalParam,loader: loader, extraParam: extraParam ); } } } }
  void sysDelete(arr,primaryKey,primaryArr,{Function? successCallback,String dataJson="",String content="Are you sure want to delete ?", bool isCustomDialog=false}){ if(isCustomDialog){ postUIJson(getPageIdentifier(), dataJson, "Delete", successCallback: (e){ if(successCallback!=null){ successCallback(e); } } ); } else{ CustomAlertUtil( callback: (){ postUIJson(getPageIdentifier(), dataJson, "Delete", successCallback: (e){ String errorMsg=e["TblOutPut"][0]["@Message"]; addNotifications(NotificationType.success,msg: errorMsg); if(successCallback!=null){ successCallback(e); } } ); }, cancelCallback: (){ } ).yesOrNoDialog2('assets/Slice/like.png', content, false); } }
  void sysDeleteHE_ListView(dynamic a,String b,{Function? successCallback,String dataJson="", String content="Are you sure want to delete ?",DevelopmentMode developmentMode=DevelopmentMode.traditional, TraditionalParam? traditionalParam,RxBool? loader,bool isCustomDialog=false}){ if(isCustomDialog){ postUIJson(getPageIdentifier(), dataJson, "Delete", successCallback: (e){ if(successCallback!=null){ successCallback(e); } if(a!=null && e["Table"]!=null && e["Table"].length>0){ a.updateArrById(b, e["Table"][0],action: ActionType.deleteById); } }, developmentMode: developmentMode, traditionalParam: traditionalParam, loader: loader ); } else{ CustomAlertUtil( callback: (){ postUIJson(getPageIdentifier(), dataJson, "Delete", successCallback: (e){ String errorMsg=e["TblOutPut"][0]["@Message"]; addNotifications(NotificationType.success,msg: errorMsg); if(successCallback!=null){ successCallback(e); } if(a!=null && e["Table"]!=null && e["Table"].length>0){ a.updateArrById(b, e["Table"][0],action: ActionType.deleteById); } }, developmentMode: developmentMode, traditionalParam: traditionalParam, loader: loader ); }, cancelCallback: (){ } ).yesOrNoDialog2('assets/Slice/like.png', content, false); } }
  fillTreeDrp(var widgets,String key,{var refId,var page,bool clearValues=true,var refType,bool toggleRequired=false,var hierarchicalId, String spName="USP_GetMasterDetail",String extraParam="",bool needToDisable=false,Function(dynamic)? resCb}) async{ var fWid=foundWidgetByKey(widgets, key); if(fWid!=null){ if(clearValues){ fWid.clearValues(); } getMasterDrp(page, key, refId, refType,hierarchicalId,spName,extraParam: extraParam).then((value){ fWid.setValue(value); if(toggleRequired){ fWid.required=value.isNotEmpty; try{ fWid.isValid.value=true; }catch(e){assignWidgetErrorToast("IsValid",e);} } if(needToDisable){ try{ fWid.isEnabled.value=value.isNotEmpty; }catch(e){} } if(resCb!=null){ resCb(value); } }); } }
  foundWidgetByKey(var ws,String k,{bool needSetValue=false,dynamic value}){ WT wt=getWT(ws); if(wt==WT.list){ for (var a in ws) { if(a.getDataName()==k){ if(needSetValue){ a.setValue(value); } return a; } } } else if(wt==WT.map){ var fw=ws[k]; if(needSetValue && fw!=null){ fw.setValue(value); } return fw; } return null; }
  void clearAll(var a){ setFrmValues(a, valueArray,fromClearAll: true);}
  void clearAllV2(var a){ WT wt=getWT(a); if(wt==WT.list){ for (var b in a){ b.clearValues(); } } else if(wt==WT.map){ for (var b in a.entries){ b.value.clearValues(); } } }
  void updateEnable(var ws,k,{bool isEnabled=false}){ var a=foundWidgetByKey(ws, k); if(a!=null){ a.isEnabled=isEnabled; a.reload.value=!a.reload.value; if(!isEnabled){ a.clearValues(); } } }
  @override
  String getPageIdentifier(){ return "";}
  void clearOnDispose(){parsedJson=null; valueArray.clear(); }
}