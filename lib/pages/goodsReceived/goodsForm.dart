
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/model/parameterModel.dart';
import 'package:flutter_utils/utils/apiUtils.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../widgets/numberPadPopUp/numberPadPopUp.dart';
import '/widgets/calculation.dart';
import '/widgets/expandedSection.dart';
import '/widgets/loader.dart';
import '/api/apiUtils.dart';
import '/widgets/arrowAnimation.dart';
import '/widgets/inventoryWidgets.dart';
import '/api/sp.dart';
import '/utils/constants.dart';
import '/utils/sizeLocal.dart';
import '/utils/utils.dart';
import '/widgets/alertDialog.dart';
import '/widgets/circle.dart';
import '/widgets/customAppBar.dart';
import '/widgets/expectedDateContainer.dart';
import '/widgets/pinWidget.dart';
import '/widgets/searchDropdown/search2.dart';
import '/utils/colorUtil.dart';
import '/utils/utilWidgets.dart';
import '/widgets/singleDatePicker.dart';
import '/widgets/swipe2/core/cell.dart';
import '/widgets/swipe2/core/controller.dart';

class GoodsForm extends StatefulWidget {
  bool isEdit;
  Function? closeCb;
  String dataJson;
  GoodsForm({Key? key,this.isEdit=false,this.closeCb,this.dataJson=""}) : super(key: key);

  @override
  State<GoodsForm> createState() => _GoodsFormState();
}

class _GoodsFormState extends State<GoodsForm> with HappyExtension implements HappyExtensionHelperCallback{

  Map widgets={};

  String page="Goods";
  TraditionalParam traditionalParam=TraditionalParam(
      getByIdSp: "IV_Goods_GetByGoodsReceivedIdDetail",
      insertSp: "",
      updateSp: "IV_Goods_UpdateGoodsReceivedDetail"
  );
  var isKeyboardVisible=false.obs;


  var unitName="Unit".obs;
  var poNum="".obs;


  RxList<dynamic> counterList=RxList<dynamic>();
  RxList<dynamic> vendorMaterialList=RxList<dynamic>();

  var isCartOpen=false.obs;
  var selectedIndex=(-1).obs;


  late SwipeActionController controller;
  final FlutterUtils _flutterUtils=FlutterUtils();

  var numPadUtils={
    "isNumPadOpen":false,
    "numPadVal":"",
    "numPadTitle":"",
    "numPadSubTitle":"",
    "vendorIndex":-1,
    "productIndex":-1
  }.obs;

  @override
  void initState(){
    controller = SwipeActionController(selectedIndexPathsChangeCallback: (changedIndexPaths, selected, currentCount) {},);
    assignWidgets();
    super.initState();
  }

