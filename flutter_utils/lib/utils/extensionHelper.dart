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
enum WidgetType{
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
  Future<List<ParamModel>> getFrmCollection(var widgets) async{

    List<bool> validateList=[];
    List<ParamModel> parameterList=[];
    bool validate=false;

    Future widgetValidation(var widget) async{
      String elementType="";
      try{
        elementType=widget.getType();
      }catch(e){}

      if(elementType=='inputTextField' || elementType=='HE_Text'){
        if(widget.hasInput??false){
          if(widget.required??false){
            validate=widget.validate();
            validateList.add(validate);
            if(validate){
              parameterList.add(ParamModel(Key: widget.getDataName(), Type: 'string', Value: widget.getValue(), orderBy: widget.getOrderBy()));
            }
          }
          else{
            parameterList.add(ParamModel(Key: widget.getDataName(), Type: 'string', Value: widget.getValue(), orderBy: widget.getOrderBy()));
          }
        }
      }
      if(elementType=='searchDrp' || elementType=='searchDrp2'){
        if(widget.hasInput??false){
          if(widget.required??false){
            validate=widget.validate();
            validateList.add(validate);
            if(validate){
              parameterList.add(ParamModel(Key: widget.getDataName(), Type: 'string', Value: widget.getValue(), orderBy: widget.getOrderBy()));
            }
          }
          else{
            parameterList.add(ParamModel(Key: widget.getDataName(), Type: 'string', Value: widget.getValue(), orderBy: widget.getOrderBy()));
          }
        }
      }
      if(elementType=='hidden'){
        if(widget.hasInput??false){
          parameterList.add(ParamModel(Key: widget.getDataName(), Type: 'string', Value: widget.getValue(), orderBy: widget.getOrderBy()));
        }
      }
      if(elementType=='locationPicker'){
        if(widget.hasInput??false){
          if(widget.required??false){
            validate=widget.validate();
            validateList.add(validate);
            if(validate){
              parameterList.add(ParamModel(Key: widget.getDataName(), Type: 'string', Value: widget.getValue(), orderBy: widget.getOrderBy()));
            }
          }
          else{
            parameterList.add(ParamModel(Key: widget.getDataName(), Type: 'string', Value: widget.getValue(), orderBy: widget.getOrderBy()));
          }
        }
      }
      if(elementType=='multiImage' || elementType=='singleImagePicker'){
        if(widget.hasInput??false){
          if(widget.required??false){
            validate=widget.validate();
            validateList.add(validate);
            if(validate){
              parameterList.add(ParamModel(Key: widget.getDataName(), Type: 'string', Value: await widget.getValue(), orderBy: widget.getOrderBy()));
            }
          }
          else{
            parameterList.add(ParamModel(Key: widget.getDataName(), Type: 'string', Value: await widget.getValue(), orderBy: widget.getOrderBy()));
          }
        }
      }
    }

    WidgetType widgetType=getWidgetType(widgets);
    if(widgetType==WidgetType.list){
      for (var widget in widgets){
        await widgetValidation(widget);
      }
    }
    else if(widgetType==WidgetType.map){
      for (var widget in widgets.entries){
        await widgetValidation(widget.value);
      }
    }
    bool isValid=!validateList.any((element) => element==false);
    return isValid?parameterList:[];
  }

  //Not in use ,WidgetType widgetType=WidgetType.list,Map<String,dynamic> widgetMap=const {}
  setFrmValuesV2(var widgets,List response){
    void widgetValueUpdate(value,widget){
      String widgetType="";
      try{
        widgetType=widget.getType();
        if(widgetType.isNotEmpty){
          widget.setValue(value);
          //widget.setOrderBy(value['orderBy']??1);
        }
      }catch(e){
        // CustomAlertUtil().cupertinoAlert("${widget.getDataName()} Error HE001 \n $e");
      }
    }
    if (response!=null && response.isNotEmpty) {
      for(int i=0;i<response.length;i++){
        response[i].forEach((key,value){

          var widget=null;
          WidgetType widgetType=getWidgetType(widgets);
          if(widgetType==WidgetType.list){
            var foundWid=widgets.where((x) => x.getDataName()==key).toList();
            if(foundWid.length==1){
              widget=foundWid[0];
            }
          }
          else if(widgetType==WidgetType.map){
            widget=widgets[key.toString()];
          }
          if(widget!=null){
            widgetValueUpdate(value, widget);
          }
        });
      }
    }
  }

