import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:restainventorymobile/utils/constants.dart';
import 'package:restainventorymobile/utils/utils.dart';
import 'package:restainventorymobile/widgets/searchDropdown/search2.dart';

import '../../utils/sizeLocal.dart';
import '../fittedText.dart';


class CommonViewGridStyleModel{
  String? columnName;
  String dataName;
  double width;
  Alignment alignment;
  EdgeInsets edgeInsets;
  bool isActive;
  bool isDate;
  bool isMaterial;
  String brandDataName;
  bool needRupeeFormat;
  CommonViewGridStyleModel({this.columnName,this.width=150,this.alignment=Alignment.centerLeft,
    this.edgeInsets=const EdgeInsets.only(left: 10),this.isActive=true,this.isDate=false,required this.dataName,this.isMaterial=false,
  this.brandDataName="",this.needRupeeFormat=false});


  Map<String, dynamic> toJson() => {
    "ColumnName": dataName,

  };

  dynamic get(String propertyName) {
    var _mapRep = toJson();
    if (_mapRep.containsKey(propertyName)) {
      return _mapRep[propertyName];
    }
    throw ArgumentError('propery not found');
  }
}

class CommonViewGrid extends StatefulWidget {

  List<CommonViewGridStyleModel>? gridDataRowList=[];
  List<dynamic>? gridData=[];

  int? selectedIndex;
  VoidCallback? voidCallback;
  Function(int)? func;
  double? topMargin;//70 || 50
  double? gridBodyReduceHeight;// 260  // 140
  double staticColWidth;

  CommonViewGrid({this.gridDataRowList,this.gridData,this.selectedIndex,this.voidCallback,this.func,this.topMargin,this.gridBodyReduceHeight,
  this.staticColWidth=150});
  @override
  _CommonViewGridState createState() => _CommonViewGridState();
}

class _CommonViewGridState extends State<CommonViewGrid> {


  ScrollController header=new ScrollController();
  ScrollController body=new ScrollController();
  ScrollController verticalLeft=new ScrollController();
  ScrollController verticalRight=new ScrollController();

  bool showShadow=false;





