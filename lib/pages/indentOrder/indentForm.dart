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
import '../../widgets/customCheckBox.dart';
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

class IndentForm extends StatefulWidget {
  bool isEdit;
  Function? closeCb;
  String dataJson;
  IndentForm({Key? key,this.isEdit=false,this.closeCb,this.dataJson=""}) : super(key: key);

  @override
  State<IndentForm> createState() => _IndentFormState();
}

class _IndentFormState extends State<IndentForm> with HappyExtension,TickerProviderStateMixin implements HappyExtensionHelperCallback{

  Map widgets={};
  Map rawMaterialForm={};
  Map recipeForm={};
  String page="IndentOrder";

  Rxn<DateTime> expectedDate=Rxn<DateTime>();

  late TabController tabController;
  double scrollPadding=10;
  UnitDropDown unitDropDown=UnitDropDown();

  RxList<dynamic> materialMappingList=RxList<dynamic>();
  RxList<dynamic> recipeMappingList=RxList<dynamic>();
  RxList<dynamic> recipeInnerProductList=RxList<dynamic>();
  RxList<dynamic> recipeParentList=RxList<dynamic>();

  var isRawMatCartOpen=false.obs;
  var isRecipeCartOpen=false.obs;
  late SwipeActionController controller;

  final FlutterUtils _flutterUtils=FlutterUtils();

  @override
  void initState(){
    tabController=TabController(length: 2, vsync: this);
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
    getByIdSp: "IV_Indent_GetByIndentOrderIdDetail",
    insertSp: "IV_Indent_InsertIndentOrderDetail",
    updateSp: "IV_Indent_UpdateIndentOrderDetail"
  );

  var activeTab=0;
  var needApprovedQty=false.obs;
  var approvedQtyUnit="Unit".obs;
  int selectedIndex=-1;
  var sameAsActualQty=false.obs;

