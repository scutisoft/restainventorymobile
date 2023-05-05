
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/mixins/extensionMixin.dart';
import 'package:flutter_utils/model/parameterModel.dart';
import 'package:flutter_utils/utils/apiUtils.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../widgets/calculation.dart';
import '../../widgets/numberPadPopUp/numberPadPopUp.dart';
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
import '/widgets/customAppBar.dart';
import '/widgets/expectedDateContainer.dart';
import '/widgets/pinWidget.dart';
import '/widgets/searchDropdown/search2.dart';
import '/utils/colorUtil.dart';
import '/utils/utilWidgets.dart';
import '/widgets/singleDatePicker.dart';
import '/widgets/swipe2/core/cell.dart';
import '/widgets/swipe2/core/controller.dart';

class DirectPurchaseForm extends StatefulWidget {
  bool isEdit;
  Function? closeCb;
  String dataJson;
  DirectPurchaseForm({Key? key,this.isEdit=false,this.closeCb,this.dataJson=""}) : super(key: key);

  @override
  State<DirectPurchaseForm> createState() => _DirectPurchaseFormState();
}

class _DirectPurchaseFormState extends State<DirectPurchaseForm> with HappyExtension implements HappyExtensionHelperCallback{

  Map widgets={};
  Map materialForm={};
  Map processedMaterialForm={};
  String page="DirectFreePurchaseOrder";
  TraditionalParam traditionalParam=TraditionalParam(
      getByIdSp: "IV_PurchaseDirectAndFreeAndProcessed_GetByIdPurchaseOrderDirectAndFreeAndProcessedDetail",
      insertSp: "IV_PurchaseDirectAndFreeAndProcessed_InsertPurchaseOrderDirectAndFreeAndProcessedDetail",
      updateSp: "IV_PurchaseDirectAndFreeAndProcessed_UpdatePurchaseOrderDirectAndFreeAndProcessedDetail"
  );
  var isKeyboardVisible=false.obs;

  UnitDropDown unitDropDown=UnitDropDown( );

  final FlutterUtils _flutterUtils=FlutterUtils();
  RxList<dynamic> purchaseList=RxList<dynamic>();
  RxList<dynamic> purchaseParentList=RxList<dynamic>();
  RxList<dynamic> purchaseInnerList=RxList<dynamic>();



  Map vendorNames={};
  List vendorIdList=[];

  var isCartOpen=false.obs;
  var needReturnQty=false.obs;

  var selectedIndex=(-1).obs;
  var selectedPurchaseType=(-1).obs;


  late SwipeActionController controller;


  var numPadUtils={
    "isNumPadOpen":false,
    "numPadVal":"",
    "numPadTitle":"",
    "numPadSubTitle":"",
    "numPadUnit":"",
    "productIndex":-1,
    "numPadType":0
  }.obs;

  @override
  void initState(){
    controller = SwipeActionController(selectedIndexPathsChangeCallback: (changedIndexPaths, selected, currentCount) {},);
    assignWidgets();
    super.initState();
  }

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
                  CustomAppBar(
                    title: "${widget.isEdit?"Update":"Add"} Direct Purchase",
                    width: SizeConfig.screenWidth!-100,
                    prefix: ArrowBack(
                      onTap: (){
                        Get.back();
                      },
                    ),
                  ),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        inBtwHei(height: 10),

