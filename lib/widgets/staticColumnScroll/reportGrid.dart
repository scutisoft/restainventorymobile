import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '/utils/constants.dart';
import '/utils/utils.dart';
import '/widgets/searchDropdown/search2.dart';
import '/utils/sizeLocal.dart';
import '../fittedText.dart';
import 'commonViewGrid.dart';

enum ColumnType{
  normal,
  material,
  colSpan
}

class ReportGridStyleModel{
  String? columnName;
  String dataName;
  double width;
  double maxWidth;
  Alignment alignment;
  EdgeInsets edgeInsets;
  bool isActive;
  ColumnType columnType;
  String brandDataName;
  bool needRupeeFormat;
  List<String> colSpanTitle;
  ReportGridStyleModel({this.columnName,this.width=150,this.maxWidth=200,this.alignment=Alignment.centerLeft,
    this.edgeInsets=const EdgeInsets.only(left: 10),this.isActive=true,required this.dataName,
    this.columnType=ColumnType.normal, this.brandDataName="",this.needRupeeFormat=false,
  this.colSpanTitle=const ["Title1","Title2"]});


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

class ReportGrid extends StatefulWidget {

  List<ReportGridStyleModel>? gridDataRowList=[];
  List<dynamic>? gridData=[];

  int? selectedIndex;
  VoidCallback? voidCallback;
  Function(int)? func;
  double? topMargin;//70 || 50
  double? gridBodyReduceHeight;// 260  // 140
  double staticColWidth;

  ReportGrid({this.gridDataRowList,this.gridData,this.selectedIndex,this.voidCallback,this.func,this.topMargin,this.gridBodyReduceHeight,
    this.staticColWidth=150});
  @override
  _ReportGridState createState() => _ReportGridState();
}

class _ReportGridState extends State<ReportGrid> {


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


  ScrollPhysics horizontalPhysics=ClampingScrollPhysics();
  ScrollPhysics verticalPhysics=ClampingScrollPhysics();

  double gridHeight=SizeConfig.screenHeight!-200;
  //double maxWidth=200;

  @override
  Widget build(BuildContext context) {
    //gridHeight=widget.gridData!.length*50.0;
    return Container(
      //height: SizeConfig.screenHeight!-200,
        height: gridHeight+50,
        width: SizeConfig.screenWidth,
        margin: EdgeInsets.only(top: widget.topMargin!,left: 5,right: 5),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            color:AppTheme.gridbodyBgColor,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(3),topRight: Radius.circular(3))
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
                    width: SizeConfig.screenWidth!-widget.staticColWidth-1-11,
                    color: showShadow? AppTheme.bgColor.withOpacity(0.8):AppTheme.bgColor,
                    child: SingleChildScrollView(
                      controller: header,
                      scrollDirection: Axis.horizontal,
                      physics: horizontalPhysics,
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: widget.gridDataRowList!.asMap().
                          map((i, value) => MapEntry(i, i==0?Container():
                          value.isActive?Container(
                              alignment: value.alignment,
                              padding: value.edgeInsets,
                              width: value.width,
                              constraints: BoxConstraints(
                                  minWidth: 100,
                                  maxWidth: value.maxWidth
                              ),
                              child: value.columnType==ColumnType.colSpan?Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(value.columnName!,style: AppTheme.TSWhite166),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(value.colSpanTitle[0],style: AppTheme.TSWhite166),
                                      Text(value.colSpanTitle[1],style: AppTheme.TSWhite166),
                                    ],
                                  )
                                ],
                              ):
                              FittedBox(child: Text(value.columnName!,style: AppTheme.TSWhite166,))
                          ):Container()
                          ))
                              .values.toList()
                      ),
                    ),
                  ),
                  Container(
                    //height: SizeConfig.screenHeight!-widget.gridBodyReduceHeight!,
                    height: gridHeight,
                    width: SizeConfig.screenWidth!-widget.staticColWidth-1-11,
                    alignment: Alignment.topLeft,
                    color: AppTheme.gridbodyBgColor,
                    child: SingleChildScrollView(
                      controller: body,
                      scrollDirection: Axis.horizontal,
                      physics: horizontalPhysics,
                      child: Container(
                        //height: SizeConfig.screenHeight!-widget.gridBodyReduceHeight!,
                        height: gridHeight,
                        alignment: Alignment.topCenter,
                        color:AppTheme.gridbodyBgColor,
                        child: SingleChildScrollView(
                          controller: verticalRight,
                          scrollDirection: Axis.vertical,
                          physics: verticalPhysics,
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
                                        if((10.0*value[v.dataName].toString().length)>v.width){
                                            setState(() {
                                              v.width=10.0*value[v.dataName].toString().length;
                                            });
                                        }

                                        return MapEntry(j,
                                          j==0?Container():v.isActive?Container(
                                            width: v.width,
                                            height: 50,
                                            alignment: v.alignment,
                                            padding: v.edgeInsets,
                                            constraints: BoxConstraints(
                                                minWidth: 100,
                                                maxWidth: v.maxWidth
                                            ),
                                            decoration: BoxDecoration(
                                                color: AppTheme.gridbodyBgColor
                                            ),
                                            child:v.columnType==ColumnType.material?Column(
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
                                            v.columnType==ColumnType.colSpan?Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(child: Text(value[v.dataName]??"",style: AppTheme.gridTextColor14)),
                                                Flexible(child: Text(value[v.brandDataName]??"",style: AppTheme.gridTextColor14)),
                                              ],
                                            ):
                                            Text("${v.needRupeeFormat?getRupeeString(value[v.dataName]):value[v.dataName]}",
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
                    //height: SizeConfig.screenHeight!-widget.gridBodyReduceHeight!,
                    height: gridHeight,
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(
                      //color:showShadow? AppTheme.gridbodyBgColor:Colors.transparent,
                        color: AppTheme.gridbodyBgColor,
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
                      //height: SizeConfig.screenHeight!-widget.gridBodyReduceHeight!,
                      height: gridHeight,
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        controller: verticalLeft,
                        scrollDirection: Axis.vertical,
                        physics: verticalPhysics,
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
                                child: widget.gridDataRowList![0].columnType==ColumnType.material?Column(
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