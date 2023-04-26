import 'package:flutter/material.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/mixins/extensionMixin.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:get/get.dart';
import '../../widgets/staticColumnScroll/materialInnerGrid.dart';
import '/api/apiUtils.dart';
import '/api/sp.dart';
import '/utils/constants.dart';
import '/utils/sizeLocal.dart';
import '/utils/utils.dart';
import '/widgets/alertDialog.dart';
import '/widgets/circle.dart';
import '/widgets/customAppBar.dart';
import '/utils/colorUtil.dart';
import '/utils/utilWidgets.dart';

class PhysicalStock extends StatefulWidget {
  VoidCallback navCallback;
  PhysicalStock({Key? key, required this.navCallback}) : super(key: key);

  @override
  State<PhysicalStock> createState() => _PhysicalStockState();
}

class _PhysicalStockState extends State<PhysicalStock> {

  RxList<dynamic> productList=RxList();


  @override
  void initState(){
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return PageBody(
      body: Column(
        children: [
          CustomAppBar(
            title: "Physical Stock",
            onTap: widget.navCallback,
          ),
          MaterialInnerGrid(
            height: SizeConfig.screenHeight!-80,
            staticHeaderWidget: Container(
              width: 250,
              height: 60,
              padding: EdgeInsets.only(left: 15),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(5)),
                color: ColorUtil.red,
              ),
              child: Text("Item",style: TextStyle(color:Colors.white, fontFamily:'RR',fontSize: 20),),
            ),
            staticWidget: Column(
              children: productList.asMap().map((key, value) =>MapEntry(key,
                GestureDetector(
                  onTap: (){
                  },
                  child: Container(
                    height: 65,
                    width: 250,
                    padding: EdgeInsets.only(top: 10,bottom: 10,left: 15),
                   // margin: EdgeInsets.only(bottom: key==In.PO_purchaseList.length-1?350:0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: ColorUtil.greyBorder))
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${value.MaterialName}", style: TextStyle(fontFamily: 'RR',color: Colors.white,fontSize: 20),),
                        SizedBox(height: 5,),
                      //  value.materialBrandName==null?Container():Text("${value.materialBrandName}",style: TextStyle(fontFamily: 'RR',color: selectedMaterialId!=key? AppTheme.restroTheme:Colors.white,fontSize: 14),),
                      ],
                    ),
                  ),
                ),
              )
              ).values.toList(),
            ),
            scrollableHeaderWidget: Row(
              children: [
                Container(
                  // height: hei,
                  width: 120,
                  child: Text("Purchase Qty",style: TextStyle(color:Colors.white, fontFamily:'RR',fontSize: 20),textAlign: TextAlign.left,),
                ),
                Container(
                  // height: hei,
                  width: 120,
                  child: Text("Price",style: TextStyle(color:Colors.white, fontFamily:'RR',fontSize: 20),textAlign: TextAlign.center,),
                ),
                Container(
                  // height: hei,
                  width: 110,
                  child: Text("Indent Qty",style: TextStyle(color:Colors.white, fontFamily:'RR',fontSize: 20),textAlign: TextAlign.right,),
                ),
              ],
            ),
            scrollableWidget: Column(
              children: productList.asMap().map((key, value) =>MapEntry(key,
                  GestureDetector(
                    onTap: (){

                    },
                    child: Container(
                      height: 65,
                      padding: EdgeInsets.only(top: 0,bottom: 0,),
                    //  margin: EdgeInsets.only(bottom: key==In.PO_purchaseList.length-1?350:0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(bottom: BorderSide(color:ColorUtil.greyBorder))
                      ),
                      child: Row(
                        children: [
                          Container(
                            // height: hei,
                            width: 120,
                            child: Text("Purchase Qty",style: TextStyle(color:Colors.white, fontFamily:'RR',fontSize: 20),textAlign: TextAlign.left,),
                          ),
                          Container(
                            // height: hei,
                            width: 120,
                            child: Text("Price",style: TextStyle(color:Colors.white, fontFamily:'RR',fontSize: 20),textAlign: TextAlign.center,),
                          ),
                          Container(
                            // height: hei,
                            width: 110,
                            child: Text("Indent Qty",style: TextStyle(color:Colors.white, fontFamily:'RR',fontSize: 20),textAlign: TextAlign.right,),
                          ),
                        ],
                      ),
                    ),
                  )
              )
              ).values.toList(),
            ),
          )
        ],
      ),
    );
  }


}
