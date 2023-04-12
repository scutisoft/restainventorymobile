import 'dart:convert';
import 'dart:io';

import 'package:flutter_utils/flutter_utils_platform_interface.dart';
import 'package:flutter_utils/model/parameterModel.dart';
import 'package:flutter_utils/utils/apiUtils.dart';

import '../utils/utils.dart';

import '../utils/colorUtil.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/constants.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;

import 'versionChecker.dart';

class AppVersionController{
  void getAppVersionDetail() async{
    if(!MyConstants.hasAppVersionController){
      return;
    }
    List<ParamModel> params= await getParamEssential();
    params.add(ParamModel(Key: "SpName", Type: "String", Value: "USP_GetAppVersionDetail"));
    params.add(ParamModel(Key: "AppName", Type: "String", Value: MyConstants.appName));
    FlutterUtilsPlatform.apiInstance.getInvoke(params,/*hideLoaders: true*/).then((value){
      if(value[0]){
        var response=json.decode(value[1]);
        if(response['Table']!=null){
          if(response['Table'].length>0){
            if(response['Table'][0]['AppVersionNumber']!=MyConstants.appVersion){
              Get.defaultDialog(
                  title: "",
                  titleStyle: TextStyle(height: 0),radius: 10,middleText: "New Update Available",middleTextStyle: TextStyle(fontFamily: "RR",fontSize: 20,),
                  barrierDismissible: false,
                  contentPadding: EdgeInsets.all(20),
                  confirm: GestureDetector(
                    onTap: (){
                      launchUrl(Uri.parse(response['Table'][0]['AppVersionURL']),mode: LaunchMode.externalApplication);
                    },
                    child: Container(
                      height: 50,
                      width: 150,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ColorUtil.red,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text("Update",style: ts18(Colors.white),),
                    ),
                  )
              );
            }
          }
        }
      }
    });
  }

  void checkVersion() async {
    if(!MyConstants.hasAppVersionController){
      return;
    }
    final _checker = AppVersionChecker(
      appId: MyConstants.appId,
    );
    _checker.checkUpdate().then((value) {
      if(value.currentVersion != value.newVersion){
        Get.defaultDialog(
            title: "",
            titleStyle: TextStyle(height: 0),radius: 10,middleText: "New Update Available",middleTextStyle: TextStyle(fontFamily: "RR",fontSize: 20,),
            barrierDismissible: false,
            contentPadding: EdgeInsets.all(20),
            confirm: GestureDetector(
              onTap: (){
                launchUrl(Uri.parse(value.appURL!),mode: LaunchMode.externalApplication);
              },
              child: Container(
                height: 50,
                width: 150,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ColorUtil.red,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text("Update",style: ts18(Colors.white),),
              ),
            )
        );
      }
    });
  }
}
Future<void> download(String url,String imgPath,String imgFolder,String imgName) async {
  try{
    final localPath = '$imgPath/$imgFolder/$imgName';
    // console(localPath);
    if(!File(localPath).existsSync()){
      final response = await http.get(Uri.parse(url));
      final imageFile = await File(localPath).create(recursive: true);
      await imageFile.writeAsBytes(response.bodyBytes);
    }
    //console("downloaded");
  }catch(e){
    console("_download catch $e");
  }
}

