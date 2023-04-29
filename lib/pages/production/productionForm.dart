import 'dart:convert';

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

class ProductionForm extends StatefulWidget {
  bool isEdit;
  Function? closeCb;
  String dataJson;
  ProductionForm({Key? key, this.isEdit = false, this.closeCb, this.dataJson = ""}) : super(key: key);

  @override
  State<ProductionForm> createState() => _ProductionFormState();
}

class _ProductionFormState extends State<ProductionForm> with HappyExtension, TickerProviderStateMixin implements HappyExtensionHelperCallback {
  Map widgets = {};

  String page = "Production";
  TraditionalParam traditionalParam = TraditionalParam(
      getByIdSp: "IV_Production_GetByProductionIdDetail",
      insertSp: "IV_Production_InsertProductionDetail",
      updateSp: "IV_Production_UpdateProductionDetail");
  var isKeyboardVisible = false.obs;

  var unitName = "Unit".obs;
  UnitDropDown unitDropDown = UnitDropDown();

  var isCartOpen = false.obs;
  var selectedIndex=(-1).obs;

  RxList<dynamic> productionMaterialMappingList=RxList<dynamic>();
  RxList<dynamic> productionInnerProductList=RxList<dynamic>();
  RxList<dynamic> productionParentList=RxList<dynamic>();

  late SwipeActionController controller;

  var numPadUtils = {
    "isNumPadOpen": false,
    "numPadVal": "",
    "numPadTitle": "",
    "numPadSubTitle": "",
    "numPadUnit": "",
    "departmentId": -1,
    "productIndex": -1,
    "numPadType": 0
  }.obs;

  RxList<dynamic>  tabList=RxList<dynamic>();
  RxList<dynamic>  primaryRecipeList=RxList<dynamic>();
  RxList<dynamic>  recipeList=RxList<dynamic>();
  var selectedTab=(-1).obs;
  var reloadTab=false.obs;


  double sw=SizeConfig.screenWidth!-30;
  double col1Wid=0.0,col2Wid=0.0,col3Wid=0.0;
  final FlutterUtils _flutterUtils=FlutterUtils();

  var  needApprovedQty=false.obs;