  double width1=SizeConfig.screenWidth!-30;
  @override
  Widget build(BuildContext context) {
    isKeyboardVisible.value = MediaQuery.of(context).viewInsets.bottom != 0;
    return PageBody(
        body: Stack(
          children: [
            SizedBox(
              height: SizeConfig.screenHeight,
              width: SizeConfig.screenWidth,
              child: Column(
                children: [
                  Obx(() => CustomAppBar(
                    title: "Goods Received ${poNum.value}",
                    width: SizeConfig.screenWidth!-100,
                    prefix: ArrowBack(
                      onTap: (){
                        Get.back();
                      },
                    ),
                  )),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      //physics: NeverScrollableScrollPhysics(),
                      children: [
                        inBtwHei(height: 10),
                        Container(
                          height: 120,
                          width: width1,
                          padding: const EdgeInsets.only(left: 15,right: 0,),
                          child: Obx(() => ListView.builder(
                            itemCount: counterList.length,
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (ctx,i){
                              return  Container(
                                padding: const EdgeInsets.all(15),
                                width: width1*0.9,
                                margin: const EdgeInsets.only(right: 15),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: getVendorStatusBorderColor(counterList[i]['InventoryStatusId'])),
                                    color: getVendorStatusBgColor(counterList[i]['InventoryStatusId'])
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        flexRichText("Vendor", counterList[i]['VendorName']),
                                        flexRichText("No 0f Material", counterList[i]['NoOfMaterial']),
                                      ],
                                    ),
                                    inBtwHei(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        flexRichText("Status", counterList[i]['InventorystatusName']),
                                        flexRichText("Amount", '${MyConstants.rupeeString}${getRupeeFormat(counterList[i]['GrandTotal'])}',textAlign: TextAlign.end),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          )),
                        ),
                        LeftHeader(title: "Vendor"),
                        widgets['PurchaseOrderVendorMappingId'],
                        LeftHeader(title: "Materials"),
                        Obx(() => ListView.builder(
                          shrinkWrap: true,
                          itemCount: vendorMaterialList.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (ctx,index){
                            return Container(
                              margin: const EdgeInsets.only(left: 15,right: 15,bottom: 10),
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              decoration: BoxDecoration(
                                 borderRadius: BorderRadius.circular(8),
                                color: const Color(0XFFffffff),
                              ),

                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${vendorMaterialList[index]['MaterialName']}",
                                    style: ts20M(ColorUtil.themeBlack,fontsize: 18),
                                  ),
                                  Visibility(
                                    visible: !checkNullEmpty(vendorMaterialList[index]['MaterialBrandName']),
                                    child: Text("${vendorMaterialList[index]['MaterialBrandName']}",
                                      style: ts20M(ColorUtil.red2,fontsize: 15),
                                    ),
                                  ),
                                  inBtwHei(height: 10),
                                  inBtwHei(height: 3),
                                  gridCardText("Actual Ordered",vendorMaterialList[index]['OrderedQty'],
                                    suffix: Text("  ${vendorMaterialList[index]['UnitName']}",style: ts20M(ColorUtil.text2,fontfamily: 'ALO',fontsize: 15),),
                                  ),
                                  inBtwHei(height: 3),
                                  gridCardText("Total Ordered",vendorMaterialList[index]['TotalReceivedQty'],
                                    suffix: Text("  ${vendorMaterialList[index]['UnitName']}",style: ts20M(ColorUtil.text2,fontfamily: 'ALO',fontsize: 15),),
                                  ),
                                  GestureDetector(
                                    onTap: (){
                                      console("aaa");
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      margin: const EdgeInsets.only(top: 3),
                                      child: gridCardText("Current Received Qty",vendorMaterialList[index]['TotalReceivedQty'],
                                        suffix: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("  ${vendorMaterialList[index]['UnitName']}",style: ts20M(ColorUtil.text2,fontfamily: 'ALO',fontsize: 15),),
                                            const SizedBox(width: 5,),
                                            SvgPicture.asset("assets/icons/edit.svg",height: 20,),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  GestureDetector(
                                    onTap: (){
                                      console("bbb");
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      margin: const EdgeInsets.only(top: 3),
                                      child: gridCardText("Bill Price Per Qty",getRupeeFormat(vendorMaterialList[index]['Price']),
                                        suffix: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(width: 5,),
                                            SvgPicture.asset("assets/icons/edit.svg",height: 20,),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  inBtwHei(height: 3),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      flexRichText("Current Amt", getRupeeFormat(vendorMaterialList[index]['CurrentReceivedAmt'])),
                                      flexRichText("Actual Amt", getRupeeFormat(vendorMaterialList[index]['OrderedAmount'])),
                                    ],
                                  ),
                                  inBtwHei(height: 3),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: (){
                                          console("bbb");
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                          margin: const EdgeInsets.only(top: 3),
                                          child: gridCardText("Expiry Date",getRupeeFormat(vendorMaterialList[index]['Price']),
                                            suffix: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const SizedBox(width: 5,),
                                                SvgPicture.asset("assets/icons/edit.svg",height: 20,),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      CupertinoSwitch(value: false, onChanged: (e){})
                                    ],
                                  ),

                                ],
                              ),
                            );
                          },
                        )),
                        Obx(() => NoData(show: vendorMaterialList.isEmpty,)),
                        const SizedBox(height: 100,)
                      ],
                    ),
                  ),

                ],
              ),
            ),

            SaveCloseBtn(
              isEdit: widget.isEdit,
              isKeyboardVisible: isKeyboardVisible,
              onSave: (){
                sysSubmit(widgets,
                    isEdit: widget.isEdit,
                    needCustomValidation: true,
                    traditionalParam: traditionalParam,
                    loader: showLoader,
                    extraParam: MyConstants.extraParam,
                    onCustomValidation: (){
                      /*if(purchaseList.isEmpty){
                        CustomAlert().cupertinoAlert("Select Material to raise Purchase...");
                        return false;
                      }
                      foundWidgetByKey(widgets, "Datajson",needSetValue: true,value: jsonEncode(purchaseList));*/

                      return true;
                    },
                    successCallback: (e){
                      console("sysSubmit $e");
                      if(widget.closeCb!=null){
                        widget.closeCb!(e);
                      }
                    }
                );
              },
            ),

            Obx(() => AnimatedContainer(
              duration: MyConstants.animeDuration,
              curve: MyConstants.animeCurve,
              width: SizeConfig.screenWidth,
              height: SizeConfig.screenHeight,
              transform:  Matrix4.translationValues(isCartOpen.value? 0:SizeConfig.screenWidth!, 0, 0),
              padding: ColorUtil.formMargin,
              decoration: const BoxDecoration(
                  color: ColorUtil.bgColor
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomTapIcon(
                            alignment:Alignment.centerLeft,
                            widget: Icon(Icons.arrow_back_rounded,color: ColorUtil.themeBlack,),
                            onTap: (){
                              selectedIndex.value=-1;
                              isCartOpen.value=false;
                            },
                          ),
                          Text("Back",style: ts20M(ColorUtil.themeBlack,fontsize: 18),),
                        ],
                      ),
                      /*FlexFittedText(
                        flex: 3,
                        text: "Recipe (${recipeParentList.length} Numbers)",
                        textStyle: ts20M(ColorUtil.themeBlack,fontsize: 18),
                      ),*/
                    ],
                  ),
                  inBtwHei(height: 15),

                ],
              ),
            )),

            Obx(() => Blur(value: numPadUtils['isNumPadOpen'] as bool,)),

            Obx(() => NumberPadPopUp(
              isSevenInch: true,
              isOpen:  numPadUtils['isNumPadOpen'] as bool,
              value:  numPadUtils['numPadVal'].toString(),
              title: numPadUtils['numPadTitle'].toString(),
              subTitle: numPadUtils['numPadSubTitle'].toString(),
              onCancel: (){
                numPadUtils['isNumPadOpen']=false;
                clearNumPadUtils();
              },
              numberTap: (e){
                numPadUtils['numPadVal']=e;
              },
              onDone: (){

              },
            )),

            Obx(() => Loader(value: showLoader.value,)),
          ],
        )
    );
  }

  @override
  void assignWidgets() async{
    widgets.clear();
    widgets['PurchaseOrderId']=HiddenController(dataname: "PurchaseOrderId");
    widgets['PurchaseOrderVendorMappingId']=SlideSearch(dataName: "PurchaseOrderVendorMappingId",
        selectedValueFunc: (e){
          console(e);
          getGoodsByVendor(e['Id']);
        },
        hinttext: "Select Vendor",data: []);

    if(!widget.isEdit){

    }
    fillTreeDrp(widgets, "PurchaseOrderVendorMappingId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "",clearValues: false,refId: jsonDecode(widget.dataJson)['PurchaseOrderId']);
    await parseJson(widgets, "",dataJson: widget.dataJson,traditionalParam: traditionalParam,extraParam: MyConstants.extraParam,loader: showLoader,
        resCb: (e){
          try{
            console("parseJson ${e['Table']}");
            poNum.value=" - ${e['Table'][0]['PurchaseOrderNumber']} ${e['Table'][0]['GRNNumber']}";
            counterList.value=e['Table1'];

          }catch(e,t){
            assignWidgetErrorToastLocal(e,t);
          }

        });
  }


  void getGoodsByVendor(vId) async{
    vendorMaterialList.clear();
    List<ParamModel> parameterList=await getParamEssential(extraParam: MyConstants.extraParam);
    parameterList.add(ParamModel(Key: "PurchaseOrderId", Type: "String", Value: widgets['PurchaseOrderId'].getValue()));
    parameterList.add(ParamModel(Key: "PurchaseOrderVendorMappingId", Type: "String", Value: vId));
    _flutterUtils.getInvoke(parameterList,loader: showLoader,url: "${GetBaseUrl()}/api/GoodsReceivedApi/GetGoodsDetailByVendorId").then((value){
      if(value[0]){
        var parsed=jsonDecode(value[1]);
        console(parsed);
        vendorMaterialList.value=parsed['Table2'];
      }
    });
  }


  void clearNumPadUtils(){
    numPadUtils['numPadVal']="";
    numPadUtils['numPadTitle']="";
    numPadUtils['numPadSubTitle']="";
    numPadUtils['vendorIndex']=-1;
    numPadUtils['productIndex']=-1;
  }

  Color getVendorStatusBgColor(id){
    if(id==1 || id==2 || id==3 || id==4){
      return Color.fromRGBO(255, 229, 232,1);
    }
    else if(id==5){
      return Color.fromRGBO(236, 247, 237,1);
    }
    else if(id==6){
      return Color.fromRGBO(254, 244, 232,1);
    }
    return Color.fromRGBO(255, 229, 232,1);
  }

  Color getVendorStatusBorderColor(id){
    if(id==1 || id==2 || id==3 || id==4){
      return Color(0xFFff0022);
    }
    else if(id==5){
      return Color(0xFF41B54A);
    }
    else if(id==6){
      return Color(0xFFF7971C);
    }
    return Color(0xFFff0022);
  }

  @override
  void dispose(){
    widgets.clear();

    clearOnDispose();
    super.dispose();
  }
}
