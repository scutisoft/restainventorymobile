import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/model/parameterModel.dart';
import 'package:flutter_utils/utils/apiUtils.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:flutter_utils/utils/extensionUtils.dart';
import 'package:flutter_utils/utils/utils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restainventorymobile/widgets/expandedSection.dart';
import 'package:restainventorymobile/widgets/fittedText.dart';
import 'package:restainventorymobile/widgets/loader.dart';
import '../../api/apiUtils.dart';
import '../../helper/language.dart';
import '../../widgets/arrowAnimation.dart';
import '../../widgets/swipe2/core/cell.dart';
import '../../widgets/swipe2/core/controller.dart';
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
  IndentForm({Key? key,this.isEdit=false,this.closeCb}) : super(key: key);

  @override
  State<IndentForm> createState() => _IndentFormState();
}

class _IndentFormState extends State<IndentForm> with HappyExtension,TickerProviderStateMixin implements HappyExtensionHelperCallback{

  Map widgets={};
  Map rawMaterialForm={};
  Map recipeForm={};
  String page="IndentOrder";

  Rxn<DateTime> donationDate=Rxn<DateTime>();

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
  bool needApprovedQty=false;
  int selectedIndex=-1;

  @override
  Widget build(BuildContext context) {
    isKeyboardVisible.value = MediaQuery.of(context).viewInsets.bottom != 0;
    return PageBody(
        body: Stack(
          children: [
            Container(
              height: SizeConfig.screenHeight,
              width: SizeConfig.screenWidth,
              child: Column(
                children: [
                  CustomAppBar(
                    title: "Add Indent Order",
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
                                  initialDate:  donationDate.value==null?DateTime.now():donationDate.value!, // Refer step 1
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
                                donationDate.value=picked;
                              }
                            },
                            child: Obx(() =>  ExpectedDateContainer(
                              text: donationDate.value ==null?"Select Date": "${DateFormat.yMMMd().format(donationDate.value!)}",
                            ))
                        ),
                        LeftHeader(title: "Department"),
                        widgets['DepartmentId'],
                        inBtwHei(height: 20),
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
                                print("iii $i ${tabController.index}");
                                if(i!=activeTab && materialMappingList.isNotEmpty){
                                  CustomAlert(
                                    callback: (){
                                      activeTab=i;
                                      materialMappingList.clear();
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
                        Container(
                          height: 500,
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
            Positioned(
              bottom: 0,
              child: Obx(() => Container(
                margin: const EdgeInsets.only(top: 0,bottom: 0),
                height: isKeyboardVisible.value?0:70,
                width: SizeConfig.screenWidth,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: (){
                        Get.back();
                      },
                      child: Container(
                        width: SizeConfig.screenWidth!*0.4,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: ColorUtil.primary),
                          color: ColorUtil.primary.withOpacity(0.3),
                        ),
                        child:Center(child: Text(Language.cancel,style: ts16(ColorUtil.primary,), )) ,
                      ),
                    ),
                    GestureDetector(
                      onTap: (){


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
                              foundWidgetByKey(widgets, "CustomDate",needSetValue: true,value: DateFormat(MyConstants.dbDateFormat).format(donationDate.value!));
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
                      child: Container(
                        width: SizeConfig.screenWidth!*0.4,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: ColorUtil.primary,
                        ),
                        child:Center(child: Text(Language.save,style: ts16(ColorUtil.themeWhite,), )) ,
                      ),
                    ),
                  ],
                ),
              )),
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
                        width: col1Wid,
                        content: "Material Name",
                      ),
                      GridTitleCard(
                        width: col2Wid,
                        content: "Requested Qty",
                      ),
                      GridTitleCard(
                        width: col3Wid,
                        content: "Approved Qty",
                      ),
                    ],
                  ),
                  inBtwHei(height: 15),
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
                              SwipeAction(
                                title: "",
                                icon: Padding(
                                  padding:  EdgeInsets.only(top: 11),
                                  child: SvgPicture.asset("assets/icons/delete.svg",
                                    color: ColorUtil.themeWhite,height: 30,),
                                ),
                                onTap: (handler) async {
                                  materialMappingList.removeAt(i);
                                  await handler(true);

                                 /* updateSlideItemIndex(-1);
                                  onProductDelete(c_orderDetail.value!.productList![index].productId);*/

                                },
                                color: ColorUtil.red2,
                              ),
                            ],
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 0),
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                                  FittedText(
                                    height: 25,
                                    width:col2Wid-11,
                                    alignment: Alignment.centerLeft,
                                    text: "${materialMappingList[i]['ApprovedQuantity']} ${materialMappingList[i]['UnitName']}",
                                    textStyle: ts20M(ColorUtil.text1,fontsize: 18),
                                  ),

                                ],
                              ),
                            ),
                          ),
                        );
                        return Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                              FittedText(
                                height: 25,
                                width:col2Wid-11,
                                alignment: Alignment.centerLeft,
                                text: "${materialMappingList[i]['ApprovedQuantity']} ${materialMappingList[i]['UnitName']}",
                                textStyle: ts20M(ColorUtil.red2,fontsize: 18),
                              ),

                            ],
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
                        width: col1Wid,
                        content: "Recipe Name",
                      ),
                      GridTitleCard(
                        width: col2Wid,
                        content: "Requested Qty",
                      ),
                      GridTitleCard(
                        width: col3Wid,
                        content: "Approved Qty",
                      ),
                    ],
                  ),
                  inBtwHei(height: 15),
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
                              SwipeAction(
                                title: "",
                                icon: Padding(
                                  padding:  EdgeInsets.only(top: 11),
                                  child: SvgPicture.asset("assets/icons/delete.svg",
                                    color: ColorUtil.themeWhite,height: 30,),
                                ),
                                onTap: (handler) async {
                                  // recipeParentList.removeAt(i);
                                  // await handler(true);

                                  /* updateSlideItemIndex(-1);
                                  onProductDelete(c_orderDetail.value!.productList![index].productId);*/

                                },
                                color: ColorUtil.red2,
                              ),
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
                                    padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                                    decoration:ColorUtil.formContBoxDec,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width:col1Wid,
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
                                        FittedText(
                                          height: 25,
                                          width:col2Wid-31,
                                          alignment: Alignment.centerLeft,
                                          text: "${recipeParentList[i]['ApprovedQuantity']} ${recipeParentList[i]['UnitName']}",
                                          textStyle: ts20M(ColorUtil.text1,fontsize: 18),
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
                                              width:col1Wid,
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
                                            FittedText(
                                              height: 25,
                                              width:col2Wid-11,
                                              alignment: Alignment.centerLeft,
                                              text: "${recipeInnerProductList[index]['ApprovedQuantity']} ${recipeInnerProductList[index]['UnitName']}",
                                              textStyle: ts20M(ColorUtil.text1,fontsize: 18),
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

            Obx(() => Loader(value: showLoader.value,)),
          ],
        )
    );
  }



  @override
  void assignWidgets() async{
    widgets.clear();
    widgets['FromStoreId']=HiddenController(dataname: "FromStoreId");
    widgets['IndentOrderMaterialMappingListJson']=HiddenController(dataname: "IndentOrderMaterialMappingListJson");
    widgets['IndentMaterialTypeId']=HiddenController(dataname: "IndentMaterialTypeId");
    widgets['Notes']=HiddenController(dataname: "Notes");
    widgets['CustomDate']=HiddenController(dataname: "CustomDate");
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

    if(!widget.isEdit){
      widgets['FromStoreId'].setValue(await getSharedPrefStringUtil(SP_STOREID));
      widgets['FromStoreName'].setValue(await getSharedPrefStringUtil(SP_STORENAME));
      donationDate.value=DateTime.now();
    }

    fillTreeDrp(widgets, "ToStoreId",refId: await getSharedPrefStringUtil(SP_STOREID),page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "");
    fillTreeDrp(widgets, "DeliveryTypeId",refId: await getSharedPrefStringUtil(SP_STOREID),page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "");
    fillTreeDrp(widgets, "DepartmentId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "");

    fillTreeDrp(rawMaterialForm, "MaterialId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "RawMaterial");
    fillTreeDrp(recipeForm, "RecipeId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "Recipe");
  }

  void onMaterialChange(e){
    unitDropDown.clearValues();
    if(!checkNullEmpty(e['UnitId'])){
      unitDropDown.setValue(getUnitIdNameList(e['UnitId'], e['UnitName']));
      if(unitDropDown.unitList.isNotEmpty){
        unitDropDown.setValue(unitDropDown.unitList[0]);
      }
    }
    fillTreeDrp(rawMaterialForm, "MaterialBrandId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,
        refType: "MaterialId",refId: e['MaterialId'],toggleRequired: true);
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
      int existIndex = materialMappingList.indexWhere((e) => e['MaterialId'] == mDrp['MaterialId'] && e['MaterialBrandId'] == brandId);
      if (existIndex != -1) {
        CustomAlert().cupertinoAlert("Material Already Exists");
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
        "ApprovedQuantity": ""
      };
      print(obj);
      materialMappingList.add(obj);
      clearMaterialForm();
    }
  }

  void onRecipeChange(e){
    unitDropDown.clearValues();
    if(!checkNullEmpty(e['UnitId'])){
      unitDropDown.setValue([{"Id":e['UnitId'], "Text":e['UnitName']}]);
      if(unitDropDown.unitList.isNotEmpty){
        unitDropDown.setValue(unitDropDown.unitList[0]);
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
      List<ParamModel> parameterList=await getParamEssential(extraParam: MyConstants.extraParam);
      parameterList.add(ParamModel(Key: "RecipeId", Type: "String", Value: rDrp['RecipeId']));
      parameterList.add(ParamModel(Key: "RequestedQty", Type: "String", Value: qty));
      parameterList.add(ParamModel(Key: "ApprovedQuantity", Type: "String", Value: null));
      FlutterUtils().getInvoke(parameterList,loader: showLoader,url: "${GetBaseUrl()}/api/IndentApi/GetRecipeDetail").then((value){
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

  void clearMaterialForm(){
    clearAllV2(rawMaterialForm);
    unitDropDown.clearValues();
    FocusScope.of(context).unfocus();
  }
  void clearRecipeForm(){
    clearAllV2(recipeForm);
    unitDropDown.clearValues();
    FocusScope.of(context).unfocus();
  }


  Widget cartIcon({VoidCallback? onTap,int count=0}){
    return GestureDetector(
      onTap:onTap,
      child: Stack(
        children: [
          CustomCircle(
            hei: 50,
            color: ColorUtil.themeWhite,
            widget: SvgPicture.asset("assets/icons/cart.svg"),
          ),
          Positioned(
            right: 8,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(50),
                  color: Color(0xFF444C66),
                  shape: BoxShape.circle
              ),
              child: Text("$count",style: ts20(ColorUtil.themeWhite,fontsize: 12),),
            ),
          )
        ],
      ),
    );
  }


  @override
  void dispose(){
    widgets.clear();
    rawMaterialForm.clear();
    super.dispose();
  }
}


class UnitDropDown extends StatelessWidget implements ExtensionCallback{

  UnitDropDown({Key? key}) : super(key: key);

  var unitList=[].obs;
  Rxn<dynamic> selectedUnit=Rxn<dynamic>();

  @override
  Widget build(BuildContext context) {
    return Obx(()=>Container(
      width: 100,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(top: 10,bottom: 10,right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color:  ColorUtil.red,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left:10.0,right: 10),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<dynamic>(
              value: selectedUnit.value,
              hint: Text("Unit",style: ts20M(Colors.white),),
              style: ts20M(Colors.white),
              icon: const Icon(
                Icons.keyboard_arrow_down_outlined,
                color: Colors.white,
              ),
              dropdownColor: ColorUtil.red,
              items: unitList.value.map((value) {
                return DropdownMenuItem<dynamic>(
                  value: value,
                  child: Text(
                    "${value['Text']}",
                    style: ts20M(ColorUtil.themeWhite),
                  ),
                );
              }).toList(),
              onChanged: (v) {
                print(v);
                selectedUnit.value=v;
              }
          ),
        ),
      ),
    ));
  }

  @override
  void clearValues() {
    selectedUnit.value=null;
    unitList.clear();
  }

  @override
  String getDataName() {
    // TODO: implement getDataName
    throw UnimplementedError();
  }

  @override
  int getOrderBy() {
    // TODO: implement getOrderBy
    throw UnimplementedError();
  }

  @override
  String getType() {
    // TODO: implement getType
    throw UnimplementedError();
  }

  @override
  getValue() {
    return selectedUnit.value;
  }

  @override
  setOrderBy(int oBy) {
    // TODO: implement setOrderBy
    throw UnimplementedError();
  }

  @override
  setValue(value) {
    if(HE_IsMap(value)){
      selectedUnit.value=value;
    }
    else if(HE_IsList(value)){
      unitList.value=value;
    }

  }

  @override
  bool validate() {
    // TODO: implement validate
    throw UnimplementedError();
  }

  getValueMap(){
    return selectedUnit.value;
  }
}

getUnitIdNameList(String id,String name){
  List finalArr=[];
  List idList=id.split(",");
  List nameList=name.split(",");
  if(idList.length==nameList.length){
    for (int i = 0; i < idList.length; i++) {
      finalArr.add({ "Id": idList[i], "Text": nameList[i] });
    }
  }
  else{
    CustomAlert().cupertinoAlert("Unit Name Mismatch...");
  }
  return finalArr;
}

class GridTitleCard extends StatelessWidget {
  double width;
  dynamic content;
  GridTitleCard({Key? key,required this.width,required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      alignment: Alignment.centerLeft,
      child: Text("$content",style: ts20M(ColorUtil.themeBlack,fontsize: 16),),
    );
  }
}
