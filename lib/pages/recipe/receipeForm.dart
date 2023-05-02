import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/mixins/extensionMixin.dart';
import 'package:flutter_utils/model/parameterModel.dart';
import 'package:flutter_utils/utils/apiUtils.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
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
import '/widgets/swipe2/core/cell.dart';
import '/widgets/swipe2/core/controller.dart';

class ReceipeForm extends StatefulWidget {
  bool isEdit;
  Function? closeCb;
  String dataJson;
  ReceipeForm({Key? key, this.isEdit = false, this.closeCb, this.dataJson = ""})
      : super(key: key);

  @override
  State<ReceipeForm> createState() => _ReceipeFormState();
}

class _ReceipeFormState extends State<ReceipeForm> with HappyExtension, TickerProviderStateMixin implements HappyExtensionHelperCallback {
  Map widgets = {};
  Map materialForm = {};
  Map staffForm = {};
  Map vesselForm = {};
  String page = "Recipe";
  TraditionalParam traditionalParam = TraditionalParam(
      getByIdSp: "IV_Recipe_GetRecipeIdDetail",
      insertSp: "IV_Recipe_InsertRecipeDetail",
      updateSp: "IV_Recipe_UpdateRecipeDetail");
  var isKeyboardVisible = false.obs;


  var unitName = "Unit".obs;


  UnitDropDown unitDropDown = UnitDropDown();

  var isCartOpen = false.obs;
  var selectedIndex=(-1).obs;

  RxList<dynamic> recipeMaterialMappingList = RxList<dynamic>();
  RxList<dynamic> recipeStaffMappingList = RxList<dynamic>();
  RxList<dynamic> recipeVesselMappingList = RxList<dynamic>();
  var totalCostDetail={
    "MaterialCost":0.0,
    "StaffCost":0.0,
    "VesselEssentialCost":0.0,
    "TotalCost":0.0
  }.obs;

  var activeTab = 0;

  late SwipeActionController controller;
  late TabController tabController;
  var numPadUtils = {
    "isNumPadOpen": false,
    "numPadVal": "",
    "numPadTitle": "",
    "numPadSubTitle": "",
    "departmentIndex": -1,
    "productIndex": -1,
    "numPadType": 0
  }.obs;

  List tabList=['Material','Staff','Vessel','Cost'];
  var reloadTab=false.obs;


  double sw=SizeConfig.screenWidth!-30;
  double col1Wid=0.0,col2Wid=0.0,col3Wid=0.0;
  final FlutterUtils _flutterUtils=FlutterUtils();
  @override
  void initState() {
    tabController = TabController(length: 4, vsync: this);
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
                title: "${widget.isEdit?"Update":"Add"} Recipe Master",
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
                    inBtwHei(height: 10),
                    LeftHeader(title: "Recipe Name"),
                    widgets['RecipeName'],
                    LeftHeader(title: "Recipe Type"),
                    widgets['RecipeTypeId'],
                    LeftHeader(title: "Recipe Category"),
                    widgets['RecipeCategoryId'],
                    LeftHeader(title: "Cuisine"),
                    widgets['CuisineId'],
                    LeftHeader(title: "Unit"),
                    widgets['UnitId'],
                    LeftHeader(title: "Recipe Chef"),
                    widgets['RecipeChefId'],
                    LeftHeader(title: "PreParation Time"),
                    widgets['PreParationTime'],
                    LeftHeader(title: "Yield Quantity"),
                    widgets['YieldQuantity'],
                    inBtwHei(height: 20),

                    Row(
                      children: [
                        LeftHeader(title: "Recipe Production Usage",width: SizeConfig.screenWidth!-140,),
                        const Spacer(),
                        Obx(() => cartIcon(
                            onTap:(){
                              isCartOpen.value=true;
                            },
                            count: recipeMaterialMappingList.length
                        )),
                        const SizedBox(width: 20,)
                      ],
                    ),
                    inBtwHei(height: 20),
                    SizedBox(
                      //margin: MyConstants.LRPadding,
                      //padding: EdgeInsets.only(left: 15,right: 15),
                      width: SizeConfig.screenWidth,
                      height: 70,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: tabList.length,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (ctx,i){
                          return GestureDetector(
                            onTap: (){
                              tabController.animateTo(i);
                              reloadTab.value=!reloadTab.value;
                            },
                            child: Obx(() => Container(
                              height: reloadTab.value?50:50,
                              padding: EdgeInsets.only(left: 15,right: 15),
                              margin: EdgeInsets.only(bottom: 15,right: 15,left: i==0?15:0,top: 0),
                              alignment: Alignment.center,
                              constraints: BoxConstraints(
                                minWidth: 100
                              ),
                              decoration:tabController.index==i? BoxDecoration(
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
                                color: Color(0xFFE6E6E6),
                                borderRadius: BorderRadius.circular(19),
                              ),
                              child: Text("${tabList[i]}",style: ts20M(tabController.index==i?ColorUtil.themeWhite:ColorUtil.red2),),
                            )),
                          );
                        },
                      ),
                    ),

