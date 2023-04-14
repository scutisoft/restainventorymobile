
import 'package:get/get.dart';

import '../utils/constants.dart';

import '../notifier/configuration.dart';

var showLoader=false.obs;

String GetBaseUrl(){
  return MyConstants.isLive?"http://45.126.252.78/Restainventory": "http://45.126.252.78/Restainventory";
}
String GetImageBaseUrl(){
  return MyConstants.isLive?"http://45.126.252.78/Restainventory/AppAttachments/": "http://45.126.252.78/Restainventory/AppAttachments/";
}

String getInvokeUrl(){
  return '${GetBaseUrl()}/api/Mobile/GetInvoke';
}

String getDataBase(){
  return "RestaPos_UAT";
}