  setFrmValues(var widgets,List valueArray,{bool fromClearAll=false}){
    void widgetValueUpdate(value,widget){
      String widgetType="";
      try{
        widgetType=widget.getType();
        if(widgetType.isNotEmpty){
          if(fromClearAll){
            widget.clearValues();
          }
          widget.setValue(value['value']);
          widget.setOrderBy(value['orderBy']??1);
        }
      }catch(e){
        // CustomAlertUtil().cupertinoAlert("${widget.getDataName()} Error HE001 \n $e");
      }
    }

    if (valueArray!=null && valueArray.isNotEmpty) {
      for (var value in valueArray) {
        var widget=null;
        WidgetType widgetType=getWidgetType(widgets);
        if(widgetType==WidgetType.list){
          var foundWid=widgets.where((x) => x.getDataName()==value['key']).toList();
          if(foundWid.length==1){
            widget=foundWid[0];
          }
        }
        else if(widgetType==WidgetType.map){
          widget=widgets[value['key'].toString()];
        }
        if(widget!=null){
          widgetValueUpdate(value, widget);
        }
      }
    }
  }

  var parsedJson;
  List<dynamic> valueArray=[];



  parseJson(var widgets,String pageIdentifier,{String? dataJson,bool needToSetValue=true,
    DevelopmentMode developmentMode= DevelopmentMode.traditional,TraditionalParam? traditionalParam,Function(dynamic)? resCb,
    RxBool? loader,bool fromUrl=true,String extraParam=""}) async{

    if(developmentMode==DevelopmentMode.json){
      if(fromUrl){
        await getUIFromDb(widgets,pageIdentifier, dataJson);
      }
      else{
        String data = await DefaultAssetBundle.of(Get.context!).loadString(pageIdentifier);
        parsedJson=jsonDecode(data);
        if(parsedJson.containsKey('valueArray')){
          valueArray=parsedJson['valueArray'];
        }
        if(valueArray.isNotEmpty){
          setFrmValues(widgets, valueArray);
        }
        //print(valueArray);
      }
    }
    else if(developmentMode==DevelopmentMode.traditional){
      bool isGetById=(dataJson!=null && dataJson!='');

      //console("(traditionalParam.executableSp!=null || isGetById) ${(traditionalParam!.executableSp!=null || isGetById)}");
      if(traditionalParam != null && (traditionalParam.executableSp!=null || isGetById)){
        //  console("isGetById ${isGetById}");
        List<ParamModel> finalParams=traditionalParam.paramList.isNotEmpty?traditionalParam.paramList:[];
        finalParams.add(ParamModel(Key: "SpName", Type: "String", Value:isGetById?traditionalParam.getByIdSp: traditionalParam.executableSp));
        if(isGetById){
          var parsedDataJson=jsonDecode(dataJson);
          if(HE_IsMap(parsedDataJson)){
            parsedDataJson.forEach((key, value) {
              finalParams.add(ParamModel(Key: key, Type: "String", Value: value));
            });
          }
        }
        finalParams.addAll(await getParamEssential(extraParam: extraParam));
        await FlutterUtilsPlatform.apiInstance.getInvoke(finalParams,loader: loader).then((value){
          if(value[0]){
            var parsed=jsonDecode(value[1]);
            if(parsed['Table']!=null){
              if(isGetById && needToSetValue){
                setFrmValuesV2(widgets, parsed['Table']);
              }
            }
            if(resCb!=null){
              resCb(parsed);
            }
            else{
              valueArray=parsed['Table'];
            }

          }
          else{
            CustomAlertUtil().cupertinoAlert(value[1]);
          }
        });
      }
      /*else{
        assignWidgetErrorToast("Params Not Found...", "");
      }*/
    }

  }

  Future<void> getUIFromDb(var widgets,String pageIdentifier,String? dataJson) async{
    await GetUiNotifier().getUiJson(pageIdentifier,true,dataJson: dataJson).then((value){
      print("----getUIFromDb-----");
      if(value!="null" && value.toString().isNotEmpty){
        var parsed=jsonDecode(value);
        parsedJson=jsonDecode(parsed['Table'][0]['PageJson']);
        if(parsedJson.containsKey('valueArray')){
          valueArray=parsedJson['valueArray'];
        }

        if(valueArray.isNotEmpty){
          setFrmValues(widgets, valueArray);
        }
      }
    });
  }

