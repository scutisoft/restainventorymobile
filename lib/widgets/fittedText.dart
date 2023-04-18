import 'package:flutter/material.dart';

class FittedText extends StatelessWidget {
  double? height;
  double? width;
  String? text;
  TextStyle? textStyle;
  Alignment alignment;

  FittedText({this.textStyle,this.width,this.height,this.text,this.alignment=Alignment.centerLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        width: width,
        alignment:alignment,
        color: Colors.transparent,
        child: FittedBox(child: Text("$text",style: textStyle,))
    );
  }
}

class FlexFittedText extends StatelessWidget {
  String? text;
  TextStyle? textStyle;
  int flex;
  FlexFittedText({Key? key,this.text,this.textStyle,this.flex=1}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: flex,
        child: FittedBox(alignment: Alignment.centerRight,child: Text("$text",style: textStyle,textAlign: TextAlign.end,))
    );
  }
}
