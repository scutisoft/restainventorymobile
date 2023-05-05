import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/fittedText.dart';
import '../../widgets/numberPadPopUp/numberPadPopUp.dart';
import '/widgets/calculation.dart';
import '/widgets/loader.dart';
import '/api/apiUtils.dart';
import '/widgets/inventoryWidgets.dart';
import '/api/sp.dart';
import '/utils/constants.dart';
import '/utils/sizeLocal.dart';
import '/utils/utils.dart';
import '/widgets/alertDialog.dart';
import '/widgets/circle.dart';
import '/widgets/customAppBar.dart';
import '/widgets/pinWidget.dart';
import '/widgets/searchDropdown/search2.dart';
import '/utils/colorUtil.dart';
import '/utils/utilWidgets.dart';

class RecipeViewPage extends StatefulWidget {
  RecipeViewPage({Key? key}) : super(key: key);

  @override
  State<RecipeViewPage> createState() => _RecipeViewPageState();
}

class _RecipeViewPageState extends State<RecipeViewPage> {
  List<dynamic> MaterialList =[
  {"Materialtype":"Ginger","MaterialQty":"2Kg","Materialprice":"250","Materialtotal":"500",},
  {"Materialtype":"Garlic","MaterialQty":"1Kg","Materialprice":"150","Materialtotal":"150",},
  ];
  @override
  Widget build(BuildContext context) {
    return  PageBody(
    body: SizedBox(
      height: SizeConfig.screenHeight,
      width: SizeConfig.screenWidth,
      child: Column(
      mainAxisSize: MainAxisSize.min,
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

            Expanded(
              child: ListView(
              shrinkWrap: true,
              children: [
                inBtwHei(height: 20),
                Container(
                  width: SizeConfig.screenWidth,
                  height: 150,
                  padding: EdgeInsets.only(left: 15,right: 15),
                  margin: EdgeInsets.only(left: 15,right: 15),
                  decoration: BoxDecoration(
                      color: Color(0XFFFBFBFB ),
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0Xff000000).withOpacity(0.1),
                          blurRadius:25.0, // soften the shadow
                          spreadRadius: 0.0, //extend the shadow
                          offset: Offset(
                            0.0, // Move to right 10  horizontally
                            5.0, // Move to bottom 10 Vertically
                          ),
                        ),
                      ],
                      border: Border.all(color: Color(0XFFEEEEEE),width: 1,)
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
                                child: Text('25 KG BIRIYANI RECIPE COST',style: ts18(Color(0XFF9B9FAA),fontsize: 12,fontfamily: 'RR'),),
                              ),
                              Row(
                                children: [
                                  Text('₹',style: ts18(Color(0XFF9CA0AB),fontsize: 25,fontfamily: 'RR'),),
                                  FittedText(
                                    text: '25,523.00',
                                    textStyle: ts20(Color(0XFF444C66),fontsize: 40,fontfamily: 'RB',),
                                    width: SizeConfig.screenWidth!-220,
                                  )
                                  /*RichText(
                            text: TextSpan(
                              text: '25,523',
                              style: ts20(Color(0XFF444C66),fontsize: 40,fontfamily: 'RB',),
                              children: const <TextSpan>[
                                TextSpan(text: '.00', style: TextStyle(color: Color(0XFFC8CAD0),fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )*/
                                ],
                              ), inBtwHei(height: 10),
                              Container(
                                width:SizeConfig.screenWidth!-202,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: Color(0XFF444C66),
                                    borderRadius: BorderRadius.circular(25)
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person_outline,color: Color(0XFFFBFBFB),size: 20,),
                                    SizedBox(width: 2,),
                                    Text('Staff Cost',style:ts18(Color(0XFFFBFBFB),fontsize: 12,fontfamily: 'RR'),),
                                    SizedBox(width: 2,),
                                    Text('₹',style: ts18(Color(0XFFFBFBFB),fontsize: 15,fontfamily: 'RR'),),
                                    SizedBox(width: 2,),
                                    Text('25,523.00',style:ts20(Color(0XFFFBFBFB),fontsize: 15,fontfamily: 'RB',),)
                                  ],),
                              )
                            ],
                          )
                      ),
                      Container(
                          width:140,
                          padding: EdgeInsets.only(left: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Recipetype(Color(0XFF005EFF),'Vessel Cost'),
                              FlexFittedText(
                                text: getRupeeString(25523.00),
                                textStyle: ts20(Color(0XFF444C66),fontsize: 16,fontfamily: 'RB',),
                              ),
                              inBtwHei(height: 20),
                              Recipetype(Color(0XFFF6993F),'Vessel Cost'),
                              FlexFittedText(
                                text: getRupeeString(25523.00),
                                textStyle: ts20(Color(0XFF444C66),fontsize: 16,fontfamily: 'RB',),
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
                  child: Text('Recipe Info',style: ts18(Color(0XFF9B9FAA),fontsize: 14,fontfamily: 'RR'),),
                ),
                inBtwHei(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text('Mr.Ramesh Chef',style: ts20(Color(0XFF444C66),fontsize: 19,fontfamily: 'RB'),),
                ),
                inBtwHei(height: 10),
                RecipeInfo('Recipe Category :','Biriyani'),
                inBtwHei(height: 10),
                RecipeInfo('Cuisine Name :','French Cuisine'),
                inBtwHei(height: 10),
                RecipeInfo('Perparation Time :','02:30 Hr'),
                inBtwHei(height: 10),
                RecipeInfo('Yield Quantity :','50 Kilograms'),
                inBtwHei(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Recipetype(Color(0XFF005EFF),'Material'),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Table(
                    // defaultColumnWidth: FixedColumnWidth(160.0),
                    border: TableBorder.all(
                        color: Color(0XFFCED0D4), style: BorderStyle.solid, width: 1,borderRadius: BorderRadius.circular(13)),
                    children: [
                      TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Item',style: TextStyle(fontSize: 15,fontFamily: 'RR',color: Color(0XFF7C818F)),),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Qty',style: TextStyle(fontSize: 15,fontFamily: 'RM',color: Color(0XFF7C818F)),),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Price',style: TextStyle(fontSize: 15,fontFamily: 'RM',color: Color(0XFF7C818F)),),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Total',style: TextStyle(fontSize: 15,fontFamily: 'RM',color:Color(0XFF7C818F) ),),
                            ),
                          ]
                      ),
                      for(int i=0;i<MaterialList.length;i++)
                        tableView(MaterialList[i]['Materialtype'],"${MaterialList[i]['MaterialQty']}","${MaterialList[i]['Materialprice']}","${MaterialList[i]['Materialtotal']}"),
                    ],
                  ),
                ),
                inBtwHei(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Recipetype(Color(0XFFF6993F),'Vessel Cost'),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Table(
                    // defaultColumnWidth: FixedColumnWidth(160.0),
                    border: TableBorder.all(
                        color: Color(0XFFCED0D4), style: BorderStyle.solid, width: 1,borderRadius: BorderRadius.circular(13)),
                    children: [
                      TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Item',style: TextStyle(fontSize: 15,fontFamily: 'RR',color: Color(0XFF7C818F)),),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Qty',style: TextStyle(fontSize: 15,fontFamily: 'RM',color: Color(0XFF7C818F)),),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Price',style: TextStyle(fontSize: 15,fontFamily: 'RM',color: Color(0XFF7C818F)),),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Total',style: TextStyle(fontSize: 15,fontFamily: 'RM',color:Color(0XFF7C818F) ),),
                            ),
                          ]
                      ),
                      for(int i=0;i<MaterialList.length;i++)
                        tableView(MaterialList[i]['Materialtype'],"${MaterialList[i]['MaterialQty']}","${MaterialList[i]['Materialprice']}","${MaterialList[i]['Materialtotal']}"),
                    ],
                  ),
                ),
                inBtwHei(height: 20),
              ],),
            )

         ],
        ),
    ),
    );
  }
  Widget Recipetype(Color color1 , String Rtype, ){
  return Row(
    children: [
      Icon(Icons.temple_hindu_outlined,color: color1,size: 18,),
      SizedBox(width: 2,),
      Text(Rtype,style: ts18(color1,fontsize: 14,fontfamily: 'RR'),),
    ],
  );
  }

  Widget RecipeInfo(String title , String value){
     return Padding(
         padding: const EdgeInsets.only(left: 25.0),
         child: Row(
           children: [
             Container(
               width: 120,
               child: Text(title ,style: ts18(Color(0XFF9B9FAA),fontsize: 14,fontfamily: 'RR'),),
             ),
             SizedBox(width: 10,),
             Container(
               child: FlexFittedText(
                 text: value,
                 textStyle: ts20(Color(0XFF444C66),fontsize: 14,fontfamily: 'RM'),
               ),
             ),
           ],
         )
     );
  }
  TableRow tableView(String tabelvalue1,String tablevalue2,String tablevalue3,String tablevalue4, ){
    return TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(tabelvalue1,style: TextStyle(fontSize: 15,fontFamily: 'RR',color: Color(0XFF444C66)),),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(tablevalue2,style: TextStyle(fontSize: 15,fontFamily: 'RM',color: Color(0XFF444C66)),),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(getRupeeString(tablevalue3),style: TextStyle(fontSize: 15,fontFamily: 'RM',color: Color(0XFF444C66)),),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(getRupeeString(tablevalue4),style: TextStyle(fontSize: 15,fontFamily: 'RM',color: Color(0XFF444C66)),),
          ),
        ]
    );
  }
}