  Future<void> postUIJson(String pageIdentifier,String dataJson,String action,{Function? successCallback,
    DevelopmentMode developmentMode= DevelopmentMode.traditional,TraditionalParam? traditionalParam,RxBool? loader
    ,String extraParam=""}) async{
    //"N'$dataJson'"
    if(developmentMode==DevelopmentMode.json){
      //"N'$dataJson'"
      await GetUiNotifier().postUiJson( pageIdentifier, "N'$dataJson'", {"actionType":action}).then((value){
        //print("----- post    $value");
        if(value[0]){
          // console(value);
          var parsed=jsonDecode(value[1]);
          String errorMsg=parsed["TblOutPut"][0]["@Message"]??"";
          if(successCallback!=null){
            successCallback(parsed);
          }
          else{
            addNotifications(NotificationType.success,msg: errorMsg);
            //CustomAlertUtil().successAlert(errorMsg, "");
          }
        }
        else{
          CustomAlertUtil().cupertinoAlert(value[1]);
        }
      });
    }
    else if(developmentMode==DevelopmentMode.traditional){
      if(traditionalParam != null && traditionalParam.executableSp!=null){
        List<ParamModel> finalParams=traditionalParam.paramList.isNotEmpty?traditionalParam.paramList:[];
        finalParams.add(ParamModel(Key: "SpName", Type: "String", Value: traditionalParam.executableSp));
        finalParams.addAll(await getParamEssential(extraParam: extraParam));
        if(dataJson.isNotEmpty){
          var parsedDataJson=jsonDecode(dataJson);
          if(HE_IsMap(parsedDataJson)){
            parsedDataJson.forEach((key, value) {
              finalParams.add(ParamModel(Key: key, Type: "String", Value: value));
            });
          }
        }

        await FlutterUtilsPlatform.apiInstance.getInvoke(finalParams,loader: loader).then((value){
          if(value[0]){

            var parsed=jsonDecode(value[1]);
            String errorMsg=parsed["TblOutPut"][0]["@Message"]??"";
            if(successCallback!=null){
              successCallback(parsed);
            }
            else{
              addNotifications(NotificationType.success,msg: errorMsg);
              //CustomAlertUtil().successAlert(errorMsg, "");
            }
          }
          else{
            CustomAlertUtil().cupertinoAlert(value[1]);
          }
        });
      }
      else{
        assignWidgetErrorToast("Params Not Found...", "");
      }
    }
  }

  void sysSubmit(dynamic widgets,{
    Function? successCallback,
    String action="",
    bool isEdit=false,
    bool needCustomValidation=false,
    Function? onCustomValidation,
    bool clearFrm=true,
    bool closeFrmOnSubmit=true,
    DevelopmentMode developmentMode= DevelopmentMode.traditional,
    TraditionalParam? traditionalParam,
    bool needSuccessCb=false,required RxBool? loader
    ,String extraParam=""
  }) async{

    void successCbHandler(e){
      String errorMsg=e["TblOutPut"][0]["@Message"]??"";
      if(closeFrmOnSubmit){
        Get.back();
      }
      addNotifications(NotificationType.success,msg: errorMsg);
      //CustomAlertUtil().successAlert(errorMsg, "");
      if(clearFrm){
        clearAll(widgets);
      }
      if(successCallback!=null && e['Table']!=null && e['Table'].length>0){
        successCallback(e);
      }
      else if(needSuccessCb){
        successCallback!(e);
      }
    }

    bool isValid=true;
    if(needCustomValidation){
      isValid=onCustomValidation!();
    }
    List<ParamModel> params= await getFrmCollection(widgets);
    if(params.isNotEmpty && isValid){
      if(isValid){
        try{
          params.sort((a,b)=>a.orderBy.compareTo(b.orderBy));
        }catch(e){
          CustomAlertUtil().cupertinoAlert("Error HE002 $e");
        }

        if(developmentMode==DevelopmentMode.json){
          postUIJson(getPageIdentifier(),
              jsonEncode(params.map((e) => e.toJsonHE()).toList()),
              action.isNotEmpty?action: isEdit?"Update":"Insert",
              successCallback: successCbHandler,
              developmentMode: developmentMode
          );
        }
        else if(developmentMode==DevelopmentMode.traditional){
          if(traditionalParam==null){
            assignWidgetErrorToast("Traditional Params not found...", "");
            return;
          }
          traditionalParam.executableSp=isEdit?traditionalParam.updateSp:traditionalParam.insertSp;
          traditionalParam.paramList=params;
          postUIJson(getPageIdentifier(), "", "", successCallback: successCbHandler,
              developmentMode: developmentMode, traditionalParam: traditionalParam,loader: loader,
            extraParam: extraParam
          );
        }
      }
    }

  }

  void sysDelete(arr,primaryKey,primaryArr,{Function? successCallback,String dataJson="",String content="Are you sure want to delete ?",
    bool isCustomDialog=false}){
    if(isCustomDialog){
      postUIJson(getPageIdentifier(),
          dataJson,
          "Delete",
          successCallback: (e){
            if(successCallback!=null){
              successCallback(e);
            }
          }
      );
    }
    else{
      CustomAlertUtil(
          callback: (){
            postUIJson(getPageIdentifier(),
                dataJson,
                "Delete",
                successCallback: (e){
                  String errorMsg=e["TblOutPut"][0]["@Message"];
                  addNotifications(NotificationType.success,msg: errorMsg);
                  //CustomAlertUtil().successAlert(errorMsg, "");
                  if(successCallback!=null){
                    successCallback(e);
                  }
                  //updateArrById(primaryKey, e["Table"][0], arr,action: ActionType.deleteById,primaryArr:primaryArr );
                }
            );
          },
          cancelCallback: (){

          }
      ).yesOrNoDialog2('assets/Slice/like.png', content, false);
    }
  }

