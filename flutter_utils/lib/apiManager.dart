import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as g;
import 'flutter_utils_platform_interface.dart';
import 'model/parameterModel.dart';
import 'utils/apiUtils.dart';

class ApiManger extends FlutterUtilsPlatform{
  int t=30; a(RxBool loader){ loader.value=false; return [false,"Connection TimeOut"]; } b(){ return [false,"Connection TimeOut"]; } @override Future<List> getInvoke(List<ParamModel> c,{ String url="",RxBool? loader}) async { loader!.value=true; try{ if(url.isEmpty){ url=await gBU(); url="$url/api/Mobile/GetInvoke"; } var d={ "Fields": c.map((e) => e.toJson()).toList() }; final f = await g.post(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: json.encode(d) ).timeout(Duration(seconds: t),onTimeout: ()=>a(loader)); loader.value=false; if(f.statusCode==200){ return [true,f.body]; } else{ var g; g=json.decode(f.body); return [false,g['Message']]; } } catch(e){ loader.value=false; return [false,"Server Disconnected..."]; } } @override Future<List> getInvokeLazy(List<ParamModel> z,{ String url="/api/Mobile/GetInvoke"}) async { try{ url=await gBU(); url="$url/api/Mobile/GetInvoke"; var y={ "Fields": z.map((e) => e.toJson()).toList() }; final x = await g.post(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: json.encode(y) ).timeout(Duration(seconds: t),onTimeout: ()=>b()); if(x.statusCode==200){ return [true,x.body]; } else{ var w; w=json.decode(x.body); return [false,w['Message']]; } } catch(e){ return [false,"Server Disconnected..."]; } }
}