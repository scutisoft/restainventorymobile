import 'package:flutter/material.dart';

import '../../utils/colorUtil.dart';
import '../../utils/sizeLocal.dart';
import 'commonViewGrid.dart';

class MaterialInnerGrid extends StatefulWidget {

  VoidCallback? drawerCallback;
  String? title;
  Widget? scrollableWidget;
  Widget? scrollableHeaderWidget;
  Widget? staticWidget;
  Widget? staticHeaderWidget;
  double height;
  double staticWidth;
  MaterialInnerGrid({this.drawerCallback,this.title,required this.height,this.scrollableWidget,this.scrollableHeaderWidget,
  this.staticHeaderWidget, this.staticWidget,this.staticWidth=250});

  @override
  _MaterialInnerGridState createState() => _MaterialInnerGridState();
}

class _MaterialInnerGridState extends State<MaterialInnerGrid> {


  ScrollController header=new ScrollController();
  ScrollController body=new ScrollController();
  ScrollController verticalLeft=new ScrollController();
  ScrollController verticalRight=new ScrollController();

  bool showShadow=false;


  double headerHeight=60;

  @override
  void initState() {


    header.addListener(() {
      if(body.offset!=header.offset){
        body.jumpTo(header.offset);
      }
    });

    body.addListener(() {
      if(header.offset!=body.offset){
        header.jumpTo(body.offset);
      }
    });

    verticalLeft.addListener(() {
      if(verticalRight.offset!=verticalLeft.offset){
        verticalRight.jumpTo(verticalLeft.offset);
      }
    });

    verticalRight.addListener(() {
      if(verticalLeft.offset!=verticalRight.offset){
        verticalLeft.jumpTo(verticalRight.offset);
      }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return   Container(
        height:widget.height,
       // height: widget.height,
        width: SizeConfig.screenWidth,
        color: Colors.white,
        margin: EdgeInsets.only(top: 0),
        child: Stack(
          children: [

            //Scrollable
            Positioned(
              left:widget.staticWidth-1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                    /*  Container(
                        height: 30,
                        width: 800,
                        color: Color(0XFF353535),
                      ),*/
                      Container(
                        height: headerHeight,
                        width: SizeConfig.screenWidth!-widget.staticWidth-1,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            color: ColorUtil.red,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(5))
                        ),
                        //   color: showShadow? AppTheme.bgColor.withOpacity(0.8):AppTheme.bgColor,
                        child: SingleChildScrollView(
                          controller: header,
                          scrollDirection: Axis.horizontal,
                          child: widget.scrollableHeaderWidget,
                        ),

                      ),
                    ],
                  ),
                  Container(
                    height: widget.height,
                    width: SizeConfig.screenWidth!-widget.staticWidth-1,
                    alignment: Alignment.topLeft,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      color:Colors.white,
                    ),
                    child: SingleChildScrollView(
                      controller: body,
                      scrollDirection: Axis.horizontal,
                      physics: ClampingScrollPhysics(),
                      child: Container(
                        height: widget.height-headerHeight,
                        alignment: Alignment.topCenter,
                        // color:AppTheme.gridbodyBgColor,
                        color:Colors.white,
                        child: SingleChildScrollView(
                          controller: verticalRight,
                          scrollDirection: Axis.vertical,
                          child: widget.scrollableWidget,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),


            //not Scrollable
            Positioned(
              left: 0,
              child:Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      /*Container(
                        height: 30,
                        width: 250,
                        color: Color(0XFF353535),
                      ),*/
                      widget.staticHeaderWidget!
                    ],
                  ),
                  Container(
                    height: widget.height,
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(
                      //   color:showShadow? AppTheme.gridbodyBgColor:Colors.transparent,
                        color:showShadow? Colors.white:Colors.transparent,
                        boxShadow: [
                          showShadow?  BoxShadow(
                            color: AppTheme.addNewTextFieldText.withOpacity(0.1),
                            spreadRadius: 0,
                            blurRadius: 15,
                            offset: Offset(0, -8), // changes position of shadow
                          ):BoxShadow(color: Colors.transparent)
                        ]
                    ),
                    child: Container(
                      height: widget.height-headerHeight,
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        controller: verticalLeft,
                        scrollDirection: Axis.vertical,
                        child: widget.staticWidget,
                      ),
                    ),
                  ),
                ],
              ),
            ),


          /*  widget.gridBody.isEmpty?Container(
              width: SizeConfig.screenWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 100,),
                  //     Text("No Data Found",style: TextStyle(fontSize: 18,fontFamily:'RMI',color: AppTheme.addNewTextFieldText),),
                  SvgPicture.asset("assets/errors/nodata.svg",height: 300,width: 300,),

                ],
              ),
            ):Container()*/



          ],
        )
    );
  }
}

