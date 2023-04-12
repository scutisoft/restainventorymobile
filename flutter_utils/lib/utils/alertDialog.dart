import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAlertUtil{

  RoundedRectangleBorder alertRadius=RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0),);


  VoidCallback? callback;
  VoidCallback? cancelCallback;
  CustomAlertUtil({this.callback,this.cancelCallback});




  void yesOrNoDialog2(String img,String title,bool isSvg,
      {double imgHeight=50.0,EdgeInsets pad=const EdgeInsets.all(20),double hei=360,double textWidth=200}){
    double wid=MediaQuery.of(Get.context!).size.width;
    showDialog(
      barrierDismissible: false,
        context: Get.context!,
        builder: (ctx) => Dialog(
          shape: alertRadius,
          clipBehavior: Clip.antiAlias,
          child: Container(
             height:hei,
              width:wid-40,
              decoration:BoxDecoration(
                color:Colors.white,
              ),
              padding: pad,
              child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                  children:[

                  //  isSvg?SvgPicture.asset(img,height: imgHeight,):Image.asset(img,height: imgHeight,),
                    SizedBox(height:30),
                    Container(
                      width: textWidth,
                      child: Text("Are you sure want to delete ?",
                        style:TextStyle(fontFamily:'RR',fontSize:23,color:Color(0xFF787878),letterSpacing: 0.5,
                        height: 1.5),textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height:30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [

                        GestureDetector(
                          onTap:(){
                            Get.back(closeOverlays: true);
                            cancelCallback!();
                          },
                          child: Container(
                            height: 50.0,
                            width: (wid-80)*0.4,
                            //margin: EdgeInsets.only(bottom: 0,top:20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xFFE4E4E4),
                                // boxShadow: [
                                //   BoxShadow(
                                //     color:Color(0xFF808080).withOpacity(0.6),
                                //     offset: const Offset(0, 8.0),
                                //     blurRadius: 15.0,
                                //     // spreadRadius: 2.0,
                                //   ),
                                // ]
                            ),
                            child: Center(
                              child: Text('No',
                                style: TextStyle(fontFamily:'RR',color: Color(0xFF808080),fontSize: 16),
                              ),
                            ),
                          ),
                        ),



                        GestureDetector(
                          onTap:(){
                            Get.back(closeOverlays: true);
                            callback!();
                          },
                          child: Container(
                            height: 50.0,
                            width: (wid-80)*0.4,
                           // margin: EdgeInsets.only(bottom: 0,top:20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.red,
                                // boxShadow: [
                                //   BoxShadow(
                                //     color:ColorUtil.red.withOpacity(0.6),
                                //     offset: const Offset(0, 8.0),
                                //     blurRadius: 15.0,
                                //     // spreadRadius: 2.0,
                                //   ),
                                // ]
                            ),
                            child: Center(
                              child: Text('Yes',
                                style: TextStyle(fontFamily:'Avenir Next',color: Colors.white,fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),



                  ]
              )
          ),
        )
    );
  }







  void cupertinoAlert(String title){
    Get.dialog(  CupertinoAlertDialog(
      title: Icon(Icons.error_outline,color: Colors.red,size: 50,),
      content: Text(title,
        style: TextStyle(fontSize: 18,fontFamily: 'RR'),),
    ));
  }
}

enum NotificationType {
  success,
  error,
  info
}

void addNotifications(NotificationType notificationType,{String msg=""}){
  Color themeBlack=const Color(0xff2C2C2D);
  Color text3=const Color(0xff828282);
  if(notificationType==NotificationType.success){
    Get.snackbar(
      "",
      "",
      titleText:Text("Success",style: TextStyle(color: themeBlack,fontFamily: 'RM',fontSize: 18)),
      messageText: Text(msg,style: TextStyle(color: text3,fontSize: 15),),
      icon: Container(
          height: 20,
          width: 20,
          child: Image(image: AssetImage("assets/icons/success.png",), width: 20,)),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      borderRadius: 20,
      margin: EdgeInsets.all(15),
      padding: EdgeInsets.all(15),
      colorText: themeBlack,
      duration: Duration(milliseconds: 1000),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
    /* ElegantNotification.success(
            title:  Text("Success",style: ts18(AppTheme.bgColor),),
            description:  Text(msg,style: ts15(AppTheme.darkGrey1),),
        ).show(Get.context!);*/
  }
  else if(notificationType==NotificationType.error){
    Get.snackbar(
        "",
        "",
        titleText:Text("Error",style:  TextStyle(color: themeBlack,fontFamily: 'RM',fontSize: 18),),
        messageText: Text(msg,style:  TextStyle(color: text3,fontSize: 15),),
        icon: Container(
            height: 20,
            width: 20,
            child: Image(image: AssetImage("assets/icons/error.png",), width: 20,)),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        borderRadius: 20,
        margin: EdgeInsets.all(15),
        padding: EdgeInsets.all(15),
        colorText: themeBlack,
        duration: Duration(milliseconds: 1500),
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        forwardAnimationCurve: Curves.easeOutBack
    );
  }
  else if(notificationType==NotificationType.info){
    Get.snackbar(
      "Info",
      "",
      titleText:Text("Info",style:  TextStyle(color: themeBlack,fontFamily: 'RM',fontSize: 18),),
      messageText: Text(msg,style:  TextStyle(color: text3,fontSize: 15),),
      icon: Container(
          height: 20,
          width: 20,
          child: Image(image: AssetImage("assets/icons/info.png",), width: 20,)),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      borderRadius: 20,
      margin: EdgeInsets.all(15),
      padding: EdgeInsets.all(15),
      colorText: themeBlack,
      duration: Duration(milliseconds: 1000),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }
}


