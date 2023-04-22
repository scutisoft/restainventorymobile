import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/mixins/extensionMixin.dart';
import 'package:flutter_utils/model/parameterModel.dart';
import 'package:flutter_utils/utils/apiUtils.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:flutter_utils/utils/utils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restainventorymobile/widgets/calculation.dart';
import 'package:restainventorymobile/widgets/customCheckBox.dart';
import '/widgets/expandedSection.dart';
import '/widgets/fittedText.dart';
import '/widgets/loader.dart';
import '/widgets/numberPadPopUp/numberPadPopUp.dart';
import '/api/apiUtils.dart';
import '/widgets/arrowAnimation.dart';
import '/widgets/inventoryWidgets.dart';
import '/widgets/swipe2/core/cell.dart';
import '/widgets/swipe2/core/controller.dart';
import '/api/sp.dart';
import '/notifier/configuration.dart';
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
import '/widgets/customWidgetsForDynamicParser/searchDrp2.dart';
import '/widgets/searchDropdown/dropdown_search.dart';
import '/widgets/singleDatePicker.dart';

class TransferForm extends StatefulWidget {
  bool isEdit;
  Function? closeCb;
  String dataJson;
  TransferForm({Key? key,this.isEdit=false,this.closeCb,this.dataJson=""}) : super(key: key);

  @override
  State<TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends State<TransferForm> with HappyExtension,TickerProviderStateMixin implements HappyExtensionHelperCallback{

  Map widgets={};
  Map rawMaterialForm={};

  String page="Transfer";

  Rxn<DateTime> expectedDate=Rxn<DateTime>();


  double scrollPadding=10;
  UnitDropDown unitDropDown=UnitDropDown();

  RxList<dynamic> materialMappingList=RxList<dynamic>();
  RxList<dynamic> indentMappingList=RxList<dynamic>();


  var isRawMatCartOpen=false.obs;
  var isIndentOpen=false.obs;
  var selectedIndex=(-1).obs;
  late SwipeActionController controller;
  var numPadUtils={
    "isNumPadOpen":false,
    "numPadVal":"",
    "numPadTitle":"",
    "numPadSubTitle":"",
    "numPadType":0,
    "productIndex":-1
  }.obs;
  final FlutterUtils _flutterUtils=FlutterUtils();

  @override
  void initState(){

    controller = SwipeActionController(selectedIndexPathsChangeCallback: (changedIndexPaths, selected, currentCount) {},);
    col1Wid=sw*0.5;
    col2Wid=sw*0.25;
    col3Wid=sw*0.25;
    assignWidgets();
    super.initState();
  }

  double sw=SizeConfig.screenWidth!-30;
  double col1Wid=0.0,col2Wid=0.0,col3Wid=0.0;
  var isKeyboardVisible=false.obs;

  TraditionalParam traditionalParam=TraditionalParam(
      getByIdSp: "IV_Transfer_GetByTransferOrderIdDetail",
      insertSp: "IV_Transfer_InsertTransferOrderDetail",
      updateSp: "IV_Transfer_UpdateTransferOrderDetail"
  );

  var activeTab=0;
  var approvedQtyUnit="Unit".obs;

  var hasIndentMaterials=false.obs;

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
                    title: "${widget.isEdit?"Update":"Add"} Transfer Material",
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
                        SvgPicture.asset("assets/icons/store.svg"),
                        Container(
                          width: SizeConfig.screenWidth,
                          alignment: Alignment.center,
                          child: Container(
                            height: 35,
                            width: 200,
                            margin: EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Color(0xff444C66),
                            ),
                            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                            alignment: Alignment.center,
                            child: FittedBox(
                              child: widgets['FromStoreName'],
                            ),
                          ),
                        ),
                        LeftHeader(title: "To Store"),
                        widgets['ToStoreId'],
                        LeftHeader(title: "Transfer Order Type"),
                        widgets['TransferOrderTypeId'],
                        LeftHeader(title: "Notes"),
                        widgets['Notes'],
                        LeftHeader(title: "Transfer Date"),
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

