
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/model/parameterModel.dart';
import 'package:flutter_utils/utils/apiUtils.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../widgets/customCheckBox.dart';
import '../../widgets/fittedText.dart';
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

class DepartmentDistributionForm extends StatefulWidget {
  bool isEdit;
  Function? closeCb;
  String dataJson;
  DepartmentDistributionForm({Key? key,this.isEdit=false,this.closeCb,this.dataJson=""}) : super(key: key);

  @override
  State<DepartmentDistributionForm> createState() => _DepartmentDistributionFormState();
}

class _DepartmentDistributionFormState extends State<DepartmentDistributionForm> with HappyExtension implements HappyExtensionHelperCallback{

  Map widgets={};
  Map materialForm={};
  String page="DepartmentDistributionDetail";
  TraditionalParam traditionalParam=TraditionalParam(
      getByIdSp: "IV_DepartmentDistribution_GetByDepartmentDistributionDepartmentIdDetail",
      insertSp: "IV_DepartmentDistribution_InsertDepartmentDistributionDetail",
      updateSp: "IV_DepartmentDistribution_UpdateDepartmentDistributionDetail"
  );
  var isKeyboardVisible=false.obs;

  Rxn<DateTime> expectedDate=Rxn<DateTime>();
  var unitName="Unit".obs;
  var batchNo="".obs;

  UnitDropDown unitDropDown=UnitDropDown();


  RxList<dynamic> purchaseList=RxList<dynamic>();
  RxList<dynamic> indentMappingList=RxList<dynamic>();


  Map vendorNames={};
  List vendorIdList=[];

  var isCartOpen=false.obs;
  var needReturnQty=false.obs;

  var selectedIndex=(-1).obs;


  late SwipeActionController controller;


