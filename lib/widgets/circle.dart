import 'package:flutter/material.dart';
class CustomCircle extends StatelessWidget {
  double hei;
  Color color;
  Widget? widget;
  EdgeInsets margin;
  List<BoxShadow> bs;
  CustomCircle({required this.hei,required this.color,this.widget=null,this.margin=const EdgeInsets.only(left: 0),
  this.bs=const []});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: hei,
      width: hei,
      margin: margin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: bs
      ),
      child: widget==null?Container():widget,
    );
  }
}
