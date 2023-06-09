import 'package:flutter/material.dart';
import 'package:restainventorymobile/utils/constants.dart';
import '../helper/language.dart';
import '../utils/colorUtil.dart';






class ValidationErrorText extends StatelessWidget {
 final String title;
 double leftPadding;
 double rightPadding;
 Alignment alignment;
 ValidationErrorText({this.title="",this.leftPadding=15.0,this.rightPadding=0.0,this.alignment=Alignment.centerLeft});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(left: leftPadding,right: rightPadding,top:1,bottom: 0),
      child: Align(
        alignment: alignment,
          child: Text(title.isEmpty?"* ${Language.required}":title,style: ts20M(ColorUtil.red,fontsize: 15),textAlign: TextAlign.left,)),
    );
  }
}

class EmailValidation{
  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern as String);
    return (!regex.hasMatch(value)) ? false : true;
  }
}