  var numPadUtils={
    "isNumPadOpen":false,
    "numPadVal":"",
    "numPadTitle":"",
    "numPadSubTitle":"",
    "departmentIndex":-1,
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
                  Obx(() => CustomAppBar(
                    title: "${widget.isEdit?"Update":"Add"} Department Distribution ${batchNo.value}",
                    width: SizeConfig.screenWidth!-100,
                    prefix: ArrowBack(
                      onTap: (){
                        Get.back();
                      },
                    ),
                  )),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        inBtwHei(height: 10),
                        LeftHeader(title: "Date"),
                        GestureDetector(
                            onTap: () async{
                              final DateTime? picked = await showDatePicker2(
                                  context: context,
                                  initialDate:  expectedDate.value==null?DateTime.now():expectedDate.value!, // Refer step 1
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
                                expectedDate.value=picked;
                              }
                            },
                            child: Obx(() =>  ExpectedDateContainer(
                              text: expectedDate.value ==null?"Select Date": "${DateFormat.yMMMd().format(expectedDate.value!)}",
                            ))
                        ),
                        LeftHeader(title: "Notes"),
                        widgets['Notes'],
                        inBtwHei(height: 20),
                        Row(
                          children: [
                            LeftHeader(title: "+ Add Material"),
                            const Spacer(),
                            Obx(() => cartIcon(
                                onTap:(){
                                  isCartOpen.value=true;
                                },
                                count: purchaseList.length
                            )),
                            const SizedBox(width: 20,)
                          ],
                        ),
                        LeftHeader(title: "Department"),
                        materialForm['DepartmentId'],
                        LeftHeader(title: "Material"),
                        materialForm['MaterialId'],
                        LeftHeader(title: "Material Brand"),
                        materialForm['MaterialBrandId'],
                        LeftHeader(title: "Material Quantity"),
                        materialForm['MaterialQty'],
                        inBtwHei(height: 30),
                        Align(
                          alignment: Alignment.center,
                          child: DoneBtn(onDone: onMaterialAdd, title: "Add"),
                        ),
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
                        CustomAlert().cupertinoAlert("Select Material to Distribute...");
                        return false;
                      }
                      foundWidgetByKey(widgets, "DepartmentDistributionMaterialJson",needSetValue: true,value: jsonEncode(purchaseList));
                      foundWidgetByKey(widgets, "DepartmentDistributionDate",needSetValue: true,value: DateFormat(MyConstants.dbDateFormat).format(expectedDate.value!));
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
                  child: Obx(() => ListView.builder(
                    shrinkWrap: true,
                    itemCount: purchaseList.length,
                    itemBuilder: (ctx,i){
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap:(){
                                if(selectedIndex.value==i){
                                  selectedIndex.value=-1;
                                }
                                else {
                                  selectedIndex.value=i;
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10,left: 0,right: 0),
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
                                        children: [
                                          Text("${purchaseList[i]['DepartmentName']}",style: ts20M(ColorUtil.red),),
                                          inBtwHei(),
                                          gridCardText("Materials",(purchaseList[i]['MaterialList'].length)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [

                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            GridDeleteIcon(
                                              hasAccess: purchaseList[i]['IsDelete']??false,
                                              onTap: (){
                                                CustomAlert(
                                                    cancelCallback: (){},
                                                    callback: (){
                                                      purchaseList.removeAt(i);
                                                    }
                                                ).yesOrNoDialog2("assets/icons/delete.svg", "Are you sure want to Delete ?", true);
                                              },
                                            ),
                                            const SizedBox(width: 5,),
                                            Obx(() => ArrowAnimation(
                                              openCb: (value){
                                              },
                                              isclose: selectedIndex.value!=i,
                                            ),)
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Obx(() => ExpandedSection(
                              expand: selectedIndex.value==i,
                              child: ListView.builder(
                                itemCount: purchaseList[i]['MaterialList'].length,
                                physics:const NeverScrollableScrollPhysics(),
                                shrinkWrap:true,
                                itemBuilder: (ctx1,index){
                                  return SwipeActionCell(
                                    controller: controller,
                                    index: i,
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
                                        if(needReturnQty.value){
                                          numPadUtils["numPadVal"]=purchaseList[i]['MaterialList'][index]['ReturnQuantity'].toString();
                                          numPadUtils["numPadSubTitle"]="Return Quantity";
                                          numPadUtils["numPadType"]=2;
                                        }
                                        else{
                                          numPadUtils["numPadVal"]=purchaseList[i]['MaterialList'][index]['Quantity'].toString();
                                          numPadUtils["numPadSubTitle"]="Quantity";
                                          numPadUtils["numPadType"]=1;
                                        }

                                        numPadUtils["numPadTitle"]=purchaseList[i]['MaterialList'][index]['MaterialName'].toString();
                                        numPadUtils['departmentIndex']=i;
                                        numPadUtils['productIndex']=index;
                                        controller.closeAllOpenCell();
                                      },needBG: true),
                                      swipeActionDelete((handler,) async {
                                        if(purchaseList[i]['MaterialList'][index]['IsDelete']??false){
                                          CustomAlert(
                                              cancelCallback: (){},
                                              callback: () async{
                                                purchaseList[i]['MaterialList'].removeAt(index);
                                                if( purchaseList[i]['MaterialList'].length==0){
                                                  selectedIndex.value=-1;
                                                  purchaseList.removeAt(i);
                                                }
                                                purchaseList.refresh();
                                                await handler(true);
                                              }
                                          ).yesOrNoDialog2("assets/icons/delete.svg", "Are you sure want to Delete ?", true);
                                        }

                                      },hasAccess: purchaseList[i]['MaterialList'][index]['IsDelete']??false,needBG: true),
                                    ],
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 7,right: 7),
                                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(color: ColorUtil.greyBorder)
                                          )
                                      ),
                                      //  decoration:ColorUtil.formContBoxDec,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("${purchaseList[i]['MaterialList'][index]['MaterialName']}",
                                            style: ts20M(ColorUtil.themeBlack,fontsize: 18),
                                          ),
                                          Visibility(
                                            visible: purchaseList[i]['MaterialList'][index]['MaterialBrandName'].toString().isNotEmpty,
                                            child: Text("${purchaseList[i]['MaterialList'][index]['MaterialBrandName']}",
                                              style: ts20M(ColorUtil.red2,fontsize: 15),
                                            ),
                                          ),
                                          inBtwHei(),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              gridCardText("Qty",purchaseList[i]['MaterialList'][index]['Quantity']),
                                              Text("  ${purchaseList[i]['MaterialList'][index]['PrimaryUnitName']}",style: ts20M(ColorUtil.text2,fontfamily: 'ALO',fontsize: 15),),
                                              const Spacer(),
                                              gridCardText("Return Qty",purchaseList[i]['MaterialList'][index]['ReturnQuantity']??0),
                                              Text("  ${purchaseList[i]['MaterialList'][index]['PrimaryUnitName']}",style: ts20M(ColorUtil.text2,fontfamily: 'ALO',fontsize: 15),),
                                            ],
                                          ),
                                          inBtwHei(),
                                          /*Row(
                                            children: [
                                              gridCardText("Qty",purchaseList[i]['MaterialList'][index]['Quantity']),
                                              Text("  ${purchaseList[i]['MaterialList'][index]['UnitName']}",style: ts20M(ColorUtil.text2,fontfamily: 'ALO',fontsize: 15),),
                                              const Spacer(),
                                              gridCardText("SubTotal",getRupeeString(purchaseList[i]['MaterialList'][index]['SubTotal'])),
                                            ],
                                          ),
                                          inBtwHei(),*/



                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ))
                          ],
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
              onCancel: (){
                numPadUtils['isNumPadOpen']=false;
                clearNumPadUtils();
              },
              numberTap: (e){
                numPadUtils['numPadVal']=e;
              },
              onDone: (){
                onProductQtyUpdate();
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
      unitName.value=e['Text'];
    };
    widgets.clear();
    widgets['DepartmentDistributionId']=HiddenController(dataname: "DepartmentDistributionId");
    widgets['DepartmentDistributionDate']=HiddenController(dataname: "DepartmentDistributionDate");
    widgets['DepartmentDistributionMaterialJson']=HiddenController(dataname: "DepartmentDistributionMaterialJson");
    widgets['Notes']=AddNewLabelTextField(
      dataname: 'Notes',
      hasInput: true,
      required: false,
      labelText: "Notes",
      regExp: null,
      onChange: (v){},
      onEditComplete: (){
        FocusScope.of(context).unfocus();
      },
      maxlines: null,
    );

