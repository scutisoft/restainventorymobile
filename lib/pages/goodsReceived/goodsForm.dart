
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/mixins/extensionMixin.dart';
import 'package:flutter_utils/model/parameterModel.dart';
import 'package:flutter_utils/utils/apiUtils.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../widgets/customCheckBox.dart';
import '../../widgets/numberPadPopUp/numberPadPopUp.dart';
import '/widgets/calculation.dart';
import '/widgets/loader.dart';
import '/api/apiUtils.dart';
import '/api/sp.dart';
import '/utils/constants.dart';
import '/utils/sizeLocal.dart';
import '/utils/utils.dart';
import '/widgets/alertDialog.dart';
import '/widgets/customAppBar.dart';
import '/widgets/searchDropdown/search2.dart';
import '/utils/colorUtil.dart';
import '/utils/utilWidgets.dart';
import '/widgets/singleDatePicker.dart';
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
  RxList<dynamic> otherChargesList=RxList<dynamic>();

  var isCartOpen=false.obs;
  var selectedIndex=(-1).obs;
  var sameAsActualQty=false.obs;

  late SwipeActionController controller;
  final FlutterUtils _flutterUtils=FlutterUtils();

  var numPadUtils={
    "isNumPadOpen":false,
    "numPadVal":"",
    "numPadTitle":"",
    "numPadSubTitle":"",
    "numPadType":0,
    "productIndex":-1
  }.obs;

  bool needReload=false;

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
                        chkReload();
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
                        Obx(() => CustomCheckBox(
                          isSelect: sameAsActualQty.value,
                          content:"Same As Actual Quantity",
                          margin: const EdgeInsets.fromLTRB(15, 10, 0,10),
                          ontap: (){
                            sameAsActualQty.value=!sameAsActualQty.value;
                            onChkBoxChg();
                          },
                          selectColor: ColorUtil.red2,
                        )),
                        inBtwHei(height: 10),
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
                                  gridCardText("Total Received",vendorMaterialList[index]['TotalReceivedQty'],
                                    suffix: Text("  ${vendorMaterialList[index]['UnitName']}",style: ts20M(ColorUtil.text2,fontfamily: 'ALO',fontsize: 15),),
                                  ),
                                  GestureDetector(
                                    onTap: (){
                                      console("aaa ${vendorMaterialList[index]}");
                                      numPadUtils.value={
                                        "isNumPadOpen":true,
                                        "numPadVal":getQtyString(vendorMaterialList[index]['CurrentReceivedQty']),
                                        "numPadTitle":vendorMaterialList[index]['MaterialName'],
                                        "numPadSubTitle":"Current Received Qty",
                                        "numPadType":1,
                                        "productIndex":index
                                      };
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      margin: const EdgeInsets.only(top: 3),
                                      child: gridCardText("Current Received Qty",vendorMaterialList[index]['CurrentReceivedQty'],
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
                                      numPadUtils.value={
                                        "isNumPadOpen":true,
                                        "numPadVal":getQtyString(vendorMaterialList[index]['Price']),
                                        "numPadTitle":"${vendorMaterialList[index]['MaterialName']}",
                                        "numPadSubTitle":"Bill Price Per Qty",
                                        "numPadType":2,
                                        "productIndex":index
                                      };
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
                                        onTap: () async{
                                          final DateTime? picked = await showDatePicker2(
                                              context: context,
                                              initialDate:  vendorMaterialList[index]['ExpiryDate']==null?DateTime.now():DateTime.parse(vendorMaterialList[index]['ExpiryDate']), // Refer step 1
                                              firstDate: DateTime.now(),
                                              lastDate: DateTime(2050),
                                              builder: (BuildContext context,Widget? child){
                                                return Theme(
                                                  data: Theme.of(context).copyWith(
                                                    colorScheme: ColorScheme.light(
                                                      primary: ColorUtil.primary, // header background color
                                                      onPrimary: ColorUtil.themeWhite, // header text color
                                                      onSurface: ColorUtil.themeBlack, // body text color
                                                    ),
                                                    // textTheme: TextTheme(bodySmall: TextStyle(fontFamily: 'AM',color: Colors.red))
                                                  ),
                                                  child: child!,
                                                );
                                              });
                                          if (picked != null) {
                                            vendorMaterialList[index]['ExpiryDate']=DateFormat(MyConstants.dbDateFormat).format(picked);
                                            vendorMaterialList.refresh();
                                          }
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                          margin: const EdgeInsets.only(top: 3),
                                          child: gridCardText("Expiry Date","",
                                            suffix: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text("  ${vendorMaterialList[index]['ExpiryDate']??"yyyy-MM-dd"}",style: ts20M(ColorUtil.themeBlack,fontfamily: 'AM',fontsize: 15),),
                                                const SizedBox(width: 5,),
                                                SvgPicture.asset("assets/icons/edit.svg",height: 20,),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      CupertinoSwitch(value: vendorMaterialList[index]['InventoryStatusId'], onChanged: (e){
                                        vendorMaterialList[index]['InventoryStatusId']=e;
                                        vendorMaterialList.refresh();
                                      })
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
                    clearFrm: false,
                    closeFrmOnSubmit: false,
                    onCustomValidation: (){
                      if(vendorMaterialList.isEmpty){
                        CustomAlert().cupertinoAlert("Select Vendor to Update...");
                        return false;
                      }
                      chkInventoryStatus();
                      for(var pd in vendorMaterialList){
                        double cQty=parseDouble(pd['CurrentReceivedQty']);
                        double price=parseDouble(pd['Price']);
                        if(cQty>0){
                          if(price<=0){
                            CustomAlert().cupertinoAlert("One of your Material Price is Empty. Enter Material Price ...");
                            return false;
                          }
                        }
                      }
                      foundWidgetByKey(widgets, "PurchaseVendorMaterialTransactionJson",needSetValue: true,value: jsonEncode(vendorMaterialList));
                      foundWidgetByKey(widgets, "PurchaseOtherChargesListJson",needSetValue: true,value: jsonEncode(otherChargesList));

                      return true;
                    },
                    successCallback: (e){
                      console("sysSubmit $e");
                      needReload=true;
                      getGoodsByVendor(widgets['PurchaseOrderVendorMappingId'].getValue());

                    }
                );
              },
              onClose: (){
                chkReload();
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
                if(numPadUtils['numPadType']==1){
                  onCurrentReceivedQtyChange();
                }
                else if(numPadUtils['numPadType']==2){
                  onBillPriceChange();
                }
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
    widgets['PurchaseOtherChargesListJson']=HiddenController(dataname: "PurchaseOtherChargesListJson");
    widgets['PurchaseVendorMaterialTransactionJson']=HiddenController(dataname: "PurchaseVendorMaterialTransactionJson");
    widgets['PurchaseOrderVendorMappingId']=SlideSearch(dataName: "PurchaseOrderVendorMappingId",selectedValueFunc: (e){  console(e);  getGoodsByVendor(e['Id']); },hinttext: "Select Vendor",data: []);

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

  void chkReload(){
    if(needReload && widget.closeCb!=null){
      widget.closeCb!("A");
    }
  }

  void getGoodsByVendor(vId) async{
    sameAsActualQty.value=false;
    vendorMaterialList.clear();
    List<ParamModel> parameterList=await getParamEssential(extraParam: MyConstants.extraParam);
    parameterList.add(ParamModel(Key: "PurchaseOrderId", Type: "String", Value: widgets['PurchaseOrderId'].getValue()));
    parameterList.add(ParamModel(Key: "PurchaseOrderVendorMappingId", Type: "String", Value: vId));
    _flutterUtils.getInvoke(parameterList,loader: showLoader,url: "${GetBaseUrl()}/api/GoodsReceivedApi/GetGoodsDetailByVendorId").then((value){
      if(value[0]){
        var parsed=jsonDecode(value[1]);
        //console(parsed);
        vendorMaterialList.value=parsed['Table2'];
      }
    });
  }

  void onCurrentReceivedQtyChange(){
    double crQty=parseDouble(numPadUtils['numPadVal']);
    int index=numPadUtils['productIndex']as int;
    if(index>=0){
      double needToRec=Calculation().sub(vendorMaterialList[index]['OrderedQty'], vendorMaterialList[index]['TotalReceivedQty']);
      if(crQty>needToRec){
        CustomAlert().cupertinoAlert("Received Quantity should be less than Remaining Quantity ($needToRec)");
        return;
      }
      vendorMaterialList[index]['CurrentReceivedQty'] = crQty;
      productCalc(index);
      numPadUtils['isNumPadOpen']=false;
      clearNumPadUtils();
    }
  }

  void onBillPriceChange(){
    double price=parseDouble(numPadUtils['numPadVal']);
    int index=numPadUtils['productIndex']as int;
    if(index>=0){
      if(price<=0){
        CustomAlert().cupertinoAlert("Price should not be empty");
        return;
      }
      vendorMaterialList[index]['Price'] = price;
      productCalc(index);
      numPadUtils['isNumPadOpen']=false;
      clearNumPadUtils();
    }
  }

  void productCalc(index){

    double psT=0.0,ptax=0.0,ptA=0.0,pTV=0.0;
    psT=Calculation().mul(vendorMaterialList[index]['CurrentReceivedQty'], vendorMaterialList[index]['Price']);
    pTV=Calculation().div(vendorMaterialList[index]['TaxValue'], 100);
    ptax=Calculation().mul(psT, pTV);
    ptA=Calculation().add(psT, ptax);

    vendorMaterialList[index]['CurrentReceivedAmt'] = ptA;
    vendorMaterialList[index]['InventoryStatusId'] = parseDouble(vendorMaterialList[index]['OrderedQty'])==Calculation().add(vendorMaterialList[index]['CurrentReceivedQty'], vendorMaterialList[index]['TotalReceivedQty']);
    vendorMaterialList.refresh();
  }

  void chkInventoryStatus(){
    for(var pd in vendorMaterialList){
      pd['InventoryStatusId'] = parseDouble(pd['OrderedQty'])==Calculation().add(parseDouble(pd['CurrentReceivedQty']), parseDouble(pd['TotalReceivedQty']));
    }
    vendorMaterialList.refresh();
  }

  void onChkBoxChg(){
    int i=0;
    for (var md in vendorMaterialList) {
      if(sameAsActualQty.value){
        double needToRec=Calculation().sub(md['OrderedQty'], md['TotalReceivedQty']);
        if(needToRec>0){
          md['CurrentReceivedQty']=needToRec;
        }
      }
      else{
        md['CurrentReceivedQty']=0.0;
      }
      productCalc(i);
      i++;
    }
    vendorMaterialList.refresh();
  }

  void clearNumPadUtils(){
    numPadUtils['numPadVal']="";
    numPadUtils['numPadTitle']="";
    numPadUtils['numPadSubTitle']="";
    numPadUtils['productIndex']=-1;
    numPadUtils['numPadType']=0;
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
