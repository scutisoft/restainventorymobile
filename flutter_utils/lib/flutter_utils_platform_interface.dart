import 'package:get/get.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_utils_method_channel.dart';
import 'model/parameterModel.dart';
import 'utils/extensionHelper.dart';

abstract class FlutterUtilsPlatform extends PlatformInterface {

  FlutterUtilsPlatform() : super(token: _token){
    print("FlutterUtilsPlatform hiiiiii");
  }

  static final Object _token = Object();

  static FlutterUtilsPlatform _instance = MethodChannelFlutterUtils();
  static FlutterUtilsPlatform _apiInstance = ApiManger();

  static FlutterUtilsPlatform get instance => _instance;

  static FlutterUtilsPlatform get apiInstance => _apiInstance;


  static set instance(FlutterUtilsPlatform instance) {
    print("set instance");
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  static set apiInstance(FlutterUtilsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _apiInstance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<List> getInvoke(List<ParamModel> parameterList,{String url="/api/Mobile/GetInvoke", RxBool? loader}){
    throw UnimplementedError('getInvoke() has not been implemented.');
  }

  Future<List> getInvokeLazy(List<ParamModel> parameterList,{String url="/api/Mobile/GetInvoke"}){
    throw UnimplementedError('getInvoke() has not been implemented.');
  }

  Future<List<ParamModel>> getFrmCol(var widgets){
    throw UnimplementedError('getFrmCollection has not been implemented.');
  }

  void setFrmValuesV1(var widgets,List valueArray,{bool fromClearAll=false}){
    throw UnimplementedError('setFrmValuesV1() has not been implemented.');
  }

  void parseJsonV1(var widgets,String pageIdentifier,{String? dataJson,bool needToSetValue=true,
    DevelopmentMode developmentMode= DevelopmentMode.traditional,TraditionalParam? traditionalParam,Function(dynamic)? resCb,
    RxBool? loader,bool fromUrl=true,String extraParam=""})async{
    throw UnimplementedError('parseJsonV1() has not been implemented.');
  }

  void fillTreeDrpV1(var widgets,String key,{var refId,var page,bool clearValues=true,var refType,bool toggleRequired=false,var hierarchicalId,
    String spName="USP_GetMasterDetail",String extraParam="",bool needToDisable=false,Function(dynamic)? resCb}) async{
    throw UnimplementedError('fillTreeDrpV1() has not been implemented.');
  }


  void clearAllV4(widgets){
    throw UnimplementedError('clearAllV4() has not been implemented.');
  }

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
    bool needSuccessCb=false,RxBool? loader,String extraParam=""
  }) async{
    throw UnimplementedError('sysSubmitV1() has not been implemented.');
  }

  void foundWidgetByKeyV1(var widgets,String key,{bool needSetValue=false,dynamic value}){
    throw UnimplementedError('foundWidgetByKeyV1() has not been implemented.');
  }

  void clearOnDisposeV1(){
    throw UnimplementedError('clearOnDisposeV1() has not been implemented.');
  }

  void sysDeleteHE_ListViewV1(dynamic he_listViewBody,String primaryKey,{Function? successCallback,String dataJson="",
    String content="Are you sure want to delete ?",DevelopmentMode developmentMode=DevelopmentMode.traditional,
    TraditionalParam? traditionalParam,RxBool? loader}){
    throw UnimplementedError('sysDeleteHE_ListViewV1() has not been implemented.');
  }
}
