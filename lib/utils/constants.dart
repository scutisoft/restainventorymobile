import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../utils/utils.dart';
import '../helper/language.dart';

class MyConstants{
  MyConstants._();
  static String appName="TreeDonate";
  //static String appName="RadiantECS_Dev";
  static String appVersion="1.0.6";
  static String appId="com.bridget.restainventory";
  static bool isLive=false;
  static bool fromUrl=true;
  static bool hasAppVersionController=true;
  static bool bottomSafeArea=true;
  static bool defaultActionEnable=true;
  static const PaymentGateway paymentGateway=PaymentGateway.razorpay;

  static Duration animeDuration = const Duration(milliseconds: 300);
  static Cubic animeCurve=Curves.easeIn;

  static String mapApiKey="AIzaSyB9wKg5QXWHAoOd1i-mUKYhhaq6bBQuHeg";
  static String extraParam="StoreId";

  static int minimumDonationAmount=1;
  static int maximumQty=9;

  static String dbDateFormat="yyyy-MM-dd";
  static String decimalReg=r'^\d+\.?\d{0,3}';
  static String timeReg=r'^\d{0,2}\:?\d{0,2}';
  static int phoneNoLength=10;
  static int zipcodeLength=6;
  static String digitRegEx='[0-9]';
  static String digitDecimalRegEx=r'^\d+\.?\d{0,30}';
  static String alphaSpaceRegEx='[A-Za-z ]';
  static String alphaSpaceRegEx2="/[அ-ஔ]+|[க-னௌ]+|[ァ-ヴー]+|[a-zA-Z ]+|[々〆〤ヶ]+/u";
  static String addressRegEx='[A-Za-z0-9-,_/*+()@. ]';
  static String dbDateTimeFormat='yyyy-MM-dd HH:mm:ss';
  static String rupeeString='₹';

  static EdgeInsets LRPadding=const EdgeInsets.only(left: 20,right: 20);

}

var formatCurrency = NumberFormat.currency(locale: 'HI',name: "");
double textFormWidth=400;

glowFunTransparent(BuildContext context){
  return Theme.of(context).copyWith(
      colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.white10
      )
  );
}

ts12(Color color,{String fontfamily='RR'}){
  return TextStyle(fontSize: 12,fontFamily: getLangFontFamily(fontfamily),color: color,letterSpacing: 0.1);
}
ts14(Color color,{String fontfamily='RR',TextOverflow? textOverflow}){
  return TextStyle(fontSize: 14,fontFamily: getLangFontFamily(fontfamily),color: color,letterSpacing: 0.1,overflow: textOverflow,);
}
ts15(Color color,{String fontfamily='RR'}){
  return TextStyle(fontSize: 15,fontFamily: getLangFontFamily(fontfamily),color: color,letterSpacing: 0.1);
}
ts16(Color color,{String fontfamily='RR'}){
  return TextStyle(fontSize: 16,fontFamily: getLangFontFamily(fontfamily),color: color,letterSpacing: 0.1);
}
ts18(Color color,{String fontfamily='RR',double fontsize=18,double ls=0.1}){
  return TextStyle(fontSize: fontsize,fontFamily: getLangFontFamily(fontfamily),color: color,letterSpacing: ls,height: Language.height);
}
ts20(Color color,{String fontfamily='AR',double fontsize=18,double ls=0.1,FontWeight? fontWeight}){
  return TextStyle(fontSize: fontsize,fontFamily: fontfamily,color: color,letterSpacing: ls,fontWeight: fontWeight);
}
ts20M(Color color,{String fontfamily='AM',double fontsize=18,double ls=0.1,FontWeight? fontWeight}){
  return TextStyle(fontSize: fontsize,fontFamily: fontfamily,color: color,letterSpacing: ls,fontWeight: fontWeight);
}

String getLangFontFamily(String ff){

  if(ff=='RR'){
    return Language.regularFF;
  }
  else if(ff=='Reg'){
    return Language.regularFF;
  }
  else if(ff=='Bold'){
    return Language.boldFF;
  }
  else if(ff=='Med'){
    return Language.mediumFF;
  }
  else if(ff=='Lit'){
    return Language.lightFF;
  }
  else{
    return Language.regularFF;
  }
}

// double topPad=24.0;



clearCache() async{
  //print("clearCache");
//  SharedPreferences sp=await SharedPreferences.getInstance();


}

void  fadeRoute(Widget widget) {
  Get.to(widget,transition: Transition.fadeIn,duration: const Duration(milliseconds: 400));
}
void fadeRouteOff(Widget widget) {
  Get.off(widget,transition: Transition.fadeIn,duration: const Duration(milliseconds: 400));
}