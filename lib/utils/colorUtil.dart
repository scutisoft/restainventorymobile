
import 'package:flutter/material.dart';

import '../helper/language.dart';

class ColorUtil{
  static Color  theme=const Color(0xffF8F8F8);
  static Color themeWhite=const Color(0xffffffff);
  static Color themeBlack=const Color(0xff030303);
  static Color secondary=const Color(0xff476039);
  static Color primary=const Color(0xffDC0022);
  static Color greyBorder=const Color(0xffE4E5E9);
  static Color greyFill=const Color(0xff656565);
  static Color greyLite=const Color(0xffF5F6FA);
  static Color text1=const Color(0xff515151);
  static Color text2=const Color(0xff9E9E9E);
  static Color text3=const Color(0xff828282);
  static Color text4=const Color(0xffA6A6A6);
  static Color lightgrey=const Color(0xffF2F2F2);
  static Color text5=const Color(0xff6E6E6E);
  static Color lightBlue=const Color(0xffF4F7FC);
  static Color red=const Color(0xffDC0022);
  static Color grey1=const Color(0xffF7F7F9);
  static TextStyle textStyle18=TextStyle(fontFamily: 'RR',fontSize: 18,color: Color(0xff2C2C2D));
  static TextStyle notiText=TextStyle(fontFamily: 'RR',color: Color(0xFFffffff),fontSize: 10);

  static const Color menu=Color(0xFF858585);
  static const Color bgColor=Color(0xffF5F5F5);
  static const Color primaryTextColor2=Color(0xFF383838);
  static const Color formGridBg=Color(0xFFf2f6f0);

  static Color rejectClr=const Color(0xffE1433A);
  static Color paidClr=const Color(0xff019342);
  static Color partiallyPaidClr=const Color(0xffE4BE49);
  static Color payClr=const Color(0xff062778);
  static Color approvedClr=const Color(0xff019342);


  static TextStyle paidTS=TextStyle(fontFamily: 'RR',fontSize: 15,color: ColorUtil.secondary);
  static TextStyle pendingTS=TextStyle(fontFamily: 'RR',fontSize: 15,color: Color(0xffE4BE49));

  static const TextStyle fseAccRejGridTS=TextStyle(fontFamily: 'USB',fontSize: 18,color:ColorUtil.primaryTextColor2);
  static const TextStyle fseAccRejGridBosyTS=TextStyle(fontFamily: 'RR',fontSize: 15,color:Color(0xff6E6E6E));

  static  TextStyle search2ActiveTS=TextStyle(fontFamily: Language.regularFF,fontSize: 15,color: Color(0xffffffff));
  static  TextStyle search2InActiveTS=TextStyle(fontFamily: Language.regularFF,fontSize: 15,color: Color(0xff979797));

  static Color search2ActBg= primary;
  static Color search2InActBg= Color(0xffffffff);
  static double formContainerHeight=60;
  static BoxDecoration formContBoxDec=BoxDecoration(
      color: themeWhite,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: greyBorder)
  );

  static Color chkBoxText=const Color(0xff452800);
  static Color disableColor=Color(0xFFe8e8e8);
  static Color avatarBorderColor=Color(0xFFC7D0D8);


  //Animated Search Bar
  static Color asbColor=primary;
  static bool asbBoxShadow=false;
  static bool asbCloseSearchOnSuffixTap=true;
  static Color asbSearchIconColor=themeWhite;
  static Icon getASBSuffix(){
    return const Icon(Icons.clear,color: Colors.white,);
  }

  //rawScrollBar Properties
  static const Color scrollBarColor=Colors.grey;
  static const double scrollBarRadius=5.0;
  static const double scrollBarThickness=4.0;

  static EdgeInsets formMargin=const EdgeInsets.only(left:15,right:15,top:0,);
  static Color formTableBorder=primary.withOpacity(0.15);
  static TextStyle formTableBodyTS=TextStyle(fontSize: 13,fontFamily: 'RR',color: themeBlack );
  static TextStyle formTableBodyTSB=TextStyle(fontSize: 13,fontFamily: 'Bold',color: themeBlack );
  static TextStyle formTableHeaderTS=TextStyle(fontSize: 12,fontFamily: 'Med',color:ColorUtil.themeBlack );

}