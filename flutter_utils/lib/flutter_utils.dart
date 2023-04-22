
import 'package:get/get.dart';
import 'flutter_utils_platform_interface.dart';
import 'model/parameterModel.dart';

class FlutterUtils {
  Future<String?> getPlatformVersion() {
    return FlutterUtilsPlatform.instance.getPlatformVersion();
  }

  Future<List> getInvoke(List<ParamModel> parameterList,{String url="/api/Mobile/GetInvoke", RxBool? loader}){
    return  FlutterUtilsPlatform.apiInstance.getInvoke(parameterList,url: url,loader: loader);
  }
}