                    SizedBox(
                      height: 450,
                      child: TabBarView(
                          controller: tabController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                inBtwHei(height: 20),
                                materialForm['MaterialId'],
                                inBtwHei(height: 10),
                                materialForm['MaterialBrandId'],
                                inBtwHei(height: 10),
                                materialForm['Quantity'],
                                inBtwHei(height: 30),
                                DoneBtn(onDone: onMaterialAdd, title: "Add"),
                              ],
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                inBtwHei(height: 20),
                                staffForm['StaffCategoryId'],
                                inBtwHei(height: 10),
                                staffForm['TotalStaff'],
                                inBtwHei(height: 10),
                                staffForm['WorkingTime'],
                                inBtwHei(height: 10),
                                staffForm['SalaryCost'],
                                inBtwHei(height: 30),
                                DoneBtn(onDone: onStaffAdd, title: "Add"),
                              ],
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                inBtwHei(height: 20),
                                vesselForm['VesselId'],
                                inBtwHei(height: 10),
                                Obx(() => Visibility(visible:vesselCategoryId.value==2,child: vesselForm['UsageTime'])),
                                inBtwHei(height: 10),
                                Obx(() => Visibility(visible:vesselCategoryId.value==1,child: vesselForm['VesselQuantity'])),
                                inBtwHei(height: 30),
                                DoneBtn(onDone: onVesselAdd, title: "Add"),
                              ],
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                inBtwHei(height: 30),
                                LeftHeader(title: "Over all Cost Info ${MyConstants.rupeeString}"),
                                inBtwHei(),
                                Obx(() => getCostCard("Material Cost", totalCostDetail['MaterialCost'])),
                                Obx(() => getCostCard("Staff Cost", totalCostDetail['StaffCost'])),
                                Obx(() => getCostCard("Vessel & Essential Cost", totalCostDetail["VesselEssentialCost"])),
                                Container(
                                  height: ColorUtil.formContainerHeight,
                                  //decoration: ColorUtil.formContBoxDec,
                                  margin: const EdgeInsets.only(left:15,right:15,bottom:5,),
                                  padding: const EdgeInsets.only(left: 15,right: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      FlexFittedText(
                                        text: "Total Cost",
                                        textStyle: ts20M(ColorUtil.themeBlack),
                                      ),
                                      Obx(() => FlexFittedText(
                                        text: getRupeeString(totalCostDetail['TotalCost']),
                                        textStyle: ts20M(ColorUtil.red2,fontfamily: "AH",fontWeight: FontWeight.bold),
                                      )),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ]),
                    ),
                    // Align(
                    //   alignment: Alignment.center,
                    //   child: DoneBtn(onDone: onMaterialAdd, title: "Add"),
                    // ),
                    const SizedBox(
                      height: 100,
                    )
                  ],
                ),
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
                  if (recipeMaterialMappingList.isEmpty) {
                    CustomAlert()
                        .cupertinoAlert("Select Material to Prepare Recipe...");
                    return false;
                  }
                  foundWidgetByKey(widgets, "RecipeMaterialMappingList", needSetValue: true, value: jsonEncode(recipeMaterialMappingList));
                  foundWidgetByKey(widgets, "RecipeStaffMappingList", needSetValue: true, value: jsonEncode(recipeStaffMappingList));
                  foundWidgetByKey(widgets, "RecipeVesselMappingList", needSetValue: true, value: jsonEncode(recipeVesselMappingList));
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
            text: "Materials (${recipeMaterialMappingList.length} Numbers)",
            textStyle: ts20M(ColorUtil.themeBlack,fontsize: 18),
          )),
          widgets: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Obx(() => ListView.builder(
                    shrinkWrap: true,
                    itemCount: recipeMaterialMappingList.length,
                    physics: const NeverScrollableScrollPhysics(),
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
                            /*swipeActionEdit((handler) async{
                              updateHandler(1,i);
                              controller.closeAllOpenCell();
                            },needBG: true),*/
                            swipeActionDelete((handler) async {
                              deleteHandler(1,i);
                              await handler(true);
                            },needBG: true),
                          ],
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 0),
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            decoration:ColorUtil.formContBoxDec,
                            constraints: BoxConstraints(
                                minHeight: 60
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width:col1Wid-20,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${recipeMaterialMappingList[i]['MaterialName']}",
                                        style: ts20M(ColorUtil.themeBlack,fontsize: 18),
                                      ),
                                      Visibility(
                                        visible: !checkNullEmpty(recipeMaterialMappingList[i]['MaterialBrandName']),
                                        child: Text("${recipeMaterialMappingList[i]['MaterialBrandName']}",
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
                                  text: "${recipeMaterialMappingList[i]['Quantity']} ${recipeMaterialMappingList[i]['UnitName']} ",
                                  textStyle: ts20M(ColorUtil.red2,fontsize: 16),
                                ),
                                FittedText(
                                  height: 25,
                                  width:col2Wid-11+20,
                                  alignment: Alignment.centerRight,
                                  text: getRupeeString(recipeMaterialMappingList[i]['Cost']),
                                  textStyle: ts20M(ColorUtil.red2,fontsize: 18,fontfamily: 'AH'),
                                ),

                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )),
                  getTotalFooter('MaterialCost'),
                  inBtwHei(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Obx(()=>
                        Text("Vessels (${recipeVesselMappingList.length} Numbers)",
                          style: ts20M(ColorUtil.themeBlack),
                        )
                    ),
                  ),
                  inBtwHei(height: 10),
                  Obx(() => ListView.builder(
                    shrinkWrap: true,
                    itemCount: recipeVesselMappingList.length,
                    physics: const NeverScrollableScrollPhysics(),
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
                            /*swipeActionEdit((handler) async{
                              updateHandler(1,i);
                              controller.closeAllOpenCell();
                            },needBG: true),*/
                            swipeActionDelete((handler) async {
                              deleteHandler(2,i);
                              await handler(true);
                            },needBG: true),
                          ],
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 0),
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            decoration:ColorUtil.formContBoxDec,
                            constraints: BoxConstraints(
                                minHeight: 60
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width:col1Wid-20,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${recipeVesselMappingList[i]['VesselName']}",
                                        style: ts20M(ColorUtil.themeBlack,fontsize: 18),
                                      ),
                                      Text("${recipeVesselMappingList[i]['VesselCategoryName']}",
                                        style: ts20M(ColorUtil.text4,fontsize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                                FittedText(
                                  height: 25,
                                  width:col2Wid-11,
                                  alignment: Alignment.centerLeft,
                                  text: "${parseInt(recipeVesselMappingList[i]['VesselQuantity'])>0?recipeVesselMappingList[i]['VesselQuantity']:""} ${recipeVesselMappingList[i]['EssentialTime']} ",
                                  textStyle: ts20M(ColorUtil.red2,fontsize: 16),
                                ),
                                FittedText(
                                  height: 25,
                                  width:col2Wid-11+20,
                                  alignment: Alignment.centerRight,
                                  text: getRupeeString(recipeVesselMappingList[i]['UsageCost']),
                                  textStyle: ts20M(ColorUtil.red2,fontsize: 18,fontfamily: 'AH'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )),
                  getTotalFooter('VesselEssentialCost'),
                  inBtwHei(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Obx(()=>
                        Text("Staff (${recipeStaffMappingList.length} Numbers)",
                          style: ts20M(ColorUtil.themeBlack),
                        )
                    ),
                  ),
                  inBtwHei(height: 10),
                  Obx(() => ListView.builder(
                    shrinkWrap: true,
                    itemCount: recipeStaffMappingList.length,
                    physics: const NeverScrollableScrollPhysics(),
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
                            /*swipeActionEdit((handler) async{
                              updateHandler(1,i);
                              controller.closeAllOpenCell();
                            },needBG: true),*/
                            swipeActionDelete((handler) async {
                              deleteHandler(3,i);
                              await handler(true);
                            },needBG: true),
                          ],
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 0),
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            decoration:ColorUtil.formContBoxDec,
                            constraints: BoxConstraints(
                                minHeight: 60
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width:(col1Wid-20)*0.7,
                                  child: Text("${recipeStaffMappingList[i]['StaffCategoryName']}",
                                    style: ts20M(ColorUtil.themeBlack,fontsize: 18),
                                  ),
                                ),
                                FittedText(
                                  height: 25,
                                  width:(col1Wid-20)*0.3,
                                  alignment: Alignment.centerLeft,
                                  text: "${recipeStaffMappingList[i]['TotalStaff']}",
                                  textStyle: ts20M(ColorUtil.themeBlack,fontsize: 16),
                                ),
                                FittedText(
                                  height: 25,
                                  width:col2Wid-11,
                                  alignment: Alignment.centerLeft,
                                  text: "${recipeStaffMappingList[i]['WorkingTime']} Hrs",
                                  textStyle: ts20M(ColorUtil.themeBlack,fontsize: 16),
                                ),
                                FittedText(
                                  height: 25,
                                  width:col2Wid-11+20,
                                  alignment: Alignment.centerRight,
                                  text: getRupeeString(recipeStaffMappingList[i]['SalaryCost']),
                                  textStyle: ts20M(ColorUtil.red2,fontsize: 18,fontfamily: 'AH'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )),
                  getTotalFooter("StaffCost"),
                ],
              ),
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
              onCancel: () {
                numPadUtils['isNumPadOpen'] = false;
                clearNumPadUtils();
              },
              numberTap: (e) {
                numPadUtils['numPadVal'] = e;
              },
              onDone: () {

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
    widgets['RecipeId']=HiddenController(dataname: "RecipeId");
    widgets["RecipeMaterialMappingList"]=HiddenController(dataname: "RecipeMaterialMappingList");
    widgets["RecipeStaffMappingList"]=HiddenController(dataname: "RecipeStaffMappingList");
    widgets["RecipeVesselMappingList"]=HiddenController(dataname: "RecipeVesselMappingList");
    widgets["TotalCost"]=HiddenController(dataname: "TotalCost");
    widgets["VesselEssentialCost"]=HiddenController(dataname: "VesselEssentialCost");
    widgets["StaffCost"]=HiddenController(dataname: "StaffCost");
    widgets["MaterialCost"]=HiddenController(dataname: "MaterialCost");
    widgets['YieldQuantity'] = AddNewLabelTextField(
      dataname: 'YieldQuantity',
      hasInput: true,
      required: true,
      labelText: "Yield Quantity",
      regExp: MyConstants.digitRegEx,
      textInputType: TextInputType.number,
      onChange: (v) {},
      onEditComplete: () {
        FocusScope.of(context).unfocus();
      },
    );
    widgets['RecipeName'] = AddNewLabelTextField(
      dataname: 'RecipeName',
      hasInput: true,
      required: true,
      labelText: "Recipe Name",
      regExp: null,
      onChange: (v) {},
      onEditComplete: () {
        FocusScope.of(context).unfocus();
      },
    );
    widgets['RecipeTypeId'] = SlideSearch(
        dataName: "RecipeTypeId",
        selectedValueFunc: (e) {console("RecipeTypeId $e");},
        hinttext: "Select Recipe Type",
        data: []);
    widgets['RecipeCategoryId'] = SlideSearch(
        dataName: "RecipeCategoryId",
        selectedValueFunc: onMaterialChange,
        hinttext: "Select Recipe Category",
        data: []);
    widgets['CuisineId'] = SlideSearch(
      dataName: "CuisineId",
      required: false,
      selectedValueFunc: (e) {},
      hinttext: "Select Cuisine",
      data: [],
    );
    widgets['UnitId'] = SlideSearch(
      dataName: "UnitId",
      required: true,
      selectedValueFunc: (e) {},
      hinttext: "Select Unit",
      data: [],
    );
    widgets['RecipeChefId'] = SlideSearch(
      dataName: "RecipeChefId",
      required: false,
      selectedValueFunc: (e) {},
      hinttext: "Select Recipe Chef",
      data: [],
    );

    widgets['PreParationTime'] = AddNewLabelTextField(
      dataname: 'PreParationTime',
      hasInput: true,
      required: true,
      labelText: "Preparation Time (hh:mm)",
      scrollPadding: 150,
      regExp: MyConstants.timeReg,
      textInputType: TextInputType.number,
      onChange: (v) {updateTimeFormat(widgets['PreParationTime'], v);},
      onEditComplete: () {
        FocusScope.of(context).unfocus();
      },
      suffixIcon: CustomCircle(
        hei: 45,
        margin: const EdgeInsets.only(right: 7, top: 7, bottom: 7),
        color: ColorUtil.red,
        widget: FittedBox(
          child: Text(
            // if (!widget.isEdit) {
            //   expectedDate.value = DateTime.now();
            //   needReturnQty.value = false;
            // } else {
            //   needReturnQty.value = true;
            // }
            " hr",
            style: ts20M(ColorUtil.themeWhite),
          ),
        ),
      ),
      minLength: 5,
      needMinLengthCheck: true,
    );

    materialForm['MaterialId'] = SlideSearch(
        dataName: "MaterialId",
        selectedValueFunc: onMaterialChange,
        hinttext: "Select Material",
        data: [],
      propertyName: "value",
    );
    materialForm['MaterialBrandId'] = SlideSearch(
        dataName: "MaterialBrandId",
        selectedValueFunc: (e) {    updateMPrice(e);},
        hinttext: "Select Material Brand",
        data: [],propertyName: "value",);
    materialForm['Quantity'] = AddNewLabelTextField(
      dataname: 'Quantity',
      hasInput: true,
      required: true,
      labelText: "Material Quantity",
      scrollPadding: 150,
      regExp: MyConstants.decimalReg,
      textInputType: TextInputType.number,
      onChange: (v) {},
      onEditComplete: () {
        FocusScope.of(context).unfocus();
      },
      suffixIcon: unitDropDown,
      textLength: MyConstants.maximumQty,
    );
    materialForm['MaterialPrice']=HiddenController(dataname: "MaterialPrice");

    staffForm['StaffCategoryId'] = SlideSearch(
        dataName: "StaffCategoryId",
        selectedValueFunc: (e) {},
        hinttext: "Select Staff Category",
        data: []);
    staffForm['TotalStaff'] = AddNewLabelTextField(
      dataname: 'TotalStaff',
      hasInput: true,
      required: true,
      labelText: "Count",
      regExp: MyConstants.digitRegEx,
      textInputType: TextInputType.number,
      onChange: (v) {},
      onEditComplete: () {
        FocusScope.of(context).unfocus();
      },
      textLength: MyConstants.maximumQty,
    );
    staffForm['WorkingTime'] = AddNewLabelTextField(
      dataname: 'WorkingTime',
      hasInput: true,
      required: true,
      labelText: "hh:mm",
      regExp: MyConstants.timeReg,
      textInputType: TextInputType.number,
      onChange: (v) {
        updateTimeFormat(staffForm['WorkingTime'],v);
      },
      onEditComplete: () {
        FocusScope.of(context).unfocus();
      },
      minLength: 5,
      needMinLengthCheck: true,
    );
    staffForm['SalaryCost'] = AddNewLabelTextField(
      dataname: 'SalaryCost',
      hasInput: true,
      required: true,
      labelText: "Cost",
      regExp: MyConstants.decimalReg,
      textInputType: TextInputType.number,
      onChange: (v) {},
      onEditComplete: () {
        FocusScope.of(context).unfocus();
      },
      textLength: MyConstants.maximumQty,
    );

    vesselForm['VesselId'] = SlideSearch(
        dataName: "VesselId",
        selectedValueFunc: (e) {vesselForm['UsageTime'].setValue("");vesselForm['VesselQuantity'].setValue("");onVesselIdChg(e);},
        hinttext: "Select",
        data: []);
    vesselForm['UsageTime'] = AddNewLabelTextField(
      dataname: 'UsageTime',
      hasInput: true,
      required: false,
      labelText: "UsageTime (hh:mm)",
      regExp: MyConstants.timeReg,
      onChange: (v) {updateTimeFormat(vesselForm['UsageTime'], v);},
      onEditComplete: () {
        FocusScope.of(context).unfocus();
      },
      minLength: 5,
      needMinLengthCheck: true,
    );
    vesselForm['VesselQuantity'] = AddNewLabelTextField(
      dataname: 'VesselQuantity',
      hasInput: true,
      required: false,
      labelText: "VesselQuantity",
      regExp: null,
      onChange: (v) {},
      onEditComplete: () {
        FocusScope.of(context).unfocus();
      },
      maxlines: null,
    );


    fillTreeDrp(widgets, "RecipeTypeId",
        page: page,
        spName: Sp.masterSp,
        extraParam: MyConstants.extraParam,
        refType: "",
        clearValues: false);
    fillTreeDrp(widgets, "RecipeCategoryId",
        page: page,
        spName: Sp.masterSp,
        extraParam: MyConstants.extraParam,
        refType: "",
        refId: "",clearValues: false);
    fillTreeDrp(widgets, "CuisineId",
        page: page,
        spName: Sp.masterSp,
        extraParam: MyConstants.extraParam,
        refType: "",
        refId: "",clearValues: false);
    fillTreeDrp(widgets, "UnitId",
        page: page,
        spName: Sp.masterSp,
        extraParam: MyConstants.extraParam,
        refType: "",
        refId: "",clearValues: false);
    fillTreeDrp(widgets, "RecipeChefId",
        page: page,
        spName: Sp.masterSp,
        extraParam: MyConstants.extraParam,
        refType: "",
        refId: "",clearValues: false);
    fillTreeDrp(vesselForm, "VesselId",
        page: page,
        spName: Sp.masterSp,
        extraParam: MyConstants.extraParam,
        refType: "",
        refId: "",clearValues: false);
    fillTreeDrp(staffForm, "StaffCategoryId",
        page: page,
        spName: Sp.masterSp,
        extraParam: MyConstants.extraParam,
        refType: "",
        refId: "",clearValues: false);
    fillTreeDrp(materialForm, "MaterialId",
        page: page,
        spName: Sp.masterSp,
        extraParam: MyConstants.extraParam,
        refType: "",
        refId: "",clearValues: false);


    await parseJson(widgets, "",
        dataJson: widget.dataJson,
        traditionalParam: traditionalParam,
        extraParam: MyConstants.extraParam,
        loader: showLoader, resCb: (e) {
      try {
        console("parseJson $e");
        if(e['Table'].length>0){
          totalCostDetail['MaterialCost']=e['Table'][0]['MaterialCost'];
          totalCostDetail['StaffCost']=e['Table'][0]['StaffCost'];
          totalCostDetail['VesselEssentialCost']=e['Table'][0]['VesselEssentialCost'];
          totalCostDetail['TotalCost']=e['Table'][0]['TotalCost'];
        }
        recipeMaterialMappingList.value=e['Table1'];
        recipeStaffMappingList.value=e['Table2'];
        recipeVesselMappingList.value=e['Table3'];
      } catch (e, t) {
        assignWidgetErrorToastLocal(e, t);
      }
    });
  }

  void onMaterialChange(e) {
    unitDropDown.clearValues();
    if (!checkNullEmpty(e['UnitId'])) {
      unitDropDown.setValue(getUnitIdNameList(e['UnitId'], e['UnitName'],value: e['UnitQuantityType']));
      if (unitDropDown.unitList.isNotEmpty) {
        unitDropDown.setValue(unitDropDown.unitList[0]);
        unitName.value = unitDropDown.selectedUnit.value['Text'];
      }
    }
    updateMPrice(e);
    fillTreeDrp(materialForm, "MaterialBrandId",
        page: page,
        spName: Sp.masterSp,
        extraParam: MyConstants.extraParam,
        refId: e['Id'],
        toggleRequired: true,
        needToDisable: true);
  }

  void updateMPrice(e){
    double mPrice=parseDouble(e['Price']);
    foundWidgetByKey(materialForm, "MaterialPrice",needSetValue: true,value: mPrice>0?mPrice:"");
  }

  void onMaterialAdd() async {
    List<ParamModel> a = await getFrmCollection(materialForm);
    if (a.isNotEmpty) {
      FocusScope.of(context).unfocus();
      Map mDrp = materialForm['MaterialId'].getValueMap();
      Map mbDrp = materialForm['MaterialBrandId'].getValueMap();
      var brandId = mbDrp.isEmpty ? null : mbDrp['Id'];

      double price=getUnitTypePrice(parseDouble(materialForm['MaterialPrice'].getValue()), unitDropDown.selectedUnit.value['Value']);
      double qty=parseDouble(materialForm['Quantity'].getValue());
      double cost=Calculation().mul(price, qty);

      int existsProductIndex = recipeMaterialMappingList.indexWhere((element) =>element['MaterialId'] == mDrp['Id'] && element['MaterialBrandId'] == brandId);
      if (existsProductIndex == -1) {
        var pObj = {
          "RecipeId": null,
          "MaterialId": mDrp['Id'],
          "MaterialName": mDrp['value'],
          "MaterialBrandId": brandId,
          "MaterialBrandName": brandId != null ? mbDrp['value'] : "",
          "UnitId": unitDropDown.selectedUnit.value['Id'],
          "UnitName": unitDropDown.selectedUnit.value['Text'],
          "Price": price,
          "Quantity": qty,
          "Cost": cost
        };
        recipeMaterialMappingList.add(pObj);
        totalCostCalc();
      } else {
        CustomAlert().cupertinoAlert("Material Already Exits");
      }
      clearAllV2(materialForm);
      unitDropDown.clearValues();
      unitName.value = "Unit";
    }
  }

  void onStaffAdd() async {
    List<ParamModel> a = await getFrmCollection(staffForm);
    if (a.isNotEmpty) {
      FocusScope.of(context).unfocus();
      Map sDrp = staffForm['StaffCategoryId'].getValueMap();
      console(sDrp);

      int existsIndex = recipeStaffMappingList.indexWhere((element) =>element['StaffCategoryId'] == sDrp['Id']);
      if (existsIndex == -1) {
        var pObj =   {
          "RecipeId": null,
          "StaffCategoryId": sDrp['Id'],
          "StaffCategoryName": sDrp['Text'],
          "TotalStaff": parseInt(staffForm['TotalStaff'].getValue()),
          "WorkingTime": staffForm['WorkingTime'].getValue(),
          "SalaryCost": parseDouble(staffForm['SalaryCost'].getValue()),
          "RecipeStaffMappingId": null
        };
        recipeStaffMappingList.add(pObj);
        totalCostCalc();
      } else {
        CustomAlert().cupertinoAlert("Staff Category Already Exits");
      }
      clearAllV2(staffForm);
    }
  }

  void onVesselAdd() async {
    List<ParamModel> a = await getFrmCollection(vesselForm);
    if (a.isNotEmpty) {
      FocusScope.of(context).unfocus();
      Map vDrp = vesselForm['VesselId'].getValueMap();
      console(vDrp);

      int existsIndex = recipeVesselMappingList.indexWhere((element) =>element['VesselId'] == vDrp['Id']);
      if (existsIndex == -1) {
        int qty= parseInt(vesselForm['VesselQuantity'].getValue());
        String usageTime=vesselForm['UsageTime'].getValue();
        double totalMinutes=0;
        if(usageTime.isNotEmpty){
          List a=usageTime.split(":");
          totalMinutes=Calculation().add(Calculation().mul(a[0], 60), a[1]);
        }
        double usageCost=Calculation().mul(perMinuteCost.value, totalMinutes);
        var pObj =   {
          "RecipeId": null,
          "VesselId":  vDrp['Id'],
          "VesselName": vDrp['Text'],
          "VesselCategoryName": vesselCategoryName.value,
          "VesselQuantity": qty,
          "EssentialTime": usageTime,
          "UsageCost": usageCost,
          "RecipeVesselMappingId": ""
        };

        recipeVesselMappingList.add(pObj);
        totalCostCalc();
      } else {
        CustomAlert().cupertinoAlert("Vessel Already Exits");
      }
      clearAllV2(vesselForm);
    }
  }

  var vesselCategoryId=0.obs;
  var vesselCategoryName="".obs;
  var perMinuteCost=(0.0).obs;
  void onVesselIdChg(e) async{
    vesselCategoryId.value=0;
    vesselCategoryName.value="";
    perMinuteCost.value=0.0;
    List<ParamModel> parameterList=await getParamEssential(extraParam: MyConstants.extraParam);
    parameterList.add(ParamModel(Key: "HiraricalId", Type: "String", Value: ""));
    parameterList.add(ParamModel(Key: "RefId", Type: "String", Value: e['Id']));
    parameterList.add(ParamModel(Key: "RefTypeName", Type: "String", Value: ""));
    parameterList.add(ParamModel(Key: "TypeName", Type: "String", Value: "PerMinuteCost"));
    parameterList.add(ParamModel(Key: "Page", Type: "String", Value: page));
    _flutterUtils.getInvoke(parameterList,loader: showLoader,url: "${GetBaseUrl()}/api/MaterialApi/GetUnit").then((value){
      if(value[0]){
        var parsed=jsonDecode(value[1]);
        if(parsed['Unit'].length>0){
          vesselCategoryId.value=parsed['Unit'][0]['VesselCategoryId'];
          vesselCategoryName.value=parsed['Unit'][0]['VesselCategoryName'];
          perMinuteCost.value=parseDouble(parsed['Unit'][0]['PerMinuteCost']);

        }
        console("$parsed");
      }
    });
  }

  void totalCostCalc(){
    var materialCost=recipeMaterialMappingList.fold(0.0, (previousValue, element) => Calculation().add(previousValue , element['Cost']));
    var staff=recipeStaffMappingList.fold(0.0, (previousValue, element) => Calculation().add(previousValue , element['SalaryCost']));
    var vessel=recipeVesselMappingList.fold(0.0, (previousValue, element) => Calculation().add(previousValue , element['UsageCost']));
    totalCostDetail['MaterialCost']=materialCost;
    totalCostDetail['StaffCost']=staff;
    totalCostDetail['VesselEssentialCost']=vessel;
    totalCostDetail['TotalCost']=Calculation().add3(totalCostDetail['MaterialCost'], totalCostDetail['StaffCost'], totalCostDetail['VesselEssentialCost']);
    totalCostDetail.refresh();
    totalCostDetail.forEach((key, value) {
      foundWidgetByKey(widgets, key,needSetValue: true,value:value );
    });

  }

  void deleteHandler(int type,int index){
    if(type==1){
      recipeMaterialMappingList.removeAt(index);
      recipeMaterialMappingList.refresh();
    }
    else if(type ==2){
      recipeVesselMappingList.removeAt(index);
      recipeVesselMappingList.refresh();
    }
    totalCostCalc();
  }

  void updateHandler(int type,int index){
    if(type==1){
    }
    totalCostCalc();
  }

  void clearNumPadUtils() {
    numPadUtils['numPadVal'] = "";
    numPadUtils['numPadTitle'] = "";
    numPadUtils['numPadSubTitle'] = "";
    numPadUtils['departmentIndex'] = -1;
    numPadUtils['productIndex'] = -1;
    numPadUtils['numPadType'] = 0;
  }

  Widget getTotalFooter(String key){
    return  Padding(
      padding: const EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("TOTAL",style: ts20M(ColorUtil.themeBlack,fontfamily: 'AH',fontWeight: FontWeight.bold,ls: 1),),
          Obx(() => Text(getRupeeString(totalCostDetail[key]),style: ts20M(ColorUtil.red2,fontfamily: 'AH',fontWeight: FontWeight.bold),)),
        ],
      ),
    );
  }
  Widget getCostCard(String title,var value){
    return   Container(
      height: ColorUtil.formContainerHeight,
      decoration: ColorUtil.formContBoxDec,
      margin: const EdgeInsets.only(left:15,right:15,bottom:5,),
      padding: const EdgeInsets.only(left: 15,right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FlexFittedText(
            text: title,
            textStyle: ts20M(ColorUtil.themeBlack),
          ),
          FlexFittedText(
            text: getRupeeString(value),
            textStyle: ts20M(ColorUtil.red2,fontWeight: FontWeight.bold,fontfamily: 'AH'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widgets.clear();
    materialForm.clear();
    vesselForm.clear();
    staffForm.clear();
    recipeMaterialMappingList.clear();
    clearOnDispose();
    super.dispose();
  }
}