  @override
  void initState() {
    header.addListener(() {
      if(body.offset!=header.offset){
        body.jumpTo(header.offset);
      }
      if(header.offset==0){
        setState(() {
          showShadow=false;
        });
      }
      else{
        if(!showShadow){
          setState(() {
            showShadow=true;
          });
        }
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


  ScrollPhysics horizontalPhysics=BouncingScrollPhysics();


  @override
  Widget build(BuildContext context) {
    // print("CustomTable");
    // print(widget.gridData);
    // print(gridDataRowList);
    // print(gridCol);
    // print(widget.selectedIndex);
    return Container(
        height: SizeConfig.screenHeight!-200,
        width: SizeConfig.screenWidth,
        margin: EdgeInsets.only(top: widget.topMargin!,left: 5,right: 5),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            color:AppTheme.gridbodyBgColor,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(3),topRight: Radius.circular(3))
        ),
        child: Stack(
          children: [

            //Scrollable
            Positioned(
              left:widget.staticColWidth-1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 50,
                    width: SizeConfig.screenWidth!-widget.staticColWidth-1,
                    color: showShadow? AppTheme.bgColor.withOpacity(0.8):AppTheme.bgColor,
                    child: SingleChildScrollView(
                      controller: header,
                      scrollDirection: Axis.horizontal,
                      physics: horizontalPhysics,
                      child: Row(
                          children: widget.gridDataRowList!.asMap().
                          map((i, value) => MapEntry(i, i==0?Container():
                          value.isActive?Container(
                              alignment: value.alignment,
                              padding: value.edgeInsets,
                              width: value.width,
                              constraints: BoxConstraints(
                                  minWidth: 100,
                                  maxWidth: 200
                              ),
                              child: FittedBox(child: Text(value.columnName!,style: AppTheme.TSWhite166,))
                          ):Container()
                          ))
                              .values.toList()
                      ),
                    ),
                  ),
                  Container(
                    height: SizeConfig.screenHeight!-widget.gridBodyReduceHeight!,
                    width: SizeConfig.screenWidth!-widget.staticColWidth-1,
                    alignment: Alignment.topLeft,
                    color: AppTheme.gridbodyBgColor,
                    child: SingleChildScrollView(
                      controller: body,
                      scrollDirection: Axis.horizontal,
                      physics: horizontalPhysics,
                      child: Container(
                        height: SizeConfig.screenHeight!-widget.gridBodyReduceHeight!,
                        alignment: Alignment.topCenter,
                        color:AppTheme.gridbodyBgColor,
                        child: SingleChildScrollView(
                          controller: verticalRight,
                          scrollDirection: Axis.vertical,
                         // physics: BouncingScrollPhysics(),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:widget.gridData!.asMap().
                              map((i, value) => MapEntry(
                                  i,InkWell(
                                //   onTap: widget.voidCallback,
                                onTap: (){
                                  widget.func!(i);
                                  //setState(() {});
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: AppTheme.gridBottomborder,
                                    color: widget.selectedIndex==i?AppTheme.yellowColor:AppTheme.gridbodyBgColor,
                                  ),
                                  height: 50,
                               //   margin: EdgeInsets.only(bottom:i==widget.gridData!.length-1?70: 0),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,

                                      children: widget.gridDataRowList!.asMap().map((j, v) {
                                        if(!v.isDate){
                                          if((10.0*value[v.dataName].toString().length)>v.width){
                                            setState(() {
                                              v.width=10.0*value[v.dataName].toString().length;
                                            });
                                          }
                                        }
                                        return MapEntry(j,
                                          j==0?Container():v.isActive?!v.isDate?Container(
                                            width: v.width,
                                            height: 50,
                                            alignment: v.alignment,
                                            padding: v.edgeInsets,
                                            constraints: BoxConstraints(
                                                minWidth: 100,
                                                maxWidth: 200
                                            ),
                                            decoration: BoxDecoration(      ),
                                            child:v.isMaterial?Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("${value[v.dataName]}",
                                                  style:widget.selectedIndex==i?AppTheme.bgColorTS14:AppTheme.gridTextColor14,
                                                ),
                                                Visibility(
                                                    visible: !checkNullEmpty(value[v.brandDataName]),
                                                    child: FittedText(
                                                      width: widget.staticColWidth,
                                                      alignment: Alignment.centerLeft,
                                                      text: "${value[v.brandDataName]}",
                                                      textStyle: ts20M(AppTheme.bgColor,fontsize: 14),
                                                    )
                                                ),
                                              ],
                                            ):
                                            Text("${v.needRupeeFormat?getRupeeString(value[v.dataName]):value[v.dataName]}",
                                              style:widget.selectedIndex==i?AppTheme.bgColorTS14:AppTheme.gridTextColor14,
                                            ),
                                          ):Container(
                                            width: v.width,
                                            height: 50,
                                            alignment: v.alignment,
                                            padding: v.edgeInsets,
                                            constraints: BoxConstraints(
                                                minWidth: 100,
                                                maxWidth: 200
                                            ),
                                            decoration: BoxDecoration(

                                            ),

                                            child: Text("${value[v.dataName]!=null?DateFormat('dd-MM-yyyy').format(DateTime.parse(value[v.dataName])):" "}",
                                              style:widget.selectedIndex==i?AppTheme.bgColorTS14:AppTheme.gridTextColor14,
                                            ),
                                          )
                                              :Container(),
                                        );
                                      }
                                      ).values.toList()
                                  ),
                                ),
                              )
                              )
                              ).values.toList()
                          ),
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
              child:widget.gridDataRowList!.isEmpty?Container(): Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 50,
                    width: widget.staticColWidth,
                    color: AppTheme.bgColor,
                    padding: widget.gridDataRowList![0].edgeInsets,
                    alignment: widget.gridDataRowList![0].alignment,
                    child: FittedBox(child: Text("${widget.gridDataRowList![0].columnName}",style: AppTheme.TSWhite166,)),

                  ),
                  Container(
                    height: SizeConfig.screenHeight!-widget.gridBodyReduceHeight!,
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(
                        color:showShadow? AppTheme.gridbodyBgColor:Colors.transparent,
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
                      height: SizeConfig.screenHeight!-widget.gridBodyReduceHeight!,
                      alignment: Alignment.topCenter,

                      child: SingleChildScrollView(
                        controller: verticalLeft,
                        scrollDirection: Axis.vertical,
                       // physics: BouncingScrollPhysics(),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: widget.gridData!.asMap().
                            map((i, value) => MapEntry(
                                i,InkWell(
                              onTap: (){
                                widget.func!(i);
                                //setState(() {});
                              },
                              child:  Container(
                                alignment:widget.gridDataRowList![0].alignment,
                                padding: widget.gridDataRowList![0].edgeInsets,
                            //    margin: EdgeInsets.only(bottom:i==widget.gridData!.length-1?70: 0),
                                decoration: BoxDecoration(
                                  border: AppTheme.gridBottomborder,
                                  color: widget.selectedIndex==i?AppTheme.yellowColor:AppTheme.gridbodyBgColor,
                                ),
                                height: 50,
                                width: widget.staticColWidth,
                                child: widget.gridDataRowList![0].isMaterial?Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${value[widget.gridDataRowList![0].dataName]}",
                                      style:widget.selectedIndex==i?AppTheme.bgColorTS14:AppTheme.gridTextColor14,
                                    ),
                                    Visibility(
                                      visible: !checkNullEmpty(value[widget.gridDataRowList![0].brandDataName]),
                                      child: FittedText(
                                        width: widget.staticColWidth,
                                        alignment: Alignment.centerLeft,
                                        text: "${value[widget.gridDataRowList![0].brandDataName]}",
                                        textStyle: ts20M(AppTheme.bgColor,fontsize: 14),
                                      )
                                    ),
                                  ],
                                ):Text("${value[widget.gridDataRowList![0].dataName]}",
                                  style:widget.selectedIndex==i?AppTheme.bgColorTS14:AppTheme.gridTextColor14,
                                ),
                              ),
                            )
                            )
                            ).values.toList()



                        ),
                      ),


                    ),
                  ),
                ],
              ),
            ),


            widget.gridData!.isEmpty?Container(
              width: SizeConfig.screenWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 70,),
                  Text("No Data Found",style: TextStyle(fontSize: 18,fontFamily:'RMI',color: AppTheme.addNewTextFieldText),),
                  SvgPicture.asset("assets/nodata.svg",height: 350,),

                ],
              ),
            ):Container()



          ],
        )

    );
  }
}