  var recipeNumPadOpen=false.obs;
  var recipeNumPadVal="".obs;
  var recipeNumPadTitle="".obs;
  var recipeNumPadSubTitle="".obs;
  int recipeEditIndex=-1;

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
                    title: "${widget.isEdit?"Update":"Add"} Indent Order",
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
                        LeftHeader(title: "Delivery Type"),
                        widgets['DeliveryTypeId'],
                        LeftHeader(title: "Reason"),
                        widgets['CustomReason'],
                        LeftHeader(title: "Expected Date"),
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
                        LeftHeader(title: "Department"),
                        widgets['DepartmentId'],
                        inBtwHei(height: 20),
                        Stack(
                          children: [
                            Container(
                              margin: MyConstants.LRPadding,
                              decoration: BoxDecoration(
                                border: Border.all(color: ColorUtil.red2),
                                borderRadius: BorderRadius.circular(7),
                                color: Color(0xffFCE2E2),
                              ),
                              child: TabBar(
                                  controller: tabController,
                                  unselectedLabelColor: ColorUtil.red2,
                                  unselectedLabelStyle: ts20M(ColorUtil.red2,fontsize: 18),
                                  labelStyle: ts20M(ColorUtil.themeWhite,fontsize: 18),
                                  onTap: (i){
                                    if(i!=activeTab && (materialMappingList.isNotEmpty || recipeMappingList.isNotEmpty)){
                                      CustomAlert(
                                          callback: (){
                                            activeTab=i;
                                            materialMappingList.clear();
                                            recipeMappingList.clear();
                                            recipeInnerProductList.clear();
                                            recipeParentList.clear();
                                          },
                                          cancelCallback: (){
                                            tabController.animateTo(activeTab);
                                          }
                                      ).yesOrNoDialog2("assets/icons/delete.svg", "Are you sure want to leave ?", true);
                                    }
                                    else{
                                      activeTab=i;
                                    }
                                    clearMaterialForm();
                                    clearRecipeForm();
                                  },
                                  indicator: BoxDecoration(
                                      color: ColorUtil.red2,
                                      borderRadius: BorderRadius.circular(7),
                                      boxShadow: [
                                        BoxShadow(
                                            color: ColorUtil.red2.withOpacity(0.2),
                                            spreadRadius: 5,
                                            blurRadius: 30,
                                            offset: Offset(0, 15)
                                        )
                                      ]
                                  ),
                                  tabs: [
                                    Tab(text: "Raw Material",iconMargin: EdgeInsets.zero,height: ColorUtil.formContainerHeight,),
                                    Tab(text: "Recipe",iconMargin: EdgeInsets.zero,height: ColorUtil.formContainerHeight,),
                                  ]
                              ),
                            ),
                            Visibility(
                              visible: widget.isEdit,
                              child: Container(
                                height: 65,
                                width: SizeConfig.screenWidth,
                                margin: MyConstants.LRPadding,
                                color: Colors.red.withOpacity(0.1),
                              ),
                            )
                          ],
                        ),
                        Container(
                          height: 570,
                          child: TabBarView(
                              controller: tabController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Obx(() => cartIcon(
                                              onTap:(){
                                                isRawMatCartOpen.value=true;
                                              },
                                              count: materialMappingList.length
                                          )),
                                        ],
                                      ),
                                    ),
                                    rawMaterialForm['MaterialId'],
                                    inBtwHei(height: 10),
                                    rawMaterialForm['MaterialBrandId'],
                                    inBtwHei(height: 10),
                                    rawMaterialForm['RequestedQuantity'],
                                    inBtwHei(height: 10),
                                    Obx(() => Visibility(
                                      visible: needApprovedQty.value,
                                      child: rawMaterialForm['ApprovedQuantity'],
                                    )),
                                    inBtwHei(height: 30),
                                    DoneBtn(onDone: onRawMaterialAdd, title: "Add"),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Obx(() => cartIcon(
                                              onTap:(){
                                                isRecipeCartOpen.value=true;
                                              },
                                              count: recipeParentList.length
                                          )),
                                        ],
                                      ),
                                    ),
                                    recipeForm['RecipeId'],
                                    inBtwHei(height: 10),
                                    recipeForm['RequestedQuantity'],
                                    inBtwHei(height: 10),
                                    Obx(() => Visibility(
                                      visible: needApprovedQty.value,
                                      child: recipeForm['ApprovedQuantity'],
                                    )),
                                    inBtwHei(height: 30),
                                    DoneBtn(onDone: onRecipeAdd, title: "Add"),
                                  ],
                                ),
                              ]
                          ),
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
              onSave: (){
                sysSubmit(widgets,
                    isEdit: widget.isEdit,
                    needCustomValidation: true,
                    traditionalParam: traditionalParam,
                    loader: showLoader,
                    onCustomValidation: (){
                      if(activeTab==0){
                        if(materialMappingList.isEmpty){
                          CustomAlert().cupertinoAlert("Select Material to raise Indent...");
                          return false;
                        }
                        foundWidgetByKey(widgets, "IndentOrderMaterialMappingListJson",needSetValue: true,value: jsonEncode(materialMappingList));
                      }
                      else if(activeTab==1){
                        if(recipeMappingList.isEmpty){
                          CustomAlert().cupertinoAlert("Select Recipe to raise Indent...");
                          return false;
                        }
                        foundWidgetByKey(widgets, "IndentOrderMaterialMappingListJson",needSetValue: true,value: jsonEncode(recipeMappingList));
                      }
                      foundWidgetByKey(widgets, "IndentMaterialTypeId",needSetValue: true,value: tabController.index+1);
                      foundWidgetByKey(widgets, "CustomDate",needSetValue: true,value: DateFormat(MyConstants.dbDateFormat).format(expectedDate.value!));
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
              transform:  Matrix4.translationValues(isRawMatCartOpen.value? 0:SizeConfig.screenWidth!, 0, 0),
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
                              isRawMatCartOpen.value=false;
                            },
                          ),
                          Text("Back",style: ts20M(ColorUtil.themeBlack,fontsize: 18),),
                        ],
                      ),
                      FlexFittedText(
                        flex: 3,
                        text: "Materials (${materialMappingList.length} Numbers)",
                        textStyle: ts20M(ColorUtil.themeBlack,fontsize: 18),
                      ),
                    ],
                  ),
                  inBtwHei(height: 15),
                  Row(
                    children: [
                      GridTitleCard(
                        width: needApprovedQty.value?col1Wid:col1Wid+col3Wid,
                        content: "Material Name",
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
                  Obx(() => Visibility(
                    visible: needApprovedQty.value,
                    child: Obx(() => CustomCheckBox(
                      isSelect: sameAsActualQty.value,
                      content:"Same As Requested Quantity",
                      margin: const EdgeInsets.fromLTRB(0, 10, 0,10),
                      ontap: (){
                        sameAsActualQty.value=!sameAsActualQty.value;
                        onChkBoxChg();
                      },
                      selectColor: ColorUtil.red2,
                    )),
                  )),
                  Expanded(
                    child: ListView.builder(
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
                                recipeEditIndex=i;
                                recipeNumPadOpen.value=true;
                                recipeNumPadVal.value=needApprovedQty.value?materialMappingList[i]['ApprovedQuantity'].toString():
                                materialMappingList[i]['RequestedQuantity'].toString();
                                recipeNumPadVal.value=parseDouble(recipeNumPadVal.value)>0?recipeNumPadVal.value:"";
                                recipeNumPadTitle.value=materialMappingList[i]['MaterialName'];
                                recipeNumPadSubTitle.value=needApprovedQty.value?'Approved Quantity':'Requested Quantity';
                                selectedIndex=-1;
                                controller.closeAllOpenCell();
                              }),
                              swipeActionDelete((handler) async {
                                materialMappingList.removeAt(i);
                                await handler(true);
                              }),
                            ],
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 0),
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              decoration:ColorUtil.formContBoxDec,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width:needApprovedQty.value?col1Wid:col1Wid+col2Wid-11,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("${materialMappingList[i]['MaterialName']}",
                                          style: ts20M(ColorUtil.themeBlack,fontsize: 18),
                                        ),
                                        Text("${materialMappingList[i]['MaterialBrandName']}",
                                          style: ts20M(ColorUtil.red2,fontsize: 15),
                                        ),
                                      ],
                                    ),
                                  ),
                                  FittedText(
                                    height: 25,
                                    width:col2Wid-11,
                                    alignment: Alignment.centerLeft,
                                    text: "${materialMappingList[i]['RequestedQuantity']} ${materialMappingList[i]['UnitName']}",
                                    textStyle: ts20M(ColorUtil.red2,fontsize: 18),
                                  ),
                                  Visibility(
                                    visible: needApprovedQty.value,
                                    child: FittedText(
                                      height: 25,
                                      width:col2Wid-11,
                                      alignment: Alignment.centerLeft,
                                      text: "${materialMappingList[i]['ApprovedQuantity']} ${materialMappingList[i]['UnitName']}",
                                      textStyle: ts20M(ColorUtil.text1,fontsize: 18),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            )),

            Obx(() => AnimatedContainer(
              duration: MyConstants.animeDuration,
              curve: MyConstants.animeCurve,
              width: SizeConfig.screenWidth,
              height: SizeConfig.screenHeight,
              transform:  Matrix4.translationValues(isRecipeCartOpen.value? 0:SizeConfig.screenWidth!, 0, 0),
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
                              selectedIndex=-1;
                              recipeInnerProductList.clear();
                              isRecipeCartOpen.value=false;
                            },
                          ),
                          Text("Back",style: ts20M(ColorUtil.themeBlack,fontsize: 18),),
                        ],
                      ),
                      FlexFittedText(
                        flex: 3,
                        text: "Recipe (${recipeParentList.length} Numbers)",
                        textStyle: ts20M(ColorUtil.themeBlack,fontsize: 18),
                      ),
                    ],
                  ),
                  inBtwHei(height: 15),

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
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: recipeParentList.length,
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
                                recipeEditIndex=i;
                                recipeNumPadOpen.value=true;
                                recipeNumPadVal.value=needApprovedQty.value?recipeParentList[i]['ApprovedQuantity'].toString():
                                recipeParentList[i]['RequestedQuantity'].toString();
                                recipeNumPadVal.value=parseDouble(recipeNumPadVal.value)>0?recipeNumPadVal.value:"";
                                recipeNumPadTitle.value=recipeParentList[i]['RecipeName'];
                                recipeNumPadSubTitle.value=needApprovedQty.value?'Approved Quantity':'Requested Quantity';
                                selectedIndex=-1;
                                controller.closeAllOpenCell();
                              }),
                              swipeActionDelete((handler) async {
                                recipeMappingList.removeWhere((element) => element['RecipeId']==recipeParentList[i]['RecipeId']);
                                if(selectedIndex!=-1){
                                  selectedIndex=-1;
                                }
                                recipeParentList.removeAt(i);
                                recipeInnerProductList.clear();
                                await handler(true);
                              }),
                            ],
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap:(){
                                    if(selectedIndex==i){
                                      selectedIndex=-1;
                                      recipeInnerProductList.clear();
                                    }
                                    else {
                                      selectedIndex=i;
                                      recipeInnerProductList.value=recipeMappingList.where((p0) => p0['ParentId'].toString()==recipeParentList[i]['ParentPrimaryId'].toString()).toList();
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
                                              Text("${recipeParentList[i]['RecipeName']}",
                                                style: ts20M(ColorUtil.themeBlack,fontsize: 18),
                                              ),
                                            ],
                                          ),
                                        ),
                                        FittedText(
                                          height: 25,
                                          width:col2Wid-11,
                                          alignment: Alignment.centerLeft,
                                          text: "${recipeParentList[i]['RequestedQuantity']} ${recipeParentList[i]['UnitName']}",
                                          textStyle: ts20M(ColorUtil.red2,fontsize: 18),
                                        ),
                                        Visibility(
                                          visible: needApprovedQty.value,
                                          child: FittedText(
                                            height: 25,
                                            width:col2Wid-31,
                                            alignment: Alignment.centerLeft,
                                            text: "${recipeParentList[i]['ApprovedQuantity']} ${recipeParentList[i]['UnitName']}",
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
                                ExpandedSection(
                                  expand: selectedIndex==i,
                                  child: ListView.builder(
                                    itemCount: recipeInnerProductList.length,
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
                                                  Text("${recipeInnerProductList[index]['MaterialName']}",
                                                    style: ts20M(ColorUtil.themeBlack,fontsize: 18),
                                                  ),
                                                  Text("${recipeInnerProductList[index]['MaterialBrandName']}",
                                                    style: ts20M(ColorUtil.red2,fontsize: 15),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            FittedText(
                                              height: 25,
                                              width:col2Wid-11,
                                              alignment: Alignment.centerLeft,
                                              text: "${recipeInnerProductList[index]['RequestedQuantity']} ${recipeInnerProductList[index]['UnitName']}",
                                              textStyle: ts20M(ColorUtil.red2,fontsize: 18),
                                            ),
                                            Visibility(
                                              visible: needApprovedQty.value,
                                              child: FittedText(
                                                height: 25,
                                                width:col2Wid-11,
                                                alignment: Alignment.centerLeft,
                                                text: "${recipeInnerProductList[index]['ApprovedQuantity']} ${recipeInnerProductList[index]['UnitName']}",
                                                textStyle: ts20M(ColorUtil.text1,fontsize: 18),
                                              ),
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
                    ),
                  )
                ],
              ),
            )),

            Obx(() => Blur(value: recipeNumPadOpen.value,)),

            Obx(() => NumberPadPopUp(
              isSevenInch: true,
              isOpen: recipeNumPadOpen.value,
              value: recipeNumPadVal.value,
              title: recipeNumPadTitle.value,
              subTitle: recipeNumPadSubTitle.value,
              onCancel: (){
                recipeNumPadOpen.value=false;
              },
              numberTap: (e){
                recipeNumPadVal.value=e;
              },
              onDone: (){
                if(activeTab==0){
                  onMaterialUpdate();
                }
                else if(activeTab==1){
                  onRecipeUpdate();
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
    widgets['IndentOrderMaterialMappingListJson']=HiddenController(dataname: "IndentOrderMaterialMappingListJson");
    widgets['IndentMaterialTypeId']=HiddenController(dataname: "IndentMaterialTypeId");
    widgets['Notes']=HiddenController(dataname: "Notes");
    widgets['CustomDate']=HiddenController(dataname: "CustomDate");
    widgets['IsApproveRejectPermission']=HiddenController(dataname: "IsApproveRejectPermission");
    widgets['IndentOrderId']=HiddenController(dataname: "IndentOrderId");
    widgets['FromStoreName']=HE_Text(dataname: "FromStoreName", contentTextStyle: ts20M(ColorUtil.themeWhite));
    widgets['ToStoreId']=SlideSearch(dataName: "ToStoreId", selectedValueFunc: (e){}, hinttext: "Select To Store",data: [],);
    widgets['DeliveryTypeId']=SearchDrp2(map:  {"dataName":"DeliveryTypeId","hintText":"Select Delivery Type","labelText":"Delivery Type","showSearch":false,"mode":Mode.DIALOG,"dialogMargin":const EdgeInsets.all(0.0)},);
    widgets['CustomReason']=AddNewLabelTextField(
      dataname: 'CustomReason',
      hasInput: true,
      required: false,
      labelText: "Reason",
      scrollPadding: scrollPadding,
      regExp: null,
      onChange: (v){},
      onEditComplete: (){
        FocusScope.of(context).unfocus();
      },
      maxlines: null,
    );
    widgets['DepartmentId']=SlideSearch(dataName: "DepartmentId",required: false, selectedValueFunc: (e){}, hinttext: "Select Department",data: [],);

    rawMaterialForm['MaterialId']=SlideSearch(dataName: "MaterialId",
      selectedValueFunc: (e){
        console(e);
        onMaterialChange(e);
      },
      hinttext: "Select Material",data: [],propertyId: "MaterialId",propertyName: "MaterialName",);
    rawMaterialForm['MaterialBrandId']=SlideSearch(dataName: "MaterialBrandId",required: false,
      selectedValueFunc: (e){}, hinttext: "Select Material Brand",data: []);
    rawMaterialForm['RequestedQuantity']=AddNewLabelTextField(
      dataname: 'RequestedQuantity',
      hasInput: true,
      required: true,
      labelText: "Requested Quantity",
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
    rawMaterialForm['ApprovedQuantity']=AddNewLabelTextField(
      dataname: 'ApprovedQuantity',
      hasInput: true,
      required: false,
      labelText: "Approved Quantity",
      scrollPadding: 150,
      regExp: MyConstants.decimalReg,
      textInputType: TextInputType.number,
      onChange: (v){},
      onEditComplete: (){
        FocusScope.of(context).unfocus();
      },
      suffixIcon:Container(
        width: 100,
        height: 45,
        margin: const EdgeInsets.only(top: 10,bottom: 10,right: 5),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color: ColorUtil.red),
        alignment: Alignment.center,
        child: Obx(() => Text("${approvedQtyUnit.value}",style: ts20M(ColorUtil.themeWhite),)),
      ),
      textLength: MyConstants.maximumQty,
    );

    recipeForm['RecipeId']=SlideSearch(dataName: "RecipeId",
      selectedValueFunc: (e){
        console(e);
        onRecipeChange(e);
      },
      hinttext: "Select Recipe",data: [],propertyId: "RecipeId",propertyName: "RecipeName",);
    recipeForm['RequestedQuantity']=AddNewLabelTextField(
      dataname: 'RequestedQuantity',
      hasInput: true,
      required: true,
      labelText: "Requested Quantity",
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
    recipeForm['ApprovedQuantity']=AddNewLabelTextField(
      dataname: 'ApprovedQuantity',
      hasInput: true,
      required: false,
      labelText: "Approved Quantity",
      scrollPadding: 150,
      regExp: MyConstants.decimalReg,
      textInputType: TextInputType.number,
      onChange: (v){},
      onEditComplete: (){
        FocusScope.of(context).unfocus();
      },
      suffixIcon:Container(
        width: 100,
        height: 45,
        margin: const EdgeInsets.only(top: 10,bottom: 10,right: 5),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color: ColorUtil.red),
        alignment: Alignment.center,
        child: Obx(() => Text("${approvedQtyUnit.value}",style: ts20M(ColorUtil.themeWhite),)),
      ),
      textLength: MyConstants.maximumQty,
    );

    if(!widget.isEdit){
      widgets['FromStoreId'].setValue(await getSharedPrefStringUtil(SP_STOREID));
      widgets['FromStoreName'].setValue(await getSharedPrefStringUtil(SP_STORENAME));
      expectedDate.value=DateTime.now();
      needApprovedQty.value=false;
      fillTreeDrp(widgets, "ToStoreId",refId: await getSharedPrefStringUtil(SP_STOREID),page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "",clearValues: false);
    }


    fillTreeDrp(widgets, "DeliveryTypeId",refId: await getSharedPrefStringUtil(SP_STOREID),page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "",clearValues: false);
    fillTreeDrp(widgets, "DepartmentId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "",clearValues: false);

    fillTreeDrp(rawMaterialForm, "MaterialId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "RawMaterial",clearValues: false);
    fillTreeDrp(recipeForm, "RecipeId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "Recipe",clearValues: false);

    await parseJson(widgets, "",dataJson: widget.dataJson,traditionalParam: traditionalParam,extraParam: MyConstants.extraParam,loader: showLoader,
    resCb: (e){
      try{
        console("parseJson $e");
        fillTreeDrp(widgets, "ToStoreId",refId: e['Table'][0]['FromStoreId'],page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "",clearValues: false);
        expectedDate.value=DateTime.parse(e['Table'][0]['CustomDate']);
        needApprovedQty.value=e['Table'][0]['IsApproveRejectPermission'];
        if(e['Table'][0]['IndentMaterialTypeId']==1){
          activeTab=0;
          materialMappingList.value=e['Table1'];
        }
        else if(e['Table'][0]['IndentMaterialTypeId']==2){
          tabController.animateTo(1);
          activeTab=1;
          recipeMappingList.value=e['Table1'];
          recipeMappingList.where((element) => element['ParentId'].toString()=="0").toList().forEach((element) {
            recipeParentList.add(element);
          });
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
        approvedQtyUnit.value= unitDropDown.selectedUnit.value['Text'];
      }
    }
    fillTreeDrp(rawMaterialForm, "MaterialBrandId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,
        refType: "MaterialId",refId: e['MaterialId'],toggleRequired: true,needToDisable: true);
  }

  void onRawMaterialAdd() async{
    List<ParamModel> a=await getFrmCollection(rawMaterialForm);
    print(a.map((e) => e.toJson()));
    if(a.isNotEmpty){
      Map mDrp=rawMaterialForm['MaterialId'].getValueMap();
      Map mbDrp=rawMaterialForm['MaterialBrandId'].getValueMap();
      var brandId=mbDrp.isEmpty?null:mbDrp['Id'];
      console(mDrp);
      console(mbDrp);
      double aprQty=parseDouble(rawMaterialForm['ApprovedQuantity'].getValue(),);

      int existIndex = materialMappingList.indexWhere((e) => e['MaterialId'] == mDrp['MaterialId'] && e['MaterialBrandId'] == brandId);
      if (existIndex != -1) {
        CustomAlert().cupertinoAlert("Material Already Exists");
        return;
      }
      if(needApprovedQty.value && aprQty<=0){
        CustomAlert().cupertinoAlert("Enter Approved Quantity");
        return;
      }
      var obj = {
        "RNo": materialMappingList.length + 1,
        "IndentOrderMaterialMappingId": null,
        "RecipeId": null,
        "RecipeName": "",
        "MaterialId": mDrp['MaterialId'],
        "MaterialName": mDrp['MaterialName'],
        "MaterialBrandId": brandId,
        "MaterialBrandName": brandId!=null ? mbDrp['value'] : "",
        "UnitId": unitDropDown.selectedUnit.value['Id'],
        "UnitName": unitDropDown.selectedUnit.value['Text'],
        "RequestedQuantity": parseDouble(rawMaterialForm['RequestedQuantity'].getValue()),
        "ParentId": "0",
        "ParentPrimaryId": null,
        "ApprovedQuantity": aprQty
      };
      print(obj);
      materialMappingList.add(obj);
      clearMaterialForm();
    }
  }

  void onMaterialUpdate(){
    double recQty=0.0;
    double appQty=0.0;
    double qty=parseDouble(recipeNumPadVal.value);
    if(needApprovedQty.value){
      if(qty<=0){
        CustomAlert().cupertinoAlert("Enter Approved Quantity");
        return;
      }
      recQty=parseDouble(materialMappingList[recipeEditIndex]['RequestedQuantity']);
      if(qty>recQty){
        CustomAlert().cupertinoAlert("Approved Quantity Should be less than Requested Quantity ($recQty)...");
        return;
      }
      appQty=qty;
      materialMappingList[recipeEditIndex]['ApprovedQuantity']=appQty;
    }
    else{
      if(qty<=0){
        CustomAlert().cupertinoAlert("Enter Requested Quantity");
        return;
      }
      recQty=qty;
      materialMappingList[recipeEditIndex]['RequestedQuantity']=recQty;
    }
    recipeNumPadOpen.value=false;
    recipeEditIndex=-1;
    materialMappingList.refresh();
  }

  void onChkBoxChg(){
    if(sameAsActualQty.value){
      for (var pd in materialMappingList) {
        pd['ApprovedQuantity']=parseDouble(pd['RequestedQuantity']);
      }
      materialMappingList.refresh();
    }
  }
  void onRecipeChange(e){
    unitDropDown.clearValues();
    if(!checkNullEmpty(e['UnitId'])){
      unitDropDown.setValue([{"Id":e['UnitId'], "Text":e['UnitName']}]);
      if(unitDropDown.unitList.isNotEmpty){
        unitDropDown.setValue(unitDropDown.unitList[0]);
        approvedQtyUnit.value= unitDropDown.selectedUnit.value['Text'];
      }
    }
  }

  void onRecipeAdd() async{
    List<ParamModel> a=await getFrmCollection(recipeForm);
    if(a.isNotEmpty){
      Map rDrp=recipeForm['RecipeId'].getValueMap();
      double qty=parseDouble(recipeForm['RequestedQuantity'].getValue());
     // print(recipeMappingList);
      int existIndex = recipeMappingList.indexWhere((e) => e['RecipeId'] == rDrp['RecipeId']);
      if (existIndex != -1) {
        CustomAlert().cupertinoAlert("Recipe Already Exists");
        return;
      }

      double aprQty=parseDouble(recipeForm['ApprovedQuantity'].getValue(),);
      if(needApprovedQty.value && aprQty<=0){
        CustomAlert().cupertinoAlert("Enter Approved Quantity");
        return;
      }

      if(needApprovedQty.value && aprQty>qty){
        CustomAlert().cupertinoAlert("Approved Quantity Should be less than Requested Quantity...");
        return;
      }

      List<ParamModel> parameterList=await getParamEssential(extraParam: MyConstants.extraParam);
      parameterList.add(ParamModel(Key: "RecipeId", Type: "String", Value: rDrp['RecipeId']));
      parameterList.add(ParamModel(Key: "RequestedQty", Type: "String", Value: qty));
      parameterList.add(ParamModel(Key: "ApprovedQuantity", Type: "String", Value:needApprovedQty.value?aprQty: null));
      _flutterUtils.getInvoke(parameterList,loader: showLoader,url: "${GetBaseUrl()}/api/IndentApi/GetRecipeDetail").then((value){
        if(value[0]){
          var parsed=jsonDecode(value[1]);
          List<dynamic> recipeList=parsed['Table'];
          recipeMappingList.addAll(recipeList);
          recipeParentList.add(recipeList.where((element) => element['ParentId'].toString()=="0").toList()[0]);
          clearRecipeForm();
        }
      });
    }
  }

  void onRecipeUpdate() async{
    double recQty=0.0;
    double appQty=0.0;
    double qty=parseDouble(recipeNumPadVal.value);
    if(needApprovedQty.value){
      if(qty<=0){
        CustomAlert().cupertinoAlert("Enter Approved Quantity");
        return;
      }
      recQty=parseDouble(recipeParentList[recipeEditIndex]['RequestedQuantity']);
      if(qty>recQty){
        CustomAlert().cupertinoAlert("Approved Quantity Should be less than Requested Quantity ($recQty)...");
        return;
      }
      appQty=qty;
    }
    else{
      if(qty<=0){
        CustomAlert().cupertinoAlert("Enter Requested Quantity");
        return;
      }
      recQty=qty;
    }
    recipeNumPadOpen.value=false;
    List<ParamModel> parameterList=await getParamEssential(extraParam: MyConstants.extraParam);
    parameterList.add(ParamModel(Key: "RecipeId", Type: "String", Value: recipeParentList[recipeEditIndex]['RecipeId']));
    parameterList.add(ParamModel(Key: "RequestedQty", Type: "String", Value: recQty));
    parameterList.add(ParamModel(Key: "ApprovedQuantity", Type: "String", Value:needApprovedQty.value?appQty: null));
    _flutterUtils.getInvoke(parameterList,loader: showLoader,url: "${GetBaseUrl()}/api/IndentApi/GetRecipeDetail").then((value){
      if(value[0]){
        var parsed=jsonDecode(value[1]);
        List<dynamic> recipeList=parsed['Table'];
        recipeMappingList.removeWhere((element) => element['RecipeId']==recipeParentList[recipeEditIndex]['RecipeId']);
        recipeMappingList.addAll(recipeList);
        recipeParentList[recipeEditIndex]=recipeList.where((element) => element['ParentId'].toString()=="0").toList()[0];
        recipeEditIndex=-1;
      }
    });
  }

  void clearMaterialForm(){
    clearAllV2(rawMaterialForm);
    unitDropDown.clearValues();
    approvedQtyUnit.value="Unit";
    FocusScope.of(context).unfocus();
  }
  void clearRecipeForm(){
    clearAllV2(recipeForm);
    unitDropDown.clearValues();
    approvedQtyUnit.value="Unit";
    FocusScope.of(context).unfocus();
  }





  @override
  void dispose(){
    widgets.clear();
    rawMaterialForm.clear();
    recipeForm.clear();
    clearOnDispose();
    tabController.dispose();
    recipeParentList.clear();
    recipeInnerProductList.clear();
    recipeMappingList.clear();
    materialMappingList.clear();
    super.dispose();
  }
}