    materialForm['DepartmentId']=SlideSearch(dataName: "DepartmentId",selectedValueFunc: (e){ }, hinttext: "Select Department",data: []);
    materialForm['MaterialId']=SlideSearch(dataName: "MaterialId",selectedValueFunc:onMaterialChange,hinttext: "Select Material",data: []);
    materialForm['MaterialBrandId']=SlideSearch(dataName: "MaterialBrandId",required: false,selectedValueFunc: (e){}, hinttext: "Select Material Brand",data: [],propertyName: "value",);
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

    if(!widget.isEdit){
      expectedDate.value=DateTime.now();
      needReturnQty.value=false;
    }
    else{
      needReturnQty.value=true;
    }

    fillTreeDrp(materialForm, "DepartmentId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "",clearValues: false);
    fillTreeDrp(materialForm, "MaterialId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam, refType: "MaterialId",refId: "");

    await parseJson(widgets, "",dataJson: widget.dataJson,traditionalParam: traditionalParam,extraParam: MyConstants.extraParam,loader: showLoader,
        resCb: (e){
          try{
            console("parseJson $e");
            batchNo.value=" - ${e['Table'][0]['BatchNumber']}";
            expectedDate.value=checkNullEmpty(e['Table'][0]['DepartmentDistributionDate'])?DateTime.now():DateTime.parse(e['Table'][0]['DepartmentDistributionDate']);
            if(!checkNullEmpty(e['Table'][0]['OutPutJson'])){
              purchaseList.value=jsonDecode(e['Table'][0]['OutPutJson']);
            }
          }catch(e,t){
            assignWidgetErrorToastLocal(e,t);
          }
        });

  }

  void onMaterialChange(e){
    unitDropDown.clearValues();
    if(!checkNullEmpty(e['UnitId'])){
      unitDropDown.setValue(getUnitIdNameList(e['UnitId'], e['UnitName']));
      if(unitDropDown.unitList.isNotEmpty){
        unitDropDown.setValue(unitDropDown.unitList[0]);
        unitName.value= unitDropDown.selectedUnit.value['Text'];
      }
    }
    fillTreeDrp(materialForm, "MaterialBrandId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refId: e['Id'],toggleRequired: true,needToDisable: true);
  }

  void onMaterialAdd() async{
    List<ParamModel> a=await getFrmCollection(materialForm);
    if(a.isNotEmpty){
      FocusScope.of(context).unfocus();
      Map vDrp=materialForm['DepartmentId'].getValueMap();
      Map mDrp=materialForm['MaterialId'].getValueMap();
      Map mbDrp=materialForm['MaterialBrandId'].getValueMap();
      var brandId=mbDrp.isEmpty?null:mbDrp['Id'];
      console(vDrp);
      console(mDrp);
      console(mbDrp);
      int existsVendorIndex=purchaseList.indexWhere((element) => element['DepartmentId']==vDrp['Id']);
      int rNo=purchaseList.length;
      if(existsVendorIndex==-1){
        var obj = {
          "DepartmentId": vDrp['Id'],
          "DepartmentName": vDrp['Text'],
          "IsDelete":true,
          "MaterialList": []
        };
        purchaseList.add(obj);
      }
      else{
        rNo=existsVendorIndex;
      }

      List productList=purchaseList[rNo]['MaterialList'];
      int existsProductIndex=productList.indexWhere((element) => element['MaterialId']==mDrp['Id'] && element['MaterialBrandId']==brandId);
      if(existsProductIndex==-1){
        var pObj = {
          "DepartmentDistributionMaterialMappingId": null,
          "MaterialId": mDrp['Id'],
          "MaterialName": mDrp['value'],
          "MaterialBrandId": brandId,
          "MaterialBrandName": brandId!=null ? mbDrp['value'] : "",
          "PrimaryUnitId": unitDropDown.selectedUnit.value['Id'],
          "PrimaryUnitName": unitDropDown.selectedUnit.value['Text'],
          "ReturnQuantity": null,
          "Quantity": parseDouble(materialForm['MaterialQty'].getValue()),
          "DepartmentId": purchaseList[rNo]['DepartmentId'],
          "IsDelete":true,
        };
        productList.add(pObj);
        clearAllV2(materialForm);
        setFrmValues(materialForm, [{"DepartmentId":vDrp['Id']}]);
        unitDropDown.clearValues();
        unitName.value="Unit";
      }
      else{
        CustomAlert().cupertinoAlert("Material Already Exits");
      }
    }
  }

  void onProductQtyUpdate(){
    double qty=parseDouble( numPadUtils['numPadVal']);
    if(numPadUtils['departmentIndex']!=-1 && numPadUtils['productIndex']!=-1){
      if(numPadUtils['numPadType']==1){
        if(qty<=0){
          CustomAlert().cupertinoAlert("Enter Quantity...");
          return;
        }
        purchaseList[numPadUtils['departmentIndex'] as int]['MaterialList'][numPadUtils['productIndex'] as int]['Quantity']=qty;
      }
      else if(numPadUtils['numPadType']==2){
        if(qty<=0){
          CustomAlert().cupertinoAlert("Enter Return Quantity...");
          return;
        }
        int di=numPadUtils['departmentIndex'] as int;
        int pi=numPadUtils['productIndex'] as int;
        double cQty=parseDouble( purchaseList[di]['MaterialList'][pi]['Quantity']);
        if(qty>cQty){
          CustomAlert().cupertinoAlert("Return Quantity should less than ${cQty}...");
          return;
        }
        purchaseList[di]['MaterialList'][pi]['ReturnQuantity']=qty;
      }
      purchaseList.refresh();
    }

    numPadUtils['isNumPadOpen']=false;
    clearNumPadUtils();
  }

  void clearNumPadUtils(){
    numPadUtils['numPadVal']="";
    numPadUtils['numPadTitle']="";
    numPadUtils['numPadSubTitle']="";
    numPadUtils['departmentIndex']=-1;
    numPadUtils['productIndex']=-1;
    numPadUtils['numPadType']=0;
  }

  @override
  void dispose(){
    widgets.clear();
    materialForm.clear();
    purchaseList.clear();
    clearOnDispose();
    super.dispose();
  }
}