class AppTheme {
  AppTheme._();



  static const Color yellowColor=Color(0xFFFFC010);
  static const Color bgColor=Color(0xffFF0022);
  static const Color red=Color(0xFFE34343);
  static const Color addNewTextFieldBorder=Color(0xFFCDCDCD);
  static const Color addNewTextFieldFocusBorder=Color(0xFF6B6B6B);

  static  Color addNewTextFieldText=Color(0xFF787878);

  static  Color indicatorColor=Color(0xFF1C1C1C);

  static  Color grey=Color(0xFF787878);
  static  Color gridTextColor=Color(0xFF787878);
  static  Color gridbodyBgColor=Color(0xFFF6F7F9);
  static  Color disableColor=Color(0xFFe8e8e8);

  static  Color uploadColor=Color(0xFFC7D0D8);
  static  Color avatarBorderColor=Color(0xFFC7D0D8);
  static  Color hintColor=Color(0xFFC5C5C5);

  static const Color EFEFEF=Color(0xFFEFEFEF);
  static const Color f737373=Color(0xFF737373);
  static const Color unitSelectColor=Color(0xFFF3F4F9);

  static TextStyle discountDeactive=TextStyle(fontFamily: 'RR',fontSize: 20,color: Color(0xFF777A92));
  static TextStyle discountactive=TextStyle(fontFamily: 'RR',fontSize: 20,color: Colors.white);

