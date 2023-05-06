import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restainventorymobile/widgets/loader.dart';
import '../../api/apiUtils.dart';
import '../../utils/colorUtil.dart';
import '../../widgets/alertDialog.dart';
import '../../widgets/fittedText.dart';
import '../../widgets/searchDropdown/search2.dart';
import '/utils/constants.dart';
import '/utils/sizeLocal.dart';
import '/utils/utils.dart';
import '/widgets/customAppBar.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/mixins/extensionMixin.dart';
import 'package:flutter_utils/model/parameterModel.dart';
import 'package:flutter_utils/utils/apiUtils.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';

class RecipeViewPage extends StatefulWidget {
  String recipeId;
  RecipeViewPage({Key? key,required this.recipeId}) : super(key: key);

  @override
  State<RecipeViewPage> createState() => _RecipeViewPageState();
}

class _RecipeViewPageState extends State<RecipeViewPage> {

  List<dynamic> materialList=[];
  List<dynamic> vesselList=[];
  List<dynamic> staffList=[];
  final FlutterUtils _flutterUtils=FlutterUtils();
  Map details={};

  RxBool loader=RxBool(false);

  @override
  void initState(){
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  PageBody(
    body: Stack(
        children: [
          SizedBox(
            height: SizeConfig.screenHeight,
            width: SizeConfig.screenWidth,
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              children: [
                CustomAppBar(
                  title: "Recipe Order / Preview",
                  width: SizeConfig.screenWidth! - 100,
                  prefix: ArrowBack(
                    onTap: () {
                      Get.back();
                    },
                  ),
                ),

                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      inBtwHei(height: 20),
                      Container(
                        width: SizeConfig.screenWidth,
                        height: 150,
                        padding: const EdgeInsets.only(left: 15,right: 15),
                        margin: const EdgeInsets.only(left: 15,right: 15),
                        decoration: BoxDecoration(
                            color: const Color(0XFFFBFBFB ),
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0Xff000000).withOpacity(0.1),
                                blurRadius:25.0, // soften the shadow
                                spreadRadius: 0.0, //extend the shadow
                                offset: const Offset(
                                  0.0, // Move to right 10  horizontally
                                  5.0, // Move to bottom 10 Vertically
                                ),
                              ),
                            ],
                            border: Border.all(color: const Color(0XFFEEEEEE),width: 1,)
                        ),
                        child: Row(
                          children: [
                            Container(
                                width:SizeConfig.screenWidth!-202,
                                // color: Colors.red,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 15.0),
                                      child: Text('${details['RecipeName']??""} RECIPE COST',style: ts18(const Color(0XFF9B9FAA),fontsize: 12,fontfamily: 'RR'),),
                                    ),
                                    Row(
                                      children: [
                                        Text(MyConstants.rupeeString,style: ts18(const Color(0XFF9CA0AB),fontsize: 25,fontfamily: 'RR'),),
                                        FittedText(
                                          text: getRupeeFormat(details['TotalCost']),
                                          textStyle: ts20(const Color(0XFF444C66),fontsize: 40,fontfamily: 'RB',),
                                          width: SizeConfig.screenWidth!-220,
                                        )
                                      ],
                                    ), inBtwHei(height: 10),
                                    Container(
                                      width:SizeConfig.screenWidth!-202,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color: const Color(0XFF444C66),
                                          borderRadius: BorderRadius.circular(25)
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.person_outline,color: Color(0XFFFBFBFB),size: 20,),
                                          const SizedBox(width: 2,),
                                          Text('Staff Cost',style:ts18(const Color(0XFFFBFBFB),fontsize: 12,fontfamily: 'RR'),),
                                          const SizedBox(width: 2,),
                                          FlexFittedText(
                                            text: getRupeeString(details['StaffCost']),
                                            textStyle: ts20(const Color(0XFFFBFBFB),fontsize: 15,fontfamily: 'RB',),
                                          ),
                                          // Text('₹',style: ts18(const Color(0XFFFBFBFB),fontsize: 15,fontfamily: 'RR'),),
                                          // const SizedBox(width: 2,),
                                          //
                                          // Text('25,523.00',style:ts20(const Color(0XFFFBFBFB),fontsize: 15,fontfamily: 'RB',),)
                                        ],),
                                    )
                                  ],
                                )
                            ),
                            Container(
                                width:140,
                                padding: const EdgeInsets.only(left: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Recipetype(const Color(0XFF005EFF),'Material Cost'),
                                    FlexFittedText(
                                      text: getRupeeString(details['MaterialCost']),
                                      textStyle: ts20(const Color(0XFF444C66),fontsize: 16,fontfamily: 'RB',),
                                    ),
                                    inBtwHei(height: 20),
                                    Recipetype(const Color(0XFFF6993F),'Vessel Cost'),
                                    FlexFittedText(
                                      text: getRupeeString(details['VesselCost']),
                                      textStyle: ts20(const Color(0XFF444C66),fontsize: 16,fontfamily: 'RB',),
                                    ),
                                  ],
                                )
                            ),
                          ],
                        ),
                      ),
                      inBtwHei(height: 25),
                      Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: Text('Recipe Info',style: ts18(const Color(0XFF9B9FAA),fontsize: 14,fontfamily: 'RR'),),
                      ),
                      inBtwHei(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: Text('${details['ChefName']??""}',style: ts20(const Color(0XFF444C66),fontsize: 19,fontfamily: 'RB'),),
                      ),
                      inBtwHei(height: 10),
                      RecipeInfo('Recipe Category :','${details['RecipeCategoryName']??""}'),
                      inBtwHei(height: 10),
                      RecipeInfo('Cuisine Name :','${details['CuisineName']??""}'),
                      inBtwHei(height: 10),
                      RecipeInfo('Preparation Time :','${details['PreParationTime']??""}'),
                      inBtwHei(height: 10),
                      RecipeInfo('Yield Quantity :','${details['YieldQuantity']??""} ${details['UnitShortCode']??""}'),
                      inBtwHei(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: Recipetype(const Color(0XFF005EFF),'Material'),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                        child: Table(
                          columnWidths: {
                            0: FlexColumnWidth(3),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(2),
                            3: FlexColumnWidth(2),
                          },
                          // defaultColumnWidth: FixedColumnWidth(160.0),
                          border: TableBorder.all(
                              color: const Color(0XFFCED0D4), style: BorderStyle.solid, width: 1,borderRadius: BorderRadius.circular(13)),
                          children: [
                            const TableRow(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Item',style: TextStyle(fontSize: 15,fontFamily: 'RR',color: Color(0XFF7C818F)),),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Qty',style: TextStyle(fontSize: 15,fontFamily: 'RM',color: Color(0XFF7C818F)),),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Price',style: TextStyle(fontSize: 15,fontFamily: 'RM',color: Color(0XFF7C818F)),),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Total',style: TextStyle(fontSize: 15,fontFamily: 'RM',color:Color(0XFF7C818F) ),textAlign: TextAlign.right,),
                                  ),
                                ]
                            ),
                            for(int i=0;i<materialList.length;i++)
                              tableView(
                                  materialList[i]['MaterialName'],
                                  "${materialList[i]['Quantity']}",
                                  getRupeeString(materialList[i]['Price']),
                                  getRupeeString(materialList[i]['Cost']),
                                  isMaterial: true,
                                  brandName: materialList[i]['MaterialBrandName']
                              ),
                          ],
                        ),
                      ),
                      inBtwHei(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: Recipetype(const Color(0XFFF6993F),'Vessel Cost'),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                        child: Table(
                          // defaultColumnWidth: FixedColumnWidth(160.0),
                          border: TableBorder.all(
                              color: const Color(0XFFCED0D4), style: BorderStyle.solid, width: 1,borderRadius: BorderRadius.circular(13)),
                          children: [
                            const TableRow(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Vessel & Essential',style: TextStyle(fontSize: 15,fontFamily: 'RR',color: Color(0XFF7C818F)),),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Qty',style: TextStyle(fontSize: 15,fontFamily: 'RM',color: Color(0XFF7C818F)),),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Usage Time',style: TextStyle(fontSize: 15,fontFamily: 'RM',color: Color(0XFF7C818F)),),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Usage Cost',style: TextStyle(fontSize: 15,fontFamily: 'RM',color:Color(0XFF7C818F) ),),
                                  ),
                                ]
                            ),
                            for(int i=0;i<vesselList.length;i++)
                              tableView(
                                  vesselList[i]['VesselName'],
                                  "${vesselList[i]['VesselQuantity']}",
                                  "${vesselList[i]['EssentialTime']}",
                                  getRupeeString(vesselList[i]['UsageCost']),
                                  isMaterial: true,
                                  brandName: vesselList[i]['VesselCategoryName']
                              ),
                          ],
                        ),
                      ),
                      inBtwHei(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: Recipetype(const Color(0XFF444C66),'Staff Cost'),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                        child: Table(
                          // defaultColumnWidth: FixedColumnWidth(160.0),
                          border: TableBorder.all(
                              color: const Color(0XFFCED0D4), style: BorderStyle.solid, width: 1,borderRadius: BorderRadius.circular(13)),
                          children: [
                            const TableRow(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Category',style: TextStyle(fontSize: 15,fontFamily: 'RR',color: Color(0XFF7C818F)),),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Total Staff',style: TextStyle(fontSize: 15,fontFamily: 'RM',color: Color(0XFF7C818F)),),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Working Time',style: TextStyle(fontSize: 15,fontFamily: 'RM',color: Color(0XFF7C818F)),),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Salary Cost',style: TextStyle(fontSize: 15,fontFamily: 'RM',color:Color(0XFF7C818F) ),),
                                  ),
                                ]
                            ),
                            for(int i=0;i<staffList.length;i++)
                              tableView(
                                staffList[i]['StaffCategoryName'],
                                "${staffList[i]['TotalStaff']}",
                                "${staffList[i]['WorkingTime']}",
                                getRupeeString(staffList[i]['SalaryCost']),
                              ),
                          ],
                        ),
                      ),
                      inBtwHei(height: 20),
                    ],),
                )

              ],
            ),
          ),
          ShimmerLoader(loader: loader,topMargin: 80,)
        ],
      ),
    );
  }

  void getData() async{
    List<ParamModel> parameterList=await getParamEssential(extraParam: MyConstants.extraParam);
    parameterList.add(ParamModel(Key: "RecipeId", Type: "String", Value: widget.recipeId));
    parameterList.add(ParamModel(Key: "SpName", Type: "String", Value: "IV_Recipe_GetRecipeIdViewDetail"));
    _flutterUtils.getInvoke(parameterList,loader: loader,url: "${GetBaseUrl()}/api/Mobile/GetInvoke").then((value){
      if(value[0]){
        var parsed=jsonDecode(value[1]);
        console(parsed);
        if(parsed['Table']!=null && parsed['Table'].length>0){
          details=parsed['Table'][0];
        }
        try{
          materialList=parsed['Table1'];
          staffList=parsed['Table2'];
          vesselList=parsed['Table3'];
        }catch(E){

        }
        setState(() {});
      }
      else{
        CustomAlert().cupertinoAlert(value[1]);
      }
    });
  }

  Widget Recipetype(Color color1 , String Rtype, ){
  return Row(
    children: [
      Icon(Icons.temple_hindu_outlined,color: color1,size: 18,),
      const SizedBox(width: 2,),
      Text(Rtype,style: ts18(color1,fontsize: 14,fontfamily: 'RR'),),
    ],
  );
  }
  Widget RecipeInfo(String title , String value){
     return Container(
        padding: EdgeInsets.only(left: 20),
       width: SizeConfig.screenWidth,
       child: Row(
         mainAxisSize: MainAxisSize.min,
         children: [
           Container(
             width: 120,
             child: Text(title ,style: ts18(const Color(0XFF9B9FAA),fontsize: 14,fontfamily: 'RR'),),
           ),
           const SizedBox(width: 10,),
           Container(
             width: SizeConfig.screenWidth!-200,
               alignment:Alignment.centerLeft,
               color: Colors.transparent,
               child: Text("$value",style: ts20(const Color(0XFF444C66),fontsize: 14,fontfamily: 'RM'))
           )
         ],
       ),
     );
  }
  TableRow tableView(String tabelvalue1,String tablevalue2,String tablevalue3,String tablevalue4,{bool isMaterial=false,String? brandName} ){
    return TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: isMaterial?Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tabelvalue1,
                  style: TextStyle(fontSize: 15,fontFamily: 'RR',color: Color(0XFF444C66)),
                ),
                Visibility(
                  visible: !checkNullEmpty(brandName),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text("$brandName",
                      style: ts20M(ColorUtil.red2,fontsize: 13),
                    ),
                  ),
                ),
              ],
            )
                :Text(tabelvalue1,style: const TextStyle(fontSize: 15,fontFamily: 'RR',color: Color(0XFF444C66)),),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(tablevalue2,style: const TextStyle(fontSize: 15,fontFamily: 'RM',color: Color(0XFF444C66)),),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: FittedBox(child: Text(tablevalue3,style: const TextStyle(fontSize: 15,fontFamily: 'RM',color: Color(0XFF444C66)),)),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerRight,
            child: FittedBox(child: Text(tablevalue4,style: const TextStyle(fontSize: 15,fontFamily: 'RM',color: Color(0XFF444C66)),)),
          ),
        ]
    );
  }
}
