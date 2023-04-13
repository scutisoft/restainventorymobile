
import 'package:get/get.dart';
import 'flutter_utils_platform_interface.dart';
import 'model/parameterModel.dart';
import 'utils/extensionHelper.dart';

class FlutterUtils {
  Future<String?> getPlatformVersion() {
    return FlutterUtilsPlatform.instance.getPlatformVersion();
  }

  Future<List> getInvoke(List<ParamModel> parameterList,{String url="/api/Mobile/GetInvoke", RxBool? loader}){
    return  FlutterUtilsPlatform.apiInstance.getInvoke(parameterList,url: url,loader: loader);
  }


}


mixin HappyExtension{
  Future<List<ParamModel>> getFrmCollection(var widgets) async{
    return  FlutterUtilsPlatform.instance.getFrmCol(widgets);
  }

  void setFrmValues(var widgets,List valueArray,{bool fromClearAll=false}){
    FlutterUtilsPlatform.instance.setFrmValuesV1(widgets, valueArray,fromClearAll: fromClearAll);
  }

  void parseJson(var widgets,String pageIdentifier,{String? dataJson,bool needToSetValue=true,
    DevelopmentMode developmentMode= DevelopmentMode.traditional,TraditionalParam? traditionalParam,Function(dynamic)? resCb,
    RxBool? loader,bool fromUrl=true, String extraParam=""})async{
    FlutterUtilsPlatform.instance.parseJsonV1(widgets, pageIdentifier,dataJson: dataJson,needToSetValue: needToSetValue,developmentMode: developmentMode,traditionalParam: traditionalParam,
    resCb: resCb,loader: loader,fromUrl: fromUrl,extraParam:extraParam);
  }

  void fillTreeDrp(var widgets,String key,{var refId,var page,bool clearValues=true,var refType,bool toggleRequired=false,var hierarchicalId,
    String spName="USP_GetMasterDetail",String extraParam=""})async{
    FlutterUtilsPlatform.instance.fillTreeDrpV1(widgets, key,refId: refId,page: page,clearValues: clearValues,refType: refType,toggleRequired: toggleRequired,
        hierarchicalId: hierarchicalId,spName: spName,extraParam: extraParam);
  }

  void clearAllV2(var widgets){
    FlutterUtilsPlatform.instance.clearAllV4(widgets);
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
    bool needSuccessCb=false,RxBool? loader
  })async{
    FlutterUtilsPlatform.instance.sysSubmitV1(widgets,successCallback: successCallback,action: action,isEdit: isEdit,needCustomValidation: needCustomValidation,
    onCustomValidation: onCustomValidation,clearFrm: clearFrm,closeFrmOnSubmit: closeFrmOnSubmit,developmentMode: developmentMode,traditionalParam: traditionalParam,
    needSuccessCb: needSuccessCb,loader: loader);
  }

  void foundWidgetByKey(var widgets,String key,{bool needSetValue=false,dynamic value}){
    FlutterUtilsPlatform.instance.foundWidgetByKeyV1(widgets, key,needSetValue: needSetValue,value: value);
  }
}