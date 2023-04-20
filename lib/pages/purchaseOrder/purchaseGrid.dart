import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:flutter_utils/utils/extensionUtils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restainventorymobile/pages/commonView.dart';
import '/pages/purchaseOrder/purchaseForm.dart';
import '/widgets/expandedSection.dart';
import '/api/apiUtils.dart';
import '/utils/colorUtil.dart';
import '/utils/constants.dart';
import '/utils/sizeLocal.dart';
import '/utils/utils.dart';
import '/widgets/arrowAnimation.dart';
import '/widgets/customAppBar.dart';

class PurchaseGrid extends StatefulWidget {
  VoidCallback navCallback;
  PurchaseGrid({Key? key,required this.navCallback}) : super(key: key);

  @override
  State<PurchaseGrid> createState() => _PurchaseGridState();
}

class _PurchaseGridState extends State<PurchaseGrid> with HappyExtension implements HappyExtensionHelperCallback{

  Map widgets={};
  var totalCount=0.obs;

  RxList<dynamic> purchaseOrders=RxList<dynamic>();
  RxList<dynamic> filterPurchaseOrders=RxList<dynamic>();
  RxList<dynamic> innerPurchaseOrders=RxList<dynamic>();

  int selectedIndex=-1;

  @override
  void initState() {
    assignWidgets();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeConfig.screenHeight,
      width: SizeConfig.screenWidth,
      child: Column(
        children: [
          CustomAppBar(
            title: "Purchase Order",
            onTap: widget.navCallback,
          ),
          CustomAppBar2(
            title:  "Total Purchase Order",
            subTitle: "Purchase Available",
            count: totalCount,
            addCb: (){
              fadeRoute(PurchaseForm(
                closeCb: (e){
                  assignWidgets();
                },
              ));
            },
            needDatePicker: true,
            onDateSel: (a){
              dj=a;
              assignWidgets();
            },
          ),
          Flexible(
            child: Obx(()=>ListView.builder(
              shrinkWrap: true,
              itemCount: filterPurchaseOrders.length,
              itemBuilder: (ctx,i){
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: (){
                        if(selectedIndex==i){
                          selectedIndex=-1;
                          innerPurchaseOrders.clear();
                        }
                        else {
                          selectedIndex=i;
                          innerPurchaseOrders.value=purchaseOrders.where((p0) => p0['ParentId'].toString()==filterPurchaseOrders[i]['ParentPrimaryId'].toString()).toList();
                        }
                        setState(() {});
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10,left: 15,right: 10),
                        padding: const EdgeInsets.all(10),
                        width: SizeConfig.screenWidth!*1,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0XFFffffff),
                        ),
                        clipBehavior:Clip.antiAlias,
                        child:  Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("${filterPurchaseOrders[i]['PurchaseOrder']}",style: ts20M(ColorUtil.red),),
                                  inBtwHei(),
                                  Text("${filterPurchaseOrders[i]['StoreName']}",style: ts20M(ColorUtil.themeBlack),),
                                  inBtwHei(),
                                  Text("${getRupeeString(filterPurchaseOrders[i]['GrandTotalAmount'])}",style: ts20M(ColorUtil.themeBlack,fontfamily: 'AH',fontsize: 22),),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("${filterPurchaseOrders[i]['ExpectedDate']}",style: ts20M(ColorUtil.red,fontfamily: 'AH',fontsize: 18),),
                                inBtwHei(height: 15),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [

                                    GridEditIcon(
                                      hasAccess: filterPurchaseOrders[i]['IsEdit'],
                                      onTap: (){
                                        console("edit");
                                        fadeRoute(PurchaseForm(
                                          isEdit: true,
                                          dataJson: getDataJsonForGrid({"PurchaseOrderId":filterPurchaseOrders[i]['PurchaseOrderId']}),
                                          closeCb: (e){
                                            assignWidgets();
                                          },
                                        ));
                                      },
                                    ),
                                    GridDeleteIcon(
                                      hasAccess: filterPurchaseOrders[i]['IsDelete'],
                                    ),
                                    const SizedBox(width: 5,),
                                    ArrowAnimation(
                                      openCb: (value){
                                      },
                                      isclose: selectedIndex!=i,
                                    ),
                                  ],
                                )
                              ],
                            )

                          ],
                        ),
                      ),
                    ),
                    ExpandedSection(
                      expand: selectedIndex==i,
                      child: ListView.builder(
                        itemCount: innerPurchaseOrders.length,
                        physics:const NeverScrollableScrollPhysics(),
                        shrinkWrap:true,
                        itemBuilder: (ctx1,index){
                          return Container(
                            margin: const EdgeInsets.only(left: 20,right: 20),
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: ColorUtil.greyBorder)
                              )
                            ),
                            //  decoration:ColorUtil.formContBoxDec,
                            child: Row(
                             // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      gridCardText("Vendor",innerPurchaseOrders[index]['VendorName']),
                                      gridCardText("Total Materials",innerPurchaseOrders[index]['NoOfMaterial']),
                                      gridCardText("Total Quantity",parseDouble(innerPurchaseOrders[index]['NoOfQuantity'])),
                                      gridCardText("Grand Total",getRupeeString(innerPurchaseOrders[index]['GrandTotalAmount'])),
                                    ],
                                  ),
                                ),
                                EyeIcon(
                                  onTap: (){
                                    fadeRoute(CommomView(
                                        pageTitle: "Purchase Order",
                                        spName: "IV_Purchase_GetPurchaseOrderDetailVendorView",
                                        page: "Purchase",
                                      dataJson: getDataJsonForGrid({
                                        "PurchaseOrderId":innerPurchaseOrders[index]['PurchaseOrderId'],
                                        "VendorId":innerPurchaseOrders[index]['VendorId'],
                                      }),
                                    ));
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  ],
                );
              },
            )),
          )
        ],
      ),
    );
  }

  var dj={"FromDate":DateFormat(MyConstants.dbDateFormat).format(DateTime.now()),
    "ToDate":DateFormat(MyConstants.dbDateFormat).format(DateTime.now())
  };

  @override
  void assignWidgets() async{
    purchaseOrders.clear();
    filterPurchaseOrders.clear();
    parseJson(widgets, "",traditionalParam: TraditionalParam(getByIdSp: "IV_Purchase_GetPurchaseOrderDetail"),needToSetValue: false,resCb: (res){
      console(res);
      try{

        purchaseOrders.value=res['Table'];
        filterPurchaseOrders.value=purchaseOrders.where((p0) => p0['ParentId'].toString()=="0").toList();
        totalCount.value=filterPurchaseOrders.length;

      }catch(e){}
    },loader: showLoader,dataJson: jsonEncode(dj),extraParam: MyConstants.extraParam);
  }

  @override
  void dispose(){
    purchaseOrders.clear();
    filterPurchaseOrders.clear();
    innerPurchaseOrders.clear();
    clearOnDispose();
    super.dispose();
  }
}
