import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'flutter_utils_platform_interface.dart';
import 'model/parameterModel.dart';
import 'utils/apiUtils.dart';

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