  @override
  void initState() {

    controller = SwipeActionController(
      selectedIndexPathsChangeCallback:
          (changedIndexPaths, selected, currentCount) {},
    );
    col1Wid=sw*0.5;
    col2Wid=sw*0.25;
    col3Wid=sw*0.25;
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
                    title: "${widget.isEdit?"Update":"Add"} Production Master",
                    width: SizeConfig.screenWidth! - 100,
                    prefix: ArrowBack(
                      onTap: () {
                        Get.back();
                      },
                    ),
                  ),
                  inBtwHei(height: 10),
                  Row(
                    children: [
                      LeftHeader(title: "Recipe Production Usage",width: SizeConfig.screenWidth!-140,),
                      const Spacer(),
                      Obx(() => cartIcon(
                          onTap:(){
                            isCartOpen.value=true;
                          },
                          count: productionParentList.length
                      )),
                      const SizedBox(width: 20,)
                    ],
                  ),
                  inBtwHei(height: 20),
                  SizedBox(
                    width: SizeConfig.screenWidth,
                    height: 70,
                    child: Obx(() => ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: tabList.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (ctx,i){
                        return GestureDetector(
                          onTap: (){
                            selectedTab.value=i;
                          },
                          child: Obx(() => Container(
                            height: 50,
                            padding: const EdgeInsets.only(left: 15,right: 15),
                            margin: EdgeInsets.only(bottom: 15,right: 15,left: i==0?15:0,top: 0),
                            alignment: Alignment.center,
                            constraints: const BoxConstraints(
                                minWidth: 100
                            ),
                            decoration:selectedTab.value==i? BoxDecoration(
                                color: ColorUtil.red2,
                                borderRadius: BorderRadius.circular(19),
                                boxShadow: [
                                  BoxShadow(
                                      color: ColorUtil.red2.withOpacity(0.2),
                                      spreadRadius: -1,
                                      blurRadius: 20,
                                      offset: Offset(1, 10))
                                ]
                            ):BoxDecoration(
                              color: const Color(0xFFE6E6E6),
                              borderRadius: BorderRadius.circular(19),
                            ),
                            child: Text("${tabList[i]['Text']}",style: ts20M(selectedTab.value==i?ColorUtil.themeWhite:ColorUtil.red2),),
                          )),
                        );
                      },
                    )),
                  ),
                  inBtwHei(height: 20),
                  Flexible(child: SingleChildScrollView(
                    child: Obx(() => Wrap(
                      runSpacing: 20,
                      spacing: 20,
                      children: [
                        for(int i=0;i<recipeList.length;i++)
                          GestureDetector(
                            onTap: (){
                              onRecipeSelect(recipeList[i],i);
                            },
                            child: Container(
                              height: 135,
                              width: (SizeConfig.screenWidth!-30)*0.3,
                              padding: const EdgeInsets.only(left: 3,right: 3,bottom: 3),
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: ColorUtil.themeWhite
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset("assets/inventory-white.svg",height: 70,),
                                  inBtwHei(),
                                  Text("${recipeList[i]['RecipeName']}",textAlign: TextAlign.center,
                                    style: ts20M(ColorUtil.themeBlack,fontsize: 15),
                                  )
                                ],
                              ),
                            ),
                          )
                      ],
                    )),
                  )),
                  const SizedBox(
                    height: 75,
                  ),
                ],
              ),
            ),
            SaveCloseBtn(
              isEdit: widget.isEdit,
              isKeyboardVisible: isKeyboardVisible,
              onSave: () {
                sysSubmit(widgets,
                    isEdit: widget.isEdit,
                    needCustomValidation: true,
                    traditionalParam: traditionalParam,
                    loader: showLoader,
                    extraParam: MyConstants.extraParam,
                    onCustomValidation: () {
                      if (productionMaterialMappingList.isEmpty) {
                        CustomAlert()
                            .cupertinoAlert("Select Recipe to add Production...");
                        return false;
                      }
                      foundWidgetByKey(widgets, "Datajson", needSetValue: true, value: jsonEncode(productionMaterialMappingList));
                      //foundWidgetByKey(widgets, "RecipeStaffMappingList", needSetValue: true, value: jsonEncode(recipeStaffMappingList));
                      //foundWidgetByKey(widgets, "RecipeVesselMappingList", needSetValue: true, value: jsonEncode(recipeVesselMappingList));
                      return true;
                    },
                    successCallback: (e) {
                      console("sysSubmit $e");
                      if (widget.closeCb != null) {
                        widget.closeCb!(e);
                      }
                    });
              },
            ),

            SlidePopUp(
              isOpen: isCartOpen,
              onBack: (){
                selectedIndex.value=-1;
              },
              appBar: Obx(() => FlexFittedText(
                flex: 3,
                text: "Materials (${productionParentList.length} Numbers)",
                textStyle: ts20M(ColorUtil.themeBlack,fontsize: 18),
              )),
              widgets: [
                Row(
                  children: [
                    GridTitleCard(
                      width: needApprovedQty.value?col1Wid:col1Wid+col2Wid,
                      content: "Recipe Name",
                    ),
                    GridTitleCard(
                      width: col2Wid,
                      content: "Requested Qty",
                    ),
                    Visibility(
                      visible: needApprovedQty.value,
                      child: GridTitleCard(
                        width: col3Wid,
                        content: "Approved Qty",
                      ),
                    ),
                  ],
                ),
                const SwipeNotes(),
                Expanded(
                  child: Obx(() => ListView.builder(
                    shrinkWrap: true,
                    itemCount: productionParentList.length,
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
                              numPadUtils['numPadTitle']=productionParentList[i]['RecipeName'];
                              numPadUtils['numPadUnit']=productionParentList[i]['UnitName'];
                              numPadUtils['numPadSubTitle']=productionParentList[i]['DepartmentName'];
                              numPadUtils['numPadVal']=productionParentList[i]['RequestedQuantity'];
                              numPadUtils['isNumPadOpen'] = true;
                              numPadUtils['numPadType'] = 2;
                              numPadUtils['departmentId'] = parseInt(productionParentList[i]['DepartmentId']);
                              numPadUtils['productIndex'] =  i;
                              controller.closeAllOpenCell();
                            },needBG: true),
                            swipeActionDelete((handler) async {
                              productionMaterialMappingList.removeWhere((element) => element['RecipeId'].toString()==productionParentList[i]['RecipeId'].toString()&&
                                  element['DepartmentId'].toString()==productionParentList[i]['DepartmentId'].toString());
                              if(selectedIndex.value!=-1){
                                selectedIndex.value=-1;
                              }
                              productionParentList.removeAt(i);
                              productionInnerProductList.clear();
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
                                    productionInnerProductList.clear();
                                  }
                                  else {
                                    selectedIndex.value=i;
                                    productionInnerProductList.value=productionMaterialMappingList.where((p0) => p0['ParentId'].toString()==productionParentList[i]['ParentPrimaryId'].toString()
                                    && p0['DepartmentId'].toString()==productionParentList[i]['DepartmentId'].toString()).toList();
                                  }
                                  setState(() {});
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 0),
                                  padding: const EdgeInsets.fromLTRB(5, 12, 5, 12),
                                  decoration:ColorUtil.formContBoxDec,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width:needApprovedQty.value?col1Wid:col1Wid+col2Wid-31,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("${productionParentList[i]['RecipeName']}",
                                              style: ts20M(ColorUtil.themeBlack,fontsize: 18),
                                            ),
                                            Text("${productionParentList[i]['DepartmentName']}",
                                              style: ts20M(ColorUtil.red2,fontsize: 15),
                                            ),
                                          ],
                                        ),
                                      ),
                                      FittedText(
                                        height: 25,
                                        width:col2Wid-11,
                                        alignment: Alignment.centerLeft,
                                        text: "${productionParentList[i]['RequestedQuantity']} ${productionParentList[i]['UnitName']}",
                                        textStyle: ts20M(ColorUtil.red2,fontsize: 18),
                                      ),
                                      Visibility(
                                        visible: needApprovedQty.value,
                                        child: FittedText(
                                          height: 25,
                                          width:col2Wid-31,
                                          alignment: Alignment.centerLeft,
                                          text: "${productionParentList[i]['ApprovedQuantity']} ${productionParentList[i]['UnitName']}",
                                          textStyle: ts20M(ColorUtil.text1,fontsize: 18),
                                        ),
                                      ),
                                      ArrowAnimation(
                                        openCb: (value){
                                        },
                                        isclose: selectedIndex!=i,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Obx(() => ExpandedSection(
                                expand: selectedIndex.value==i,
                                child: ListView.builder(
                                  itemCount: productionInnerProductList.length,
                                  physics:const NeverScrollableScrollPhysics(),
                                  shrinkWrap:true,
                                  itemBuilder: (ctx1,index){
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 0),
                                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                      //  decoration:ColorUtil.formContBoxDec,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width:needApprovedQty.value?col1Wid:col1Wid+col2Wid-31,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("${productionInnerProductList[index]['MaterialName']}",
                                                  style: ts20M(ColorUtil.themeBlack,fontsize: 18),
                                                ),

                                              ],
                                            ),
                                          ),
                                          FittedText(
                                            height: 25,
                                            width:col2Wid-11,
                                            alignment: Alignment.centerLeft,
                                            text: "${productionInnerProductList[index]['RequestedQuantity']} ${productionInnerProductList[index]['UnitName']}",
                                            textStyle: ts20M(ColorUtil.red2,fontsize: 18),
                                          ),
                                          Visibility(
                                            visible: needApprovedQty.value,
                                            child: FittedText(
                                              height: 25,
                                              width:col2Wid-11,
                                              alignment: Alignment.centerLeft,
                                              text: "${productionInnerProductList[index]['ApprovedQuantity']} ${productionInnerProductList[index]['UnitName']}",
                                              textStyle: ts20M(ColorUtil.text1,fontsize: 18),
                                            ),
                                          ),

                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ))
                            ],
                          ),
                        ),
                      );
                    },
                  )),
                )
              ],
            ),

            Obx(() => Blur(
              value: numPadUtils['isNumPadOpen'] as bool,
            )),
            Obx(() => NumberPadPopUp(
              isSevenInch: true,
              isOpen: numPadUtils['isNumPadOpen'] as bool,
              value: numPadUtils['numPadVal'].toString(),
              title: numPadUtils['numPadTitle'].toString(),
              subTitle: numPadUtils['numPadSubTitle'].toString(),
              unit: numPadUtils['numPadUnit'].toString(),
              onCancel: () {
                numPadUtils['isNumPadOpen'] = false;
                clearNumPadUtils();
              },
              numberTap: (e) {
                numPadUtils['numPadVal'] = e;
              },
              onDone: () {
                onRecipeQtyUpdate();
              },
            )),

            Obx(() => Loader(  value: showLoader.value )),
          ],
        ));
  }

  @override
  void assignWidgets() async {
    unitDropDown.onChange = (e) {
      unitName.value = e['Text'];
    };
    widgets.clear();
    widgets['ProductionId']=HiddenController(dataname: "ProductionId");
    widgets["Datajson"]=HiddenController(dataname: "Datajson");
    getDepartmentList();


    await parseJson(widgets, "",
        dataJson: widget.dataJson,
        traditionalParam: traditionalParam,
        extraParam: MyConstants.extraParam,
        loader: showLoader, resCb: (e) {
          try {
            console("parseJson $e");
            productionMaterialMappingList.value=e['Table1'];
            productionMaterialMappingList.where((element) => element['ParentId'].toString()=="0").toList().forEach((element) {
              productionParentList.add(element);
            });
          } catch (e, t) {
            assignWidgetErrorToastLocal(e, t);
          }
        });
  }

  void getDepartmentList() async{
    List<ParamModel> parameterList=await getParamEssential(extraParam: MyConstants.extraParam);
    parameterList.add(ParamModel(Key: "HiraricalId", Type: "String", Value: ""));
    parameterList.add(ParamModel(Key: "RefId", Type: "String", Value: ""));
    parameterList.add(ParamModel(Key: "RefTypeName", Type: "String", Value: ""));
    parameterList.add(ParamModel(Key: "TypeName", Type: "String", Value: "DepartmentRecipeId"));
    parameterList.add(ParamModel(Key: "Page", Type: "String", Value: page));
    _flutterUtils.getInvoke(parameterList,loader: showLoader,url: "${GetBaseUrl()}/api/Common/GetMasterDataList").then((value){
      if(value[0]){
        var parsed=jsonDecode(value[1]);
        if(parsed['Table'].length>0){
          tabList.value=parsed['Table'];
          primaryRecipeList.value=parsed['Table1'];
          recipeList.value=primaryRecipeList.value;
          selectedTab.value=0;
        }
        console("$parsed");
      }
    });
  }

  void onRecipeSelect(e,recipeIndex){
    int depId=tabList[selectedTab.value]['Id'];
    int existIndex=productionMaterialMappingList.indexWhere((element) => element['RecipeId'].toString()==e['RecipeId'].toString()
        && element['DepartmentId'].toString()==depId.toString());
    if(existIndex==-1){
      numPadUtils['numPadTitle']=e['RecipeName'];
      numPadUtils['numPadUnit']=e['UnitName'];
      numPadUtils['numPadSubTitle']=tabList[selectedTab.value]['Text'];
      numPadUtils['isNumPadOpen'] = true;
      numPadUtils['numPadType'] = 1;
      numPadUtils['departmentId'] = depId;
      numPadUtils['productIndex'] = recipeIndex;
    }
    else{
      CustomAlert().cupertinoAlert("Recipe already Exists...");
    }
  }
  void onRecipeQtyUpdate() async{

    double qty=parseDouble(numPadUtils['numPadVal']);
    if(qty<=0){
      CustomAlert().cupertinoAlert("Enter Quantity");
      return;
    }

    int recipeId=-1;

    int type=numPadUtils['numPadType'] as int;

    if(type == 1){
      recipeId=recipeList[numPadUtils['productIndex'] as int]['RecipeId'];
    }
    else if(type==2){
      recipeId =productionParentList[numPadUtils['productIndex'] as int]['RecipeId'];
    }


    selectedIndex.value=-1;
    List<ParamModel> parameterList=await getParamEssential(extraParam: MyConstants.extraParam);
    parameterList.add(ParamModel(Key: "RecipeId", Type: "String", Value: recipeId));
    parameterList.add(ParamModel(Key: "DepartmentId", Type: "String", Value:     numPadUtils['departmentId'] as int));
    parameterList.add(ParamModel(Key: "RequestedQty", Type: "String", Value: qty));
    parameterList.add(ParamModel(Key: "ApprovedQty", Type: "String", Value:  null));
    _flutterUtils.getInvoke(parameterList,loader: showLoader,url: "${GetBaseUrl()}/api/ProductionApi/GetProductionRecipeDetail").then((value){

      if(value[0]){
        var parsed=jsonDecode(value[1]);
        List<dynamic> recipeList=parsed['Table'];
        if(type==1){
          productionMaterialMappingList.addAll(recipeList);
          productionParentList.add(recipeList.where((element) => element['ParentId'].toString()=="0").toList()[0]);
        }
        else if(type==2){
          int dif=numPadUtils['departmentId'] as int;
          productionMaterialMappingList.removeWhere((element) => element['RecipeId'].toString()==recipeId.toString() &&
              element['DepartmentId'].toString()==dif.toString());
          productionParentList[numPadUtils['productIndex'] as int]=recipeList.where((element) => element['ParentId'].toString()=="0").toList()[0];
          productionMaterialMappingList.addAll(recipeList);
        }
        numPadUtils['isNumPadOpen'] = false;
        clearNumPadUtils();
      }
      else{
        CustomAlert().cupertinoAlert(value[1]);
      }
    });

  }



  void clearNumPadUtils() {
    numPadUtils['numPadVal'] = "";
    numPadUtils['numPadTitle'] = "";
    numPadUtils['numPadSubTitle'] = "";
    numPadUtils['departmentIndex'] = -1;
    numPadUtils['productIndex'] = -1;
    numPadUtils['numPadType'] = 0;
  }

  @override
  void dispose() {
    widgets.clear();
    productionMaterialMappingList.clear();
    productionParentList.clear();
    primaryRecipeList.clear();
    clearOnDispose();
    super.dispose();
  }
}