                        LeftHeader(title: "Material Type"),
                        widgets['PurchaseOrderTypeId'],
                        inBtwHei(height: 20),
                        Row(
                          children: [
                            Obx(() => Visibility(visible:selectedPurchaseType.value!=-1,child: LeftHeader(title: "${widgets['PurchaseOrderTypeId'].getValueMap()['Text']}"))),
                            const Spacer(),
                            Obx(() => cartIcon(
                                onTap:(){
                                  isCartOpen.value=true;
                                },
                                count: selectedPurchaseType.value==3?purchaseParentList.length:purchaseList.length
                            )),
                            const SizedBox(width: 20,)
                          ],
                        ),
                        inBtwHei(height: 10),
                        Obx(()=>Visibility(
                          visible: selectedPurchaseType.value==1||selectedPurchaseType.value==2||selectedPurchaseType.value==4,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LeftHeader(title: "Material"),
                              materialForm['MaterialId'],
                              LeftHeader(title: "Material Brand"),
                              materialForm['MaterialBrandId'],
                              LeftHeader(title: "Material Quantity"),
                              materialForm['MaterialQty'],
                              LeftHeader(title: "Material Price"),
                              materialForm['MaterialPrice'],
                              inBtwHei(height: 30),
                              Align(
                                alignment: Alignment.center,
                                child: DoneBtn(onDone: onMaterialAdd, title: "Add"),
                              ),
                            ],
                          ),
                        )),
                        Obx(()=>Visibility(
                          visible: selectedPurchaseType.value==3,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LeftHeader(title: "Material"),
                              processedMaterialForm['MaterialId'],
                              LeftHeader(title: "Material Quantity"),
                              processedMaterialForm['MaterialQty'],
                              inBtwHei(height: 30),
                              Align(
                                alignment: Alignment.center,
                                child: DoneBtn(onDone: onProcessedMaterialAdd, title: "Add"),
                              ),
                            ],
                          ),
                        )),
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
                      if(purchaseList.isEmpty){
                        CustomAlert().cupertinoAlert("Select Material to Purchase...");
                        return false;
                      }
                      foundWidgetByKey(widgets, "PurchaseOrderMaterialMappingListJson",needSetValue: true,value: jsonEncode(purchaseList));
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

            SlidePopUp(
              isOpen: isCartOpen,
              onBack: (){
                selectedIndex.value=-1;
              },
              widgets: [
                inBtwHei(height: 15),
                const SwipeNotes(),
                Expanded(
                  child:selectedPurchaseType.value==3?Obx(() => ListView.builder(
                    shrinkWrap: true,
                    itemCount: purchaseParentList.length,
                    itemBuilder: (ctx,i){
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: SwipeActionCell(
                          controller: controller,
                          index: i,
                          key: UniqueKey(),
                          normalAnimationDuration: 500,
                          deleteAnimationDuration: 400,
                          backgroundColor: Colors.transparent,
                          swipeCallBack: (i){
                            // updateSlideItemIndex(i);
                          },
                          closeCallBack: (){
                            //updateSlideItemIndex(-1);
                          },
                          firstActionWillCoverAllSpaceOnDeleting: false,
                          trailingActions: [
                            swipeActionEdit((handler) async{
                              numPadUtils["isNumPadOpen"]=true;
                              numPadUtils["numPadVal"]=purchaseParentList[i]['RequestedQuantity'].toString();
                              numPadUtils["numPadSubTitle"]="Quantity";
                              numPadUtils["numPadUnit"]=purchaseParentList[i]['UnitName'];
                              numPadUtils["numPadType"]=2;
                              numPadUtils["numPadTitle"]=purchaseParentList[i]['MaterialName'].toString();
                              numPadUtils['productIndex']=i;
                              controller.closeAllOpenCell();
                            },needBG: true),
                            swipeActionDelete((handler) async {
                              purchaseList.removeWhere((element) => element['ParentPrimaryId']==purchaseParentList[i]['ParentPrimaryId']);
                              if(selectedIndex.value!=-1){
                                selectedIndex.value=-1;
                              }
                              purchaseParentList.removeAt(i);
                              purchaseInnerList.clear();
                              await handler(true);
                            },needBG: true),
                          ],
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap:(){
                                  if(selectedIndex.value==i){
                                    selectedIndex.value=-1;
                                    purchaseInnerList.clear();
                                  }
                                  else {
                                    selectedIndex.value=i;
                                    purchaseInnerList.value=purchaseList.where((p0) => p0['ParentId'].toString()==purchaseParentList[i]['ParentPrimaryId'].toString()).toList();
                                  }
                                  setState(() {});
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 0),
                                  padding: const EdgeInsets.fromLTRB(5, 12, 5, 12),
                                  decoration:ColorUtil.formContBoxDec,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("${purchaseParentList[i]['MaterialName']}", style: ts20M(ColorUtil.themeBlack,fontsize: 18),),
                                          ArrowAnimation(
                                            openCb: (value){
                                            },
                                            isclose: selectedIndex.value!=i,
                                          ),
                                        ],
                                      ),
                                      Visibility(
                                        visible: !checkNullEmpty(purchaseParentList[i]['MaterialBrandName']),
                                        child: Text("${purchaseParentList[i]['MaterialBrandName']}",
                                          style: ts20M(ColorUtil.red2,fontsize: 15),
                                        ),
                                      ),
                                      inBtwHei(),
                                      gridCardText("Price",getRupeeString(purchaseParentList[i]['Price'])),
                                      inBtwHei(),
                                      Row(
                                        children: [
                                          gridCardText("Qty",purchaseParentList[i]['RequestedQuantity']),
                                          Text("  ${purchaseParentList[i]['UnitName']}",style: ts20M(ColorUtil.text2,fontfamily: 'ALO',fontsize: 15),),
                                          const Spacer(),
                                          gridCardText("SubTotal",getRupeeString(purchaseParentList[i]['SubTotal'])),
                                        ],
                                      ),
                                      inBtwHei(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          gridCardText("Tax",getRupeeString(purchaseParentList[i]['TaxAmount'])),
                                          gridCardText("Total",getRupeeString(purchaseParentList[i]['TotalAmount']))
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ExpandedSection(
                                expand: selectedIndex.value==i,
                                child: ListView.builder(
                                  itemCount: purchaseInnerList.length,
                                  physics:const NeverScrollableScrollPhysics(),
                                  shrinkWrap:true,
                                  itemBuilder: (ctx1,index){
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 0),
                                      padding: const EdgeInsets.fromLTRB(5, 12, 5, 12),
                                     // decoration:ColorUtil.formContBoxDec,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("${purchaseInnerList[index]['MaterialName']}", style: ts20M(ColorUtil.themeBlack,fontsize: 18),),
                                          Visibility(
                                            visible: !checkNullEmpty(purchaseInnerList[index]['MaterialBrandName']),
                                            child: Text("${purchaseInnerList[index]['MaterialBrandName']}",
                                              style: ts20M(ColorUtil.red2,fontsize: 15),
                                            ),
                                          ),
                                          inBtwHei(),
                                          gridCardText("Price",getRupeeString(purchaseInnerList[index]['Price'])),
                                          inBtwHei(),
                                          Row(
                                            children: [
                                              gridCardText("Qty",purchaseInnerList[index]['RequestedQuantity']),
                                              Text("  ${purchaseInnerList[index]['UnitName']}",style: ts20M(ColorUtil.text2,fontfamily: 'ALO',fontsize: 15),),
                                              const Spacer(),
                                              gridCardText("SubTotal",getRupeeString(purchaseInnerList[index]['SubTotal'])),
                                            ],
                                          ),
                                          inBtwHei(),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              gridCardText("Tax",getRupeeString(purchaseInnerList[index]['TaxAmount'])),
                                              gridCardText("Total",getRupeeString(purchaseInnerList[index]['TotalAmount']))
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  )):
                  Obx(() => ListView.builder(
                    itemCount: purchaseList.length,
                    shrinkWrap:true,
                    itemBuilder: (ctx1,index){
                      return SwipeActionCell(
                        controller: controller,
                        index: index,
                        key: UniqueKey(),
                        normalAnimationDuration: 500,
                        deleteAnimationDuration: 400,
                        backgroundColor: Colors.transparent,
                        swipeCallBack: (j){ },
                        closeCallBack: (){ },
                        firstActionWillCoverAllSpaceOnDeleting: false,
                        trailingActions: [
                          swipeActionEdit((handler) async{
                            numPadUtils["isNumPadOpen"]=true;
                            numPadUtils["numPadVal"]=purchaseList[index]['Quantity'].toString();
                            numPadUtils["numPadSubTitle"]="Quantity";
                            numPadUtils["numPadUnit"]=purchaseList[index]['UnitName'];
                            numPadUtils["numPadType"]=1;
                            numPadUtils["numPadTitle"]=purchaseList[index]['MaterialName'].toString();
                            numPadUtils['productIndex']=index;
                            controller.closeAllOpenCell();
                          },needBG: true),
                          swipeActionDelete((handler,) async {
                            CustomAlert(
                                cancelCallback: (){},
                                callback: () async{
                                  purchaseList.removeAt(index);
                                  purchaseList.refresh();
                                  totalCalc();
                                  await handler(true);
                                }
                            ).yesOrNoDialog2("assets/icons/delete.svg", "Are you sure want to Delete ?", true);

                          },hasAccess: true,needBG: true),
                        ],
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0XFFffffff),
                          ),
                          //  decoration:ColorUtil.formContBoxDec,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${purchaseList[index]['MaterialName']}",
                                style: ts20M(ColorUtil.themeBlack,fontsize: 18),
                              ),
                              Visibility(
                                visible: !checkNullEmpty(purchaseList[index]['MaterialBrandName']),
                                child: Text("${purchaseList[index]['MaterialBrandName']}",
                                  style: ts20M(ColorUtil.red2,fontsize: 15),
                                ),
                              ),
                              inBtwHei(),
                              gridCardText("Price",getRupeeString(purchaseList[index]['Price'])),
                              inBtwHei(),
                              Row(
                                children: [
                                  gridCardText("Qty",purchaseList[index]['Quantity']),
                                  Text("  ${purchaseList[index]['UnitName']}",style: ts20M(ColorUtil.text2,fontfamily: 'ALO',fontsize: 15),),
                                  const Spacer(),
                                  gridCardText("SubTotal",getRupeeString(purchaseList[index]['SubTotal'])),
                                ],
                              ),
                              inBtwHei(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  gridCardText("Tax",getRupeeString(purchaseList[index]['TaxAmount'])),
                                  gridCardText("Total",getRupeeString(purchaseList[index]['TotalAmount']))
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )),
                )
              ],
            ),

            Obx(() => Blur(value: numPadUtils['isNumPadOpen'] as bool,)),

            Obx(() => NumberPadPopUp(
              isSevenInch: true,
              isOpen:  numPadUtils['isNumPadOpen'] as bool,
              value:  numPadUtils['numPadVal'].toString(),
              title: numPadUtils['numPadTitle'].toString(),
              subTitle: numPadUtils['numPadSubTitle'].toString(),
              unit: numPadUtils['numPadUnit'].toString(),
              onCancel: (){
                numPadUtils['isNumPadOpen']=false;
                clearNumPadUtils();
              },
              numberTap: (e){
                numPadUtils['numPadVal']=e;
              },
              onDone: (){
                if(numPadUtils['numPadType'] as int ==1){
                  onProductQtyUpdate();
                }
                else{
                  onProcessedMaterialUpdate();
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
    unitDropDown.onChange=(e){
      onUnitDrpChange();
    };
    widgets.clear();
    widgets['PurchaseOrderId']=HiddenController(dataname: "PurchaseOrderId");
    widgets['PurchaseOrderMaterialMappingListJson']=HiddenController(dataname: "PurchaseOrderMaterialMappingListJson");
    widgets['PurchaseOrderTypeId']=SlideSearch(dataName: "PurchaseOrderTypeId",selectedValueFunc: (e){ selectedPurchaseType.value=e['Id'];purchaseTypeChg(e['Id']); }, hinttext: "Select Material Type",data: []);

    //materialForm['DepartmentId']=SlideSearch(dataName: "DepartmentId",selectedValueFunc: (e){ }, hinttext: "Select Department",data: []);
    materialForm['MaterialId']=SlideSearch(dataName: "MaterialId",selectedValueFunc:onMaterialChange,hinttext: "Select Material",data: [],propertyId: "MaterialId",propertyName: "MaterialName",);
    materialForm['MaterialBrandId']=SlideSearch(dataName: "MaterialBrandId",required: false,selectedValueFunc: (e){updateMPrice(e);}, hinttext: "Select Material Brand",data: [],propertyName: "value",);
    materialForm['MaterialQty']=AddNewLabelTextField(
      dataname: 'MaterialQty',
      hasInput: true,
      required: true,
      labelText: "Material Quantity",
      scrollPadding: 150,
      regExp: MyConstants.decimalReg,
      textInputType: TextInputType.number,
      onChange: (v){},
      onEditComplete: (){
        FocusScope.of(context).unfocus();
      },
      suffixIcon:unitDropDown,
      textLength: MyConstants.maximumQty,
    );
    materialForm['MaterialPrice']=AddNewLabelTextField(
      dataname: 'MaterialPrice',
      hasInput: true,
      required: true,
      labelText: "Material Price",
      scrollPadding: 150,
      regExp: MyConstants.decimalReg,
      textInputType: TextInputType.number,
      onChange: (v){},
      onEditComplete: (){
        FocusScope.of(context).unfocus();
      },
      textLength: MyConstants.maximumQty,
    );
    materialForm['Price']=HiddenController(dataname: "Price");

    processedMaterialForm['MaterialId']=SlideSearch(dataName: "MaterialId",selectedValueFunc:onProcessedMaterialChange,hinttext: "Select Material",data: [],propertyId: "MaterialId",propertyName: "MaterialName",);
    processedMaterialForm['MaterialQty']=AddNewLabelTextField(
      dataname: 'MaterialQty',
      hasInput: true,
      required: true,
      labelText: "Material Quantity",
      scrollPadding: 150,
      regExp: MyConstants.decimalReg,
      textInputType: TextInputType.number,
      onChange: (v){},
      onEditComplete: (){
        FocusScope.of(context).unfocus();
      },
      suffixIcon:unitDropDown,
      textLength: MyConstants.maximumQty,
    );
    if(!widget.isEdit){
      needReturnQty.value=false;
    }
    else{
      needReturnQty.value=true;
    }

    fillTreeDrp(widgets, "PurchaseOrderTypeId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "",clearValues: false);


    await parseJson(widgets, "",dataJson: widget.dataJson,traditionalParam: traditionalParam,extraParam: MyConstants.extraParam,loader: showLoader,
        resCb: (e){
          try{
            console("parseJson $e");
          /* if(!checkNullEmpty(e['Table'][0]['OutPutJson'])){
              purchaseList.value=jsonDecode(e['Table'][0]['OutPutJson']);
            }*/
          }catch(e,t){
            assignWidgetErrorToastLocal(e,t);
          }
        });

  }

  void purchaseTypeChg(type){
    purchaseList.clear();
    purchaseInnerList.clear();
    purchaseParentList.clear();
    if (type == 1 || type == 2 || type == 4) {
      unitDropDown.isEnabled.value=true;
      fillTreeDrp(materialForm, "MaterialId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam, refType: "MaterialId",refId: type);
    }
    else if (type == 3) {
      unitDropDown.isEnabled.value=false;
      fillTreeDrp(processedMaterialForm, "MaterialId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam, refType: "MaterialId",refId: type);
    }
    else {

    }
  }

  void onMaterialChange(e){
    console(e);
    unitDropDown.clearValues();
    if(!checkNullEmpty(e['UnitId'])){
      unitDropDown.setValue(getUnitIdNameList(e['UnitId'], e['UnitName'],value: e['UnitQuantityType']));
      if(unitDropDown.unitList.isNotEmpty){
        unitDropDown.setValue(unitDropDown.unitList[0]);
      }
    }
    updateMPrice(e);
    fillTreeDrp(materialForm, "MaterialBrandId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refId: e['MaterialId'],toggleRequired: true,needToDisable: true);
  }

  void updateMPrice(e){
    double mPrice=parseDouble(e['MaterialPrice']);
    foundWidgetByKey(materialForm, "Price",needSetValue: true,value: mPrice>0?mPrice:"");
    onUnitDrpChange();
  }

  void onUnitDrpChange(){
    double price=getUnitTypePrice(parseDouble(materialForm['Price'].getValue()), unitDropDown.selectedUnit.value['Value']);
    foundWidgetByKey(materialForm, "MaterialPrice",needSetValue: true,value: price>0?price:"");
  }

  void onMaterialAdd() async{
    List<ParamModel> a=await getFrmCollection(materialForm);
    if(a.isNotEmpty){
      FocusScope.of(context).unfocus();

      Map mDrp=materialForm['MaterialId'].getValueMap();
      Map mbDrp=materialForm['MaterialBrandId'].getValueMap();
      var brandId=mbDrp.isEmpty?null:mbDrp['Id'];

      console(mDrp);
      console(mbDrp);
      int existsProductIndex=purchaseList.indexWhere((element) => element['MaterialId']==mDrp['MaterialId'] && element['MaterialBrandId']==brandId);
      if(existsProductIndex==-1){
        var pObj = {
          "PurchaseOrderMaterialMappingId": null,
          "PurchaseOrderId": null,
          "MaterialId": mDrp['MaterialId'],
          "MaterialName": mDrp['MaterialName'],
          "MaterialBrandId": brandId,
          "MaterialBrandName": brandId!=null ? mbDrp['value'] : "",
          "UnitId": unitDropDown.selectedUnit.value['Id'],
          "UnitName": unitDropDown.selectedUnit.value['Text'],
          "Price": parseDouble(materialForm['MaterialPrice'].getValue()),
          "Quantity": parseDouble(materialForm['MaterialQty'].getValue()),
          "IsPercentage": false,
          "DiscountValue": 0.0000,
          "DiscountAmount": 0.0000,
          "TaxId": mDrp['InventoryTaxId'],
          "TaxValue": parseDouble(mDrp['InventoryTaxValue']),
          "TaxAmount": 0.0000,
          "TotalAmount": 0.0000,
          "SubTotal": 0.0000,
          "DiscountedSubTotal": 0.0000,
        };
        purchaseList.add(pObj);
        clearAllV2(materialForm);
        totalCalc();
      }
      else{
        CustomAlert().cupertinoAlert("Material Already Exits");
      }
    }
  }

  void onProductQtyUpdate(){
    double qty=parseDouble(numPadUtils['numPadVal']);
    if(numPadUtils['productIndex']!=-1){
      if(qty<=0){
        CustomAlert().cupertinoAlert("Enter Quantity...");
        return;
      }
      purchaseList[numPadUtils['productIndex'] as int]['Quantity']=qty;
      purchaseList.refresh();
      totalCalc();
    }
    numPadUtils['isNumPadOpen']=false;
    clearNumPadUtils();
  }


  void onProcessedMaterialChange(e){
    unitDropDown.clearValues();
    if(!checkNullEmpty(e['UnitId'])){
      unitDropDown.setValue(getUnitIdNameList(e['UnitId'], e['UnitName'],value: e['UnitQuantityType']));
      if(unitDropDown.unitList.isNotEmpty){
        unitDropDown.setValue(unitDropDown.unitList[0]);
      }
    }
  }

  void onProcessedMaterialAdd() async{
    List<ParamModel> a=await getFrmCollection(processedMaterialForm);
    if(a.isNotEmpty){
      FocusScope.of(context).unfocus();
      Map mDrp=processedMaterialForm['MaterialId'].getValueMap();
      int existIndex=purchaseList.indexWhere((element) => element['MaterialId']==mDrp['MaterialId']);
      if(existIndex==-1){
        List<ParamModel> parameterList=await getParamEssential(extraParam: MyConstants.extraParam);
        parameterList.add(ParamModel(Key: "MaterialId", Type: "String", Value: mDrp['MaterialId']));
        parameterList.add(ParamModel(Key: "RequestedQty", Type: "String", Value: parseDouble(processedMaterialForm['MaterialQty'].getValue())));
        parameterList.add(ParamModel(Key: "UnitId", Type: "String", Value: unitDropDown.selectedUnit.value['Id']));
        _flutterUtils.getInvoke(parameterList,loader: showLoader,url: "${GetBaseUrl()}/api/DirectPurchaseApi/GetProcessMaterialDetail").then((value){
          if(value[0]){
            var parsed=jsonDecode(value[1]);
            List<dynamic> recipeList=parsed['Table'];
            console(parsed);
            purchaseList.addAll(recipeList);
            purchaseParentList.add(recipeList.where((element) => element['ParentId'].toString()=="0").toList()[0]);
            clearAllV2(processedMaterialForm);
          }
          else{
            CustomAlert().cupertinoAlert(value[1]);
          }
        });
      }
      else{
        CustomAlert().cupertinoAlert("Material Already Exits");
      }
    }
  }

  void onProcessedMaterialUpdate() async{
    purchaseInnerList.clear();
    selectedIndex.value=-1;
    double qty=parseDouble(numPadUtils['numPadVal']);
    int pIndex=numPadUtils['productIndex'] as int;
    if(pIndex!=-1){
      if(qty<=0){
        CustomAlert().cupertinoAlert("Enter Quantity...");
        return;
      }
      List<ParamModel> parameterList=await getParamEssential(extraParam: MyConstants.extraParam);
      parameterList.add(ParamModel(Key: "MaterialId", Type: "String", Value: purchaseParentList[pIndex]['MaterialId']));
      parameterList.add(ParamModel(Key: "RequestedQty", Type: "String", Value: qty));
      parameterList.add(ParamModel(Key: "UnitId", Type: "String", Value: purchaseParentList[pIndex]['UnitId']));
      _flutterUtils.getInvoke(parameterList,loader: showLoader,url: "${GetBaseUrl()}/api/DirectPurchaseApi/GetProcessMaterialDetail").then((value){
        if(value[0]){
          var parsed=jsonDecode(value[1]);
          List<dynamic> recipeList=parsed['Table'];
          console(parsed);
          purchaseList.removeWhere((element) => element['ParentPrimaryId']==purchaseParentList[pIndex]['ParentPrimaryId']);
          purchaseList.addAll(recipeList);
          purchaseParentList[pIndex]=recipeList.where((element) => element['ParentId'].toString()=="0").toList()[0];

        }
        else{
          CustomAlert().cupertinoAlert(value[1]);
        }
      });
    }
    numPadUtils['isNumPadOpen']=false;
    clearNumPadUtils();
  }

  void totalCalc(){
    double sT=0.0,tax=0.0,tA=0.0;
    for (var pd in purchaseList) {
      double psT=0.0,ptax=0.0,ptA=0.0,pTV=0.0;
      psT=Calculation().mul(pd['Quantity'], pd['Price']);
      pTV=Calculation().div(pd['TaxValue'], 100);
      ptax=Calculation().mul(psT, pTV);
      ptA=Calculation().add(psT, ptax);

      pd['SubTotal']=psT;
      pd['TaxAmount']=ptax;
      pd['TotalAmount']=ptA;

      sT=Calculation().add(sT, psT);
      tax=Calculation().add(tax, ptax);
      tA=Calculation().add(tA, ptA);
    }
  }

  void productCalc(e){
    double sT=0.0,tax=0.0,tA=0.0;
    e['PMD'].forEach((pd){
      double psT=0.0,ptax=0.0,ptA=0.0,pTV=0.0;
      psT=Calculation().mul(pd['Quantity'], pd['Price']);
      pTV=Calculation().div(pd['TaxValue'], 100);
      ptax=Calculation().mul(psT, pTV);
      ptA=Calculation().add(psT, ptax);

      pd['SubTotal']=psT;
      pd['TaxAmount']=ptax;
      pd['TotalAmount']=ptA;

      sT=Calculation().add(sT, psT);
      tax=Calculation().add(tax, ptax);
      tA=Calculation().add(tA, ptA);
    });
    e['SubTotal']=sT;
    e['TaxAmount']=tax;
    e['GrandTotalAmount']=tA;
  }

  void clearNumPadUtils(){
    numPadUtils['numPadVal']="";
    numPadUtils['numPadTitle']="";
    numPadUtils['numPadSubTitle']="";
    numPadUtils['numPadUnit']="";
    numPadUtils['departmentIndex']=-1;
    numPadUtils['productIndex']=-1;
    numPadUtils['numPadType']=0;
  }

  @override
  void dispose(){
    widgets.clear();
    materialForm.clear();
    processedMaterialForm.clear();
    purchaseList.clear();
    purchaseParentList.clear();
    clearOnDispose();
    super.dispose();
  }
}