  void sysDeleteHE_ListView(dynamic he_listViewBody,String primaryKey,{Function? successCallback,String dataJson="",
    String content="Are you sure want to delete ?",DevelopmentMode developmentMode=DevelopmentMode.traditional,
    TraditionalParam? traditionalParam,RxBool? loader,bool isCustomDialog=false}){
    if(isCustomDialog){
      postUIJson(getPageIdentifier(),
          dataJson,
          "Delete",
          successCallback: (e){
            if(successCallback!=null){
              successCallback(e);
            }
            if(he_listViewBody!=null && e["Table"]!=null && e["Table"].length>0){
              he_listViewBody.updateArrById(primaryKey, e["Table"][0],action: ActionType.deleteById);
            }
          },
          developmentMode: developmentMode,
          traditionalParam:  traditionalParam,
          loader: loader
      );
    }
    else{
      CustomAlertUtil(
          callback: (){
            postUIJson(getPageIdentifier(),
                dataJson,
                "Delete",
                successCallback: (e){
                  String errorMsg=e["TblOutPut"][0]["@Message"];
                  addNotifications(NotificationType.success,msg: errorMsg);
                  //CustomAlertUtil().successAlert(errorMsg, "");
                  if(successCallback!=null){
                    successCallback(e);
                  }
                  if(he_listViewBody!=null && e["Table"]!=null && e["Table"].length>0){
                    he_listViewBody.updateArrById(primaryKey, e["Table"][0],action: ActionType.deleteById);
                  }

                  //updateArrById(primaryKey, e["Table"][0], arr,action: ActionType.deleteById,primaryArr:primaryArr );
                },
                developmentMode: developmentMode,
                traditionalParam:  traditionalParam,
                loader: loader
            );
          },
          cancelCallback: (){

          }
      ).yesOrNoDialog2('assets/Slice/like.png', content, false);
    }
  }

  fillTreeDrp(var widgets,String key,{var refId,var page,bool clearValues=true,var refType,bool toggleRequired=false,var hierarchicalId,
    String spName="USP_GetMasterDetail",String extraParam="",bool needToDisable=false,Function(dynamic)? resCb}) async{
    var fWid=foundWidgetByKey(widgets, key);
    if(fWid!=null){
      if(clearValues){
        fWid.clearValues();
      }
      getMasterDrp(page, key, refId, refType,hierarchicalId,spName,extraParam: extraParam).then((value){
        //console("$key    ${value.runtimeType}");
        fWid.setValue(value);
        if(toggleRequired){
          fWid.required=value.isNotEmpty;
          try{
            fWid.isValid.value=true;
          }catch(e){assignWidgetErrorToast("IsValid",e);}
        }
        if(needToDisable){
          try{
            fWid.isEnabled.value=value.isNotEmpty;
          }catch(e){}
        }
        if(resCb!=null){
          resCb(value);
        }
      });
    }
  }

  foundWidgetByKey(var widgets,String key,{bool needSetValue=false,dynamic value}){
    WidgetType widgetType=getWidgetType(widgets);
    if(widgetType==WidgetType.list){
      for (var widget in widgets) {
        if(widget.getDataName()==key){
          if(needSetValue){
            widget.setValue(value);
          }
          return widget;
        }
      }
    }
    else if(widgetType==WidgetType.map){
      var foundWidg=widgets[key];
      if(needSetValue && foundWidg!=null){
        foundWidg.setValue(value);
      }
      return foundWidg;
    }
    return null;
  }

  void clearAll(var widgets){
    setFrmValues(widgets, valueArray,fromClearAll: true);
  }
  void clearAllV2(var widgets){
    WidgetType widgetType=getWidgetType(widgets);
    if(widgetType==WidgetType.list){
      for (var widget in widgets){
        widget.clearValues();
      }
    }
    else if(widgetType==WidgetType.map){
      for (var widget in widgets.entries){
        widget.value.clearValues();
      }
    }
  }

  void updateEnable(var widgets,key,{bool isEnabled=false}){
    var fWid=foundWidgetByKey(widgets, key);
    if(fWid!=null){
      fWid.isEnabled=isEnabled;
      fWid.reload.value=!fWid.reload.value;
      if(!isEnabled){
        fWid.clearValues();
      }
    }
  }

  @override
  String getPageIdentifier(){
    return "";
  }

  void clearOnDispose(){
    parsedJson=null;
    valueArray.clear();
  }
}