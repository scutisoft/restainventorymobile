import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:restainventorymobile/utils/colorUtil.dart';
import 'package:restainventorymobile/utils/constants.dart';

import '../../utils/sizeLocal.dart';


class NumberPadPopUp extends StatefulWidget {
  bool? isOpen;
  String? title;
  String subTitle;
  String? value;
  VoidCallback? onPercentageClick;
  VoidCallback? onAmountClick;
  bool? isPercentage;
  VoidCallback? onClear;
  VoidCallback? onClearAll;
  Function(String)? numberTap;
  VoidCallback? onCancel;
  VoidCallback? onDone;
  bool isSevenInch;
  NumberPadPopUp({this.isOpen,this.title,this.value,this.isPercentage,this.onPercentageClick,this.onAmountClick,this.onClear,this.onClearAll,
    this.numberTap,this.onCancel,this.onDone,required this.isSevenInch,this.subTitle=""
  });
  @override
  _NumberPadPopUpState createState() => _NumberPadPopUpState();
}
class _NumberPadPopUpState extends State<NumberPadPopUp> {
  late double _width1;
  List<String> _numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "0", "X"];
  int selectedIndex=-1;

  @override
  void didUpdateWidget(covariant NumberPadPopUp oldWidget) {
    if(!widget.isOpen!){
      setState(() {
        selectedIndex=-1;
        widget.isPercentage=false;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    _width1 = SizeConfig.screenWidth!-30;
    return Align(
      alignment: Alignment.center,
      child: AnimatedContainer(
        height:550,
        width:400,
        duration: Duration(milliseconds:300),
        margin: const EdgeInsets.only(left: 15,right: 15),
        transform: Matrix4.translationValues(widget.isOpen!?0: SizeConfig.screenWidth!, widget.isSevenInch?0: 100, 0),
        curve: Curves.easeIn,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color:Colors.white,),
        clipBehavior: Clip.antiAlias,
        child:Column(
          children: [
            Container(
              height: 50,
              margin: EdgeInsets.only(left: 15,right: 20,top: 15),
              decoration: BoxDecoration(
                color: Color(0xFFe9f3fc),
                borderRadius: BorderRadius.circular(5),
              ),
            //  color:Color(0xFF6D6D6D),
              child: Stack(
                // alignment: Alignment.topCenter,
                children: [
                  Align(
                      alignment: Alignment.topCenter,
                      child:  Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text("${widget.title}",
                            style: TextStyle(fontFamily:'AM',color: ColorUtil.text1 , fontSize: 18, letterSpacing: 0.5)
                        ),
                      )
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child:  Text("${widget.subTitle}",
                          style: TextStyle(fontFamily:'AR',color: ColorUtil.red , fontSize: 15, letterSpacing: 0.5)
                      )
                  ),
                ],
              ),
            ),
            !widget.isOpen!?Container():
            Container(
                height:70,
                child:Stack(
                    children:[
                      Align(
                        alignment: Alignment.center,
                        child: Text(widget.value!.isEmpty/* || widget.value=="0"*/?"":"${widget.value}",
                          style: TextStyle(fontFamily: 'RM',fontSize: 50,color: Color(0xFF5F5F5F)),
                        ),
                      ),

                    ]
                )
            ),

            Container(
              // margin: EdgeInsets.only(top:10),
                height: 310,
                child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    direction: Axis.horizontal,
                    children: _numbers
                        .asMap().map((i, element) => MapEntry(i,
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            updateKeyPad(_numbers[i]);
                            setState((){});
                            Timer(MyConstants.animeDuration, (){
                              setState(() {
                                selectedIndex=-1;
                              });
                            });
                          },
                          child: AnimatedContainer(
                              duration: MyConstants.animeDuration,
                              curve: MyConstants.animeCurve,
                              height: 70,
                              width: _width1*0.3,
                              decoration: BoxDecoration(
                                  color: selectedIndex == i?ColorUtil.red2:Colors.white,
                                  shape: BoxShape.circle
                              ),

                              child: Center(
                                  child: i==11?SvgPicture.asset("assets/icons/delete.svg",height: 30,
                                    color:selectedIndex == i?Colors.white: ColorUtil.text1,
                                  ):
                                  AnimatedCrossFade(
                                    crossFadeState: selectedIndex == i?CrossFadeState.showSecond:CrossFadeState.showFirst,
                                    duration: Duration(milliseconds: 300),
                                    reverseDuration: Duration(milliseconds: 600),
                                    firstChild: Text(_numbers[i],
                                      style: TextStyle(fontFamily: 'RR', color:ColorUtil.text1, fontSize: 28,),
                                      textAlign: TextAlign.center,
                                    ),
                                    secondChild: Text(_numbers[i],
                                      style: TextStyle(fontFamily: 'RR', color:Colors.white, fontSize: 28,),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                              )
                          ),

                        )
                      )
                    ).values.toList()
                )
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                GestureDetector(
                  onTap:(){
                    widget.onCancel!();
                  },
                  child: Container(
                    height: 50.0,
                    width: 140.0,
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
                      child: Text("No",
                        style: TextStyle(fontFamily:'RR',color: Color(0xFF808080),fontSize: 16),
                      ),
                    ),
                  ),
                ),



                GestureDetector(
                  onTap:(){
                    widget.onDone!();
                  },
                  child: Container(
                    height: 50.0,
                    width: 140.0,
                    // margin: EdgeInsets.only(bottom: 0,top:20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: ColorUtil.red,
                      // boxShadow: [
                      //   BoxShadow(
                      //     color:AppTheme.red.withOpacity(0.6),
                      //     offset: const Offset(0, 8.0),
                      //     blurRadius: 15.0,
                      //     // spreadRadius: 2.0,
                      //   ),
                      // ]
                    ),
                    child: Center(
                      child: Text("Yes",
                        style: TextStyle(fontFamily:'RR',color: Colors.white,fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20,)


          ],
        ),
      ),
    );
  }

  void updateKeyPad(String keypad){
    var disVal = "";
    if (keypad == 'X') {
      disVal = widget.value!;
      if(disVal.length==1){
        disVal="";
      }
      else{
        disVal=(disVal.substring(0, disVal.length - 1));
      }
    }
    else if (keypad == 'C') {
      disVal="";
    }
    else if (keypad == '.') {
      disVal =  widget.value!;
      if (!disVal.contains('.') && disVal!="") {
          if (disVal.length < 6) {
            disVal += keypad;
            widget.value!=(disVal);
          }
      }
    }
    else {
      disVal =  widget.value!;
        if (disVal.length < 6) {
          disVal += keypad;
          widget.value!=(disVal);
        }
    }
    widget.numberTap!(disVal);
  }
}
