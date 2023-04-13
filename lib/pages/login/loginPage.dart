import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/flutter_utils_platform_interface.dart';
import 'package:flutter_utils/model/parameterModel.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restainventorymobile/api/apiUtils.dart';
import 'package:restainventorymobile/pages/storeSelection/storeSelection.dart';
import 'package:restainventorymobile/widgets/customCheckBox.dart';
import 'package:restainventorymobile/widgets/fittedText.dart';
import 'package:restainventorymobile/widgets/pinWidget.dart';
import '../../api/sp.dart';
import '../../helper/language.dart';
import '../../notifier/configuration.dart';
import '../../utils/utils.dart';
import '../../widgets/alertDialog.dart';
import '../../widgets/loader.dart';
import '/utils/sizeLocal.dart';
import '/utils/constants.dart';

import '/utils/colorUtil.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController email=TextEditingController();
  TextEditingController password=TextEditingController();

  @override
  void initState(){
    allowAccess();
    super.initState();
  }


  allowAccess() async{
    //  final PermissionHandler _permissionHandler = PermissionHandler();
    var result = await Permission.storage.request();
    console("result ${result.isGranted}");
    if(result == PermissionStatus.granted) {

    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: MyConstants.bottomSafeArea,
      child: Scaffold(
        backgroundColor: ColorUtil.bgColor,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                height: SizeConfig.screenHeight,
                width: SizeConfig.screenWidth,
                padding: const EdgeInsets.only(left: 20,right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/logo.png"),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FittedText(
                        text: "Login into your",
                        textStyle: ts20(ColorUtil.themeBlack,fontfamily: 'AR',fontsize: 56),
                        width: SizeConfig.screenWidth!*0.7,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FittedText(
                        text: "Account",
                        textStyle: ts20(ColorUtil.red,fontfamily: 'AR',fontsize: 46,fontWeight: FontWeight.bold),
                        width: SizeConfig.screenWidth!*0.7,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    const SizedBox(height: 20,),

                    LoginTextField(
                      hintText: "Email",
                      textEditingController: email,
                      onEditCom: (){},
                    ),
                    const SizedBox(height: 10,),
                    LoginTextField(
                      hintText: "Password",
                      obscure: true,
                      textEditingController: password,
                      onEditCom: (){
                        FocusScope.of(context).unfocus();
                        login();
                      },
                    ),
                    const SizedBox(height: 30,),
                    GestureDetector(
                      onTap: (){
                        login();
                      },
                      child: Container(
                        height: 65,
                        width: SizeConfig.screenWidth!*0.6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: ColorUtil.red,
                        ),
                        alignment: Alignment.center,
                        child: Text("Login",style: ts20(Color(0xffFAFAFA),fontsize: 20,fontfamily: 'AR',fontWeight: FontWeight.w700,ls: 0.5),textAlign: TextAlign.center,),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Obx(() => Loader(value: showLoader.value,))
          ],
        ),
      ),
    );
  }

  login() async{
    if(email.text.isEmpty){
      CustomAlert().cupertinoAlert("${Language.enterEmail}....");
      return;
    }
    if(password.text.isEmpty){
      CustomAlert().cupertinoAlert("${Language.enterPassword}....");
      return;
    }
    List<ParamModel> params=[];
    params.add(ParamModel(Key: "SpName", Type: "String", Value: Sp.loginSp));
    params.add(ParamModel(Key: "UserName", Type: "String", Value: email.text));
    params.add(ParamModel(Key: "Password", Type: "String", Value: password.text));
    params.add(ParamModel(Key: "DeviceId", Type: "String", Value: getDeviceId()));
    params.add(ParamModel(Key: "database", Type: "String", Value: "RestaPos_UAT"));
    FlutterUtils().getInvoke(params,url:'${GetBaseUrl()}/api/Mobile/GetInvoke',loader: showLoader).then((value){
      console(value);
      if(value[0]){
        console(value);
        var parsed=json.decode(value[1]);
        try{
          setUserSessionDetail(parsed["Table"][0]);
         // accessData=parsed['Table1'];

        }catch(e){}
      }
      else{
        CustomAlert().cupertinoAlert(value[1]);
      }
    });
  }
}

class LoginTextField extends StatelessWidget {
  String hintText;
  bool obscure;
  TextEditingController textEditingController;
  VoidCallback onEditCom;
  LoginTextField({Key? key,required this.hintText,this.obscure=false,required this.textEditingController,required this.onEditCom}) : super(key: key);

  var isFilled=false.obs;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: SizeConfig.screenWidth,
      color: Colors.white,
      child: Row(
        children: [
          Container(
            height: 80,
            width: 5,
            color: ColorUtil.red,
          ),
          Expanded(
            child: TextField(
              controller: textEditingController,
              obscureText: obscure,
              textAlignVertical: TextAlignVertical.center,
              textAlign: TextAlign.left,
              maxLines: 1,
              style: TextStyle(fontSize: 18,fontFamily:'AR',color:ColorUtil.themeBlack,letterSpacing: 1.0,),
              scrollPadding: EdgeInsets.only(bottom: 270),
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                enabledBorder: InputBorder.none,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
               // prefixIcon: Container(width:30,alignment:Alignment.center,child: SvgPicture.asset("assets/login/person.svg",height: 25,)),
                hintText: hintText,
                //errorStyle: TextStyle(fontSize: 14,fontFamily:Language.regularFF,color:Color(0XFFBCBBCD),),
                hintStyle:TextStyle(fontSize: 18,fontFamily:'RL',color:ColorUtil.themeBlack,fontWeight: FontWeight.w100),
              ),
              cursorColor: ColorUtil.cursorColor,
              onChanged: (v){
                isFilled.value=v.isNotEmpty;
              },
              onEditingComplete: onEditCom,
            ),
          ),
          Obx(() => CustomCheckBox(
              isSelect: isFilled.value,
              onlyCheckbox: true,
              height: 25,br: 35,
              selectColor: ColorUtil.red,
              icnSize: 16,
              unSelIcon: const Icon(Icons.done,color:Colors.white,size: 16,),
            )
          ),
          const SizedBox(width: 10,)
        ],
      ),
    );
  }
}