  static  TextStyle hintText=TextStyle(fontFamily: 'RR',fontSize: 16,color: addNewTextFieldText.withOpacity(0.5));
  static TextStyle TSWhite20=TextStyle(fontFamily: 'RR',fontSize: 20,color: Colors.white,letterSpacing: 0.1);
  static TextStyle TSWhite16=TextStyle(fontFamily: 'RR',fontSize: 18,color: Colors.white,letterSpacing: 0.1);
  static TextStyle TSWhite166=TextStyle(fontFamily: 'AM',fontSize: 16,color: Colors.white,letterSpacing: 0.1);

  static TextStyle TSWhiteML=TextStyle(fontFamily: 'RR',fontSize: 14,color: Colors.white,letterSpacing: 0.1);
  //CT colourTextStyle
  static TextStyle ML_bgCT=TextStyle(fontFamily: 'RR',color: AppTheme.bgColor,fontSize: 14);


  static TextStyle userNameTS=TextStyle(fontFamily: 'RM',color: AppTheme.bgColor,fontSize: 16);
  static TextStyle userGroupTS=TextStyle(fontFamily: 'RL',color: AppTheme.gridTextColor,fontSize: 14);
  static TextStyle userDesgTS=TextStyle(fontFamily: 'RR',color:AppTheme.grey.withOpacity(0.5),fontSize: 12);



  static TextStyle bgColorTS=TextStyle(fontFamily: 'RR',color: AppTheme.bgColor,fontSize: 16);
  static TextStyle bgColorTS14=TextStyle(fontFamily: 'RR',color: AppTheme.bgColor,fontSize: 14);
  static TextStyle gridTextColorTS=TextStyle(fontFamily: 'RR',color: AppTheme.gridTextColor,fontSize: 16);
  static TextStyle gridTextColor14=TextStyle(fontFamily: 'AM',color: AppTheme.gridTextColor,fontSize: 14);
  static TextStyle gridTextGreenColor14=TextStyle(fontFamily: 'RR',color: Colors.green,fontSize: 14);
  static TextStyle gridTextRedColor14=TextStyle(fontFamily: 'RR',color: AppTheme.red,fontSize: 14);


  static const Color popUpSelectedColor=Color(0xFF3B3B3D);
  static const Color editDisableColor=Color(0xFFF2F2F2);

  static  Border gridBottomborder= Border(bottom: BorderSide(color: AppTheme.addNewTextFieldBorder.withOpacity(0.5)));


  //yellow BoxShadow
  static BoxShadow yellowShadow=  BoxShadow(
    color: AppTheme.yellowColor.withOpacity(0.4),
    spreadRadius: 1,
    blurRadius: 5,
    offset: Offset(1, 8), // changes position of shadow
  );
/*  boxShadow: [
  qn.supplierMaterialMappingList.length==0?BoxShadow():
        BoxShadow(
            color: AppTheme.addNewTextFieldText.withOpacity(0.2),
        spreadRadius: 2,
  blurRadius: 15,
  offset: Offset(0, 0), // changes position of shadow
  )
  ]*/

  static EdgeInsets gridAppBarPadding=EdgeInsets.only(bottom: 15);
  static EdgeInsets leftRightMargin20=EdgeInsets.only(left: SizeConfig.width20!,right: SizeConfig.width20!);
  static BorderRadius gridTopBorder=BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15));


  //Appbar TextStyle
  static TextStyle appBarTS=TextStyle(fontFamily: 'RR',color: AppTheme.bgColor,fontSize: 16);

  //rawScrollBar Properties
  static const Color srollBarColor=Colors.grey;
  static const double scrollBarRadius=5.0;
  static const double scrollBarThickness=4.0;


  //DashBoard
  static const Color dashCalendar=Color(0xFFCDCDCD);
  static const Color attendanceDashText1=Color(0xFF949494);
  static const Color spikeColor=Color(0xFFD1E7E7);
  static const Color yAxisText=Color(0xFFB38C1E);

  static TextStyle saleChartTotal=TextStyle(fontFamily: 'RM',fontSize: 12,color: Color(0xffadadad),letterSpacing: 0.1);
  static TextStyle saleChartQty=TextStyle(fontFamily: 'RM',fontSize: 12,color: Color(0xFF6a6a6a),letterSpacing: 0.1);

}