                        inBtwHei(height: 20),
                        Row(
                          children: [
                            LeftHeader(title: "+ Add Transfer Material"),
                            const Spacer(),
                            GestureDetector(
                              onTap: (){
                                if(widgets['ToStoreId'].getValueMap().isEmpty){
                                  CustomAlert().cupertinoAlert("Select To Store...");
                                  return;
                                }
                                isIndentOpen.value=true;
                              },
                              child: CustomCircle(
                                hei: 50,
                                color: ColorUtil.themeWhite,
                                margin: const EdgeInsets.only(right: 10),
                                widget: SvgPicture.asset("assets/icons/delivery-truck.svg",height: 25,),
                              ),
                            ),
                            Obx(() => cartIcon(
                                onTap:(){
                                  isRawMatCartOpen.value=true;
                                },
                                count: materialMappingList.length
                            )),
                            const SizedBox(width: 20,)
                          ],
                        ),
                        Obx(() =>
                            Visibility(
                              visible: !hasIndentMaterials.value,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  LeftHeader(title: "Material"),
                                  rawMaterialForm['MaterialId'],
                                  LeftHeader(title: "Material Brand"),
                                  rawMaterialForm['MaterialBrandId'],
                                  LeftHeader(title: "Transfer Quantity"),
                                  rawMaterialForm['TransferQuantity'],
                                  inBtwHei(height: 30),
                                  Align(
                                    alignment: Alignment.center,
                                    child: DoneBtn(onDone: onMaterialAdd, title: "Add"),
                                  ),
                                ],
                              ),
                            )
                        ),

                        inBtwHei(height: 100),
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
                    onCustomValidation: (){

                      if(materialMappingList.isEmpty){
                        CustomAlert().cupertinoAlert("Select Material to Transfer...");
                        return false;
                      }

                      foundWidgetByKey(widgets, "TransferDate",needSetValue: true,value: DateFormat(MyConstants.dbDateFormat).format(expectedDate.value!));
                      foundWidgetByKey(widgets, "TransferOrderMaterialJson",needSetValue: true,value: jsonEncode(materialMappingList.value));
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
              isOpen: isRawMatCartOpen,
              appBar: Obx(() => FlexFittedText(
                flex: 3,
                text: "Materials (${materialMappingList.length} Numbers)",
                textStyle: ts20M(ColorUtil.themeBlack,fontsize: 18),
              )),
              widgets: [
                inBtwHei(height: 15),
                Row(
                  children: [
                    GridTitleCard(
                      width: col1Wid,
                      content: "Material Name",
                    ),
                    GridTitleCard(
                      width: col2Wid,
                      content: "Indent Qty",
                    ),
                    GridTitleCard(
                      width: col3Wid,
                      content: "Transfer Qty",
                    ),
                  ],
                ),
                const SwipeNotes(),
                Expanded(
                  child: Obx(()=>ListView.builder(
                    shrinkWrap: true,
                    itemCount: materialMappingList.length,
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
                              numPadUtils.value={
                                "isNumPadOpen":true,
                                "numPadVal":getQtyString(materialMappingList[i]['TransferQuantity']),
                                "numPadTitle":"${materialMappingList[i]['MaterialName']}",
                                "numPadSubTitle":"Transfer Qty",
                                "numPadType":1,
                                "productIndex":i
                              };
                              controller.closeAllOpenCell();
                            }),
                            swipeActionDelete((handler) async {
                              materialMappingList.removeAt(i);
                              await handler(true);
                            }),
                          ],
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 0),
                            padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                            decoration:ColorUtil.formContBoxDec,
                            child: Row(
                              children: [
                                SizedBox(
                                  width:col1Wid,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${materialMappingList[i]['MaterialName']}",
                                        style: ts20M(ColorUtil.themeBlack,fontsize: 18),
                                      ),
                                      Visibility(
                                        visible: !checkNullEmpty(materialMappingList[i]['MaterialBrandName']),
                                        child: Text("${materialMappingList[i]['MaterialBrandName']}",
                                          style: ts20M(ColorUtil.red2,fontsize: 15),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                FittedText(
                                  height: 25,
                                  width:col2Wid-11,
                                  alignment: Alignment.centerLeft,
                                  text: "${materialMappingList[i]['IndentQuantity']} ${materialMappingList[i]['UnitName']}",
                                  textStyle: ts20M(ColorUtil.red2,fontsize: 18),
                                ),
                                FittedText(
                                  height: 25,
                                  width:col2Wid-11,
                                  alignment: Alignment.centerLeft,
                                  text: "${materialMappingList[i]['TransferQuantity']} ${materialMappingList[i]['UnitName']}",
                                  textStyle: ts20M(ColorUtil.text1,fontsize: 18),
                                ),

                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )),
                ),
              ],
            ),

            SlidePopUp(
                isOpen: isIndentOpen,
                appBar: Obx(() => FlexFittedText(
                flex: 3,
                text: "Indent (${indentMappingList.length} Numbers)",
                textStyle: ts20M(ColorUtil.themeBlack,fontsize: 18),
              )),
                widgets: [
                  Expanded(
                    child: Obx(() =>
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: indentMappingList.length,
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
                                                Text("${indentMappingList[i]['IndentOrderNumber']} / ${indentMappingList[i]['Date']}",style: ts20M(ColorUtil.red),),
                                                inBtwHei(),
                                              ],
                                            ),
                                          ),
                                          CustomCheckBox(
                                            isSelect: indentMappingList[i]['IsSelectAll']??false,onlyCheckbox: true,ontap: (){
                                              if(indentMappingList[i]['IsSelectAll']==null){
                                                indentMappingList[i]['IsSelectAll']=true;
                                              }
                                              else{
                                                indentMappingList[i]['IsSelectAll']=!indentMappingList[i]['IsSelectAll'];
                                              }
                                              indentMappingList[i]['MaterialList'].forEach((p){
                                                p['IsSelect']=indentMappingList[i]['IsSelectAll'];
                                              });
                                              indentMappingList[i]['hasProduct']=indentMappingList[i]['IsSelectAll'];
                                              indentMappingList.refresh();
                                          },selectColor: ColorUtil.red2,),
                                          const SizedBox(width: 10,),
                                          Obx(() => ArrowAnimation(
                                            openCb: (value){
                                            },
                                            isclose: selectedIndex.value!=i,
                                          ),),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Obx(() => ExpandedSection(
                                    expand: selectedIndex.value==i,
                                    child: ListView.builder(
                                      itemCount: indentMappingList[i]['MaterialList'].length,
                                      physics:const NeverScrollableScrollPhysics(),
                                      shrinkWrap:true,
                                      itemBuilder: (ctx1,index){
                                        return Container(
                                          margin: const EdgeInsets.only(left: 7,right: 7),
                                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(color: ColorUtil.greyBorder)
                                              )
                                          ),
                                          //  decoration:ColorUtil.formContBoxDec,
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width:SizeConfig.screenWidth!-200,
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("${indentMappingList[i]['MaterialList'][index]['MaterialName']}",
                                                      style: ts20M(ColorUtil.themeBlack,fontsize: 18),
                                                    ),
                                                    Visibility(
                                                      visible: indentMappingList[i]['MaterialList'][index]['MaterialBrandName'].toString().isNotEmpty,
                                                      child: Text("${indentMappingList[i]['MaterialList'][index]['MaterialBrandName']}",
                                                        style: ts20M(ColorUtil.red2,fontsize: 15),
                                                      ),
                                                    ),
                                                    inBtwHei(),

                                                  ],
                                                ),
                                              ),
                                              FittedText(
                                                height: 25,
                                                width:100,
                                                alignment: Alignment.centerLeft,
                                                text: "${indentMappingList[i]['MaterialList'][index]['IndentQuantity']} ${indentMappingList[i]['MaterialList'][index]['UnitName']}",
                                                textStyle:  ts20M(ColorUtil.themeBlack,fontsize: 18),
                                              ),
                                              CustomCheckBox(
                                                isSelect: indentMappingList[i]['MaterialList'][index]['IsSelect']??false,
                                                onlyCheckbox: true,
                                                selectColor: ColorUtil.red2,
                                                ontap: (){
                                                  if(indentMappingList[i]['MaterialList'][index]['IsSelect']==null){
                                                    indentMappingList[i]['MaterialList'][index]['IsSelect']=true;
                                                  }
                                                  else{
                                                    indentMappingList[i]['MaterialList'][index]['IsSelect']=!indentMappingList[i]['MaterialList'][index]['IsSelect'];
                                                  }
                                                  int cc=indentMappingList[i]['MaterialList'].where((pa)=>pa['IsSelect']==true).toList().length;
                                                  if(cc==indentMappingList[i]['MaterialList'].length){
                                                    indentMappingList[i]['IsSelectAll']=true;
                                                  }
                                                  else{
                                                    indentMappingList[i]['IsSelectAll']=false;
                                                  }
                                                  indentMappingList[i]['hasProduct']=cc>0;
                                                  indentMappingList.refresh();
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ))
                                ],
                              ),
                            );
                          },
                        )
                    ),
                  ),
                  inBtwHei(height: 20),
                  DoneBtn(onDone: onAddIndent, title: "Add"),
                  inBtwHei(height: 20),
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
                if(numPadUtils['numPadType']==1){
                  onMaterialUpdate();
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
      approvedQtyUnit.value=e['Text'];
    };
    widgets.clear();
    widgets['FromStoreId']=HiddenController(dataname: "FromStoreId");
    widgets['TransferOrderMaterialJson']=HiddenController(dataname: "TransferOrderMaterialJson");
    widgets['TransferDate']=HiddenController(dataname: "TransferDate");
    widgets['TransferOrderId']=HiddenController(dataname: "TransferOrderId");
    widgets['FromStoreName']=HE_Text(dataname: "FromStoreName", contentTextStyle: ts20M(ColorUtil.themeWhite));
    widgets['ToStoreId']=SlideSearch(dataName: "ToStoreId", selectedValueFunc: (e){getIndentOrders();}, hinttext: "Select To Store",data: [],);
    widgets['TransferOrderTypeId']=SearchDrp2(map:  {"dataName":"TransferOrderTypeId","hintText":"Select Transfer Type","labelText":"Transfer Type","showSearch":false,"mode":Mode.DIALOG,"dialogMargin":const EdgeInsets.all(0.0)},);
    widgets['Notes']=AddNewLabelTextField(
      dataname: 'Notes',
      hasInput: true,
      required: false,
      labelText: "Notes",
      scrollPadding: scrollPadding,
      regExp: null,
      onChange: (v){},
      onEditComplete: (){
        FocusScope.of(context).unfocus();
      },
      maxlines: null,
    );

    rawMaterialForm['MaterialId']=SlideSearch(dataName: "MaterialId",
      selectedValueFunc: (e){
        console(e);
        onMaterialChange(e);
      },
      hinttext: "Select Material",data: [],);
    rawMaterialForm['MaterialBrandId']=SlideSearch(dataName: "MaterialBrandId",required: false,
        selectedValueFunc: (e){}, hinttext: "Select Material Brand",data: [],propertyName: "value",);
    rawMaterialForm['TransferQuantity']=AddNewLabelTextField(
      dataname: 'TransferQuantity',
      hasInput: true,
      required: true,
      labelText: "Transfer Quantity",
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
      widgets['FromStoreId'].setValue(await getSharedPrefStringUtil(SP_STOREID));
      widgets['FromStoreName'].setValue(await getSharedPrefStringUtil(SP_STORENAME));
      expectedDate.value=DateTime.now();

    }

    fillTreeDrp(widgets, "ToStoreId",refId: await getSharedPrefStringUtil(SP_STOREID),page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "",clearValues: false);
    fillTreeDrp(widgets, "TransferOrderTypeId",refId: await getSharedPrefStringUtil(SP_STOREID),page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "",clearValues: false);


    fillTreeDrp(rawMaterialForm, "MaterialId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "RawMaterial",clearValues: false);

    await parseJson(widgets, "",dataJson: widget.dataJson,traditionalParam: traditionalParam,extraParam: MyConstants.extraParam,loader: showLoader,
        resCb: (e){
          try{
            console("parseJson $e");
            expectedDate.value=DateTime.parse(e['Table'][0]['TransferDate']);


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
        approvedQtyUnit.value= unitDropDown.selectedUnit.value['Text'];
      }
    }
    fillTreeDrp(rawMaterialForm, "MaterialBrandId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refId: e['Id'],toggleRequired: true,needToDisable: true);
  }

  void onMaterialAdd() async{
    List<ParamModel> a=await getFrmCollection(rawMaterialForm);
    if(a.isNotEmpty){
      Map mDrp=rawMaterialForm['MaterialId'].getValueMap();
      Map mbDrp=rawMaterialForm['MaterialBrandId'].getValueMap();
      var brandId=mbDrp.isEmpty?null:mbDrp['Id'];
      console(mDrp);
      console(mbDrp);
      int existIndex = materialMappingList.indexWhere((e) => e['MaterialId'] == mDrp['Id'] && e['MaterialBrandId'] == brandId && e['UnitId'].toString()==unitDropDown.selectedUnit.value['Id'].toString());
      if (existIndex != -1) {
        CustomAlert().cupertinoAlert("Material Already Exists");
        return;
      }

      double tQty=parseDouble(rawMaterialForm['TransferQuantity'].getValue());
      var obj = {
        "TransferOrderId": null,
        "IndentOrderMaterialMappingId": null,
        "IndentOrderId": null,
        "MaterialId": mDrp['Id'],
        "MaterialName": mDrp['Text'],
        "MaterialBrandId": brandId,
        "MaterialBrandName": brandId!=null ? mbDrp['value'] : "",
        "UnitId": unitDropDown.selectedUnit.value['Id'],
        "UnitName": unitDropDown.selectedUnit.value['Text'],
        "IndentQuantity": 0,
        "TransferQuantity": tQty,
        "TotalQuantity": tQty,
        "InventoryStatusId": null,
        "InventoryStatusName": "",
        "StockTypeId": null,
        "StockTypeName": ""
      };

      materialMappingList.add(obj);
      clearMaterialForm();
    }
  }

  void onMaterialUpdate(){
    double trQty=parseDouble(numPadUtils['numPadVal']);
    int index=numPadUtils['productIndex']as int;
    if(index>=0){
      if(trQty<=0){
        CustomAlert().cupertinoAlert("Transfer Qty should not be empty");
        return;
      }
      materialMappingList[index]['TransferQuantity']=trQty;
      materialMappingList[index]['TotalQuantity']=trQty;
      materialMappingList.refresh();
      numPadUtils['isNumPadOpen']=false;
      clearNumPadUtils();
    }
  }

  void getIndentOrders() async{
    if(hasIndentMaterials.value){
      materialMappingList.clear();
    }
    indentMappingList.clear();
    List<ParamModel> parameterList=await getParamEssential(extraParam: MyConstants.extraParam);
    parameterList.add(ParamModel(Key: "ToStoreId", Type: "String", Value: widgets['ToStoreId'].getValue()));
    _flutterUtils.getInvoke(parameterList,loader: showLoader,url: "${GetBaseUrl()}/api/TransferMaterialApi/GetIndentOrder").then((value){
      if(value[0]){
        var parsed=jsonDecode(value[1]);
        List<dynamic> materialLis=parsed['Table1'];
        indentMappingList.value=parsed['Table'];
        for (var element in indentMappingList) {
          element['MaterialList']=materialLis.where((e) => e['IndentOrderId']==element['IndentOrderId']).toList();
        }
      }
    });
  }

  void onAddIndent(){
    void checkType(pd){
      console("pd ${pd}");
      int existIndex = materialMappingList.indexWhere((e) => e['MaterialId'] == pd['MaterialId'] && e['MaterialBrandId'] == pd['MaterialBrandId'] && e['UnitId'].toString()==pd['UnitId'].toString());
      console("existIndex $existIndex");
      if (existIndex == -1) {
        pd['IndentOrderId']=pd['IndentOrderId'].toString();
        materialMappingList.add(pd);
      }
      else{
        List tii = materialMappingList[existIndex]['IndentOrderId'].split(",");
        if (!tii.contains(pd['IndentOrderId'].toString())){
          tii.add(pd['IndentOrderId'].toString());
          pd['IndentOrderId']=tii.join(",");
          pd['IndentQuantity']=Calculation().add(pd['IndentQuantity'], materialMappingList[existIndex]['IndentQuantity']);
          pd['TotalQuantity']=Calculation().add(pd['TotalQuantity'], materialMappingList[existIndex]['TotalQuantity']);
          pd['TransferQuantity']=Calculation().add(pd['TransferQuantity'], materialMappingList[existIndex]['TransferQuantity']);
          materialMappingList[existIndex]=pd;
        }
      }
    }



    bool chkCt=indentMappingList.any((element) => element['MaterialList'].any((p)=>p['IsSelect']==true)==true);
   // print("onAddIndent $chkCt");
    if(chkCt){
      if(!hasIndentMaterials.value){
        materialMappingList.clear();
        hasIndentMaterials.value=true;
      }
      indentMappingList.where((p0) => p0['hasProduct']==true).forEach((element) {
        for(var pd in element['MaterialList']){
          if(pd['IsSelect']??false){
            checkType(jsonDecode(jsonEncode(pd)));
          }
        }
      });
      materialMappingList.refresh();
      isIndentOpen.value=false;
    }
    else{
      CustomAlert().cupertinoAlert("No Materials Selected to add...");
    }
  }

  void clearMaterialForm(){
    clearAllV2(rawMaterialForm);
    unitDropDown.clearValues();
    approvedQtyUnit.value="Unit";
    FocusScope.of(context).unfocus();
  }



  void clearNumPadUtils(){
    numPadUtils['numPadVal']="";
    numPadUtils['numPadTitle']="";
    numPadUtils['numPadSubTitle']="";
    numPadUtils['productIndex']=-1;
    numPadUtils['numPadType']=0;
  }


  @override
  void dispose(){
    widgets.clear();
    rawMaterialForm.clear();
    clearOnDispose();
    materialMappingList.clear();
    super.dispose();
  }
}


