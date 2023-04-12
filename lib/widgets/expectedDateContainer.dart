import 'package:flutter/material.dart';

import '../utils/colorUtil.dart';


class ExpectedDateContainer extends StatelessWidget {
  String? text;
  Color? textColor;
  Color? iconColor;
  ExpectedDateContainer({this.text,this.textColor,this.iconColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: ColorUtil.formMargin,
      padding: EdgeInsets.only(left:15,right:15),
      height: ColorUtil.formContainerHeight,
      width: double.maxFinite,
      alignment: Alignment.centerLeft,
      decoration: ColorUtil.formContBoxDec,
      child: Row(
        children: [
          Text(text!,style: TextStyle(fontFamily: 'RR',fontSize: 16,color: textColor),),
          Spacer(),
          Container(
              height: 25,
              width: 25,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor
              ),

              child: Center(child: Icon(Icons.calendar_today,color:Colors.grey ,size: 20,)))
        ],
      ),
    );
  }
}

class EmptyContainer extends StatelessWidget {
  const EmptyContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0,
      height: 0,
    );
  }
}
