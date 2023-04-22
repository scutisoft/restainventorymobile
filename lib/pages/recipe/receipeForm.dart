import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

class ReceipeForm extends StatefulWidget {
  bool isEdit;
  Function? closeCb;
  String dataJson;
  ReceipeForm({Key? key, this.isEdit = false, this.closeCb, this.dataJson = ""})
      : super(key: key);

  @override
  State<ReceipeForm> createState() => _ReceipeFormState();
}

class _ReceipeFormState extends State<ReceipeForm>
    with HappyExtension, TickerProviderStateMixin
    implements HappyExtensionHelperCallback {
  Map widgets = {};
  Map materialForm = {};
  Map staffForm = {};
  Map vesselForm = {};
  String page = "Recipe";
  TraditionalParam traditionalParam = TraditionalParam(
      getByIdSp: "IV_Recipe_GetByRecipeIdDetail",
      insertSp: "IV_Recipe_InsertReceipeDetail",
      updateSp: "IV_Recipe_UpdateRecipeDetail");
  var isKeyboardVisible = false.obs;

  Rxn<DateTime> expectedDate = Rxn<DateTime>();
  var unitName = "Unit".obs;
  var batchNo = "".obs;

  UnitDropDown unitDropDown = UnitDropDown();

  RxList<dynamic> purchaseList = RxList<dynamic>();
  RxList<dynamic> indentMappingList = RxList<dynamic>();

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

  @override
  void initState() {
    tabController = TabController(length: 4, vsync: this);
    controller = SwipeActionController(
      selectedIndexPathsChangeCallback:
          (changedIndexPaths, selected, currentCount) {},
    );
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
                title: "Add Recipe Master",
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
                    inBtwHei(height: 30),
                    Stack(
                      children: [
                        Container(
                          width: SizeConfig.screenWidth,
                          margin: MyConstants.LRPadding,
                          decoration: BoxDecoration(
                            // border: Border.all(color: ColorUtil.red2),
                            borderRadius: BorderRadius.circular(7),
                            color: Color(0xffFCE2E2),
                          ),
                          child: TabBar(
                              controller: tabController,
                              isScrollable: true,
                              unselectedLabelColor: ColorUtil.red2,
                              unselectedLabelStyle:
                                  ts20M(ColorUtil.red2, fontsize: 18),
                              labelStyle:
                                  ts20M(ColorUtil.themeWhite, fontsize: 18),
                              // onTap: (i) {
                              //   if (i != activeTab &&
                              //       (materialMappingList.isNotEmpty ||
                              //           recipeMappingList.isNotEmpty)) {
                              //     CustomAlert(callback: () {
                              //       activeTab = i;
                              //       // materialMappingList.clear();
                              //       // recipeMappingList.clear();
                              //       // recipeInnerProductList.clear();
                              //       // recipeParentList.clear();
                              //     }, cancelCallback: () {
                              //       tabController.animateTo(activeTab);
                              //     }).yesOrNoDialog2("assets/icons/delete.svg",
                              //         "Are you sure want to leave ?", true);
                              //   } else {
                              //     activeTab = i;
                              //   }
                              //   // clearMaterialForm();
                              //   // clearRecipeForm();
                              // },
                              indicator: BoxDecoration(
                                  color: ColorUtil.red2,
                                  borderRadius: BorderRadius.circular(7),
                                  boxShadow: [
                                    BoxShadow(
                                        color: ColorUtil.red2.withOpacity(0.2),
                                        spreadRadius: 5,
                                        blurRadius: 30,
                                        offset: Offset(0, 15))
                                  ]),
                              tabs: [
                                Tab(
                                  text: "Material",
                                  iconMargin: EdgeInsets.zero,
                                  height: ColorUtil.formContainerHeight,
                                ),
                                Tab(
                                  text: "Staff",
                                  iconMargin: EdgeInsets.zero,
                                  height: ColorUtil.formContainerHeight,
                                ),
                                Tab(
                                  text: "vessel",
                                  iconMargin: EdgeInsets.zero,
                                  height: ColorUtil.formContainerHeight,
                                ),
                                Tab(
                                  text: "cost",
                                  iconMargin: EdgeInsets.zero,
                                  height: ColorUtil.formContainerHeight,
                                ),
                              ]),
                        ),
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
                                inBtwHei(height: 20),
                                materialForm['MaterialId'],
                                inBtwHei(height: 10),
                                materialForm['MaterialBrandId'],
                                inBtwHei(height: 10),
                                materialForm['Quantity'],
                                inBtwHei(height: 30),
                                DoneBtn(onDone: () {}, title: "Add"),
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
                                DoneBtn(onDone: () {}, title: "Add"),
                              ],
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                inBtwHei(height: 20),
                                vesselForm['VesselId'],
                                inBtwHei(height: 10),
                                vesselForm['UsageTime'],
                                inBtwHei(height: 10),
                                vesselForm['VesselQuantity'],
                                inBtwHei(height: 30),
                                DoneBtn(onDone: () {}, title: "Add"),
                              ],
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                inBtwHei(height: 30),
                                Container(
                                  width: SizeConfig.screenWidth,
                                  margin: EdgeInsets.only(left: 15, right: 15),
                                  child: Center(
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.all(10),
                                          child: Table(
                                            border: TableBorder.all(),
                                            children: [
                                              TableRow(children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text('Category',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text('Product Cost',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                              ]),
                                              TableRow(children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text('Material Cost',
                                                      textAlign:
                                                          TextAlign.center),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text('11',
                                                      textAlign:
                                                          TextAlign.center),
                                                ),
                                              ]),
                                            ],
                                          ),
                                        ),
                                      ])),
                                ),
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
                extraParam: MyConstants.extraParam, onCustomValidation: () {
              if (purchaseList.isEmpty) {
                CustomAlert()
                    .cupertinoAlert("Select Material to Distribute...");
                return false;
              }
              foundWidgetByKey(widgets, "DepartmentDistributionMaterialJson",
                  needSetValue: true, value: jsonEncode(purchaseList));
              foundWidgetByKey(widgets, "DepartmentDistributionDate",
                  needSetValue: true,
                  value: DateFormat(MyConstants.dbDateFormat)
                      .format(expectedDate.value!));
              return true;
            }, successCallback: (e) {
              console("sysSubmit $e");
              if (widget.closeCb != null) {
                widget.closeCb!(e);
              }
            });
          },
        ),
        // SlidePopUp(
        //   isOpen: isCartOpen,
        //   onBack: () {
        //     selectedIndex.value = -1;
        //   },
        //   widgets: [
        //     inBtwHei(height: 15),
        //     const SwipeNotes(),
        //     Expanded(
        //       child: Obx(() => ListView.builder(
        //             shrinkWrap: true,
        //             itemCount: purchaseList.length,
        //             itemBuilder: (ctx, i) {
        //               return Padding(
        //                 padding: const EdgeInsets.only(bottom: 5.0),
        //                 child: Column(
        //                   mainAxisSize: MainAxisSize.min,
        //                   children: [
        //                     GestureDetector(
        //                       onTap: () {
        //                         if (selectedIndex.value == i) {
        //                           selectedIndex.value = -1;
        //                         } else {
        //                           selectedIndex.value = i;
        //                         }
        //                       },
        //                       child: Container(
        //                         margin: const EdgeInsets.only(
        //                             bottom: 10, left: 0, right: 0),
        //                         padding: const EdgeInsets.all(10),
        //                         width: SizeConfig.screenWidth! * 1,
        //                         decoration: BoxDecoration(
        //                           borderRadius: BorderRadius.circular(10),
        //                           color: const Color(0XFFffffff),
        //                         ),
        //                         clipBehavior: Clip.antiAlias,
        //                         child: Row(
        //                           crossAxisAlignment: CrossAxisAlignment.center,
        //                           children: [
        //                             Expanded(
        //                               flex: 2,
        //                               child: Column(
        //                                 crossAxisAlignment:
        //                                     CrossAxisAlignment.start,
        //                                 children: [
        //                                   Text(
        //                                     "${purchaseList[i]['DepartmentName']}",
        //                                     style: ts20M(ColorUtil.red),
        //                                   ),
        //                                   inBtwHei(),
        //                                   gridCardText(
        //                                       "Materials",
        //                                       (purchaseList[i]['MaterialList']
        //                                           .length)),
        //                                 ],
        //                               ),
        //                             ),
        //                             Column(
        //                               crossAxisAlignment:
        //                                   CrossAxisAlignment.end,
        //                               children: [
        //                                 Row(
        //                                   mainAxisSize: MainAxisSize.min,
        //                                   children: [
        //                                     GridDeleteIcon(
        //                                       hasAccess: purchaseList[i]
        //                                               ['IsDelete'] ??
        //                                           false,
        //                                       onTap: () {
        //                                         CustomAlert(
        //                                                 cancelCallback: () {},
        //                                                 callback: () {
        //                                                   purchaseList
        //                                                       .removeAt(i);
        //                                                 })
        //                                             .yesOrNoDialog2(
        //                                                 "assets/icons/delete.svg",
        //                                                 "Are you sure want to Delete ?",
        //                                                 true);
        //                                       },
        //                                     ),
        //                                     const SizedBox(
        //                                       width: 5,
        //                                     ),
        //                                     Obx(
        //                                       () => ArrowAnimation(
        //                                         openCb: (value) {},
        //                                         isclose:
        //                                             selectedIndex.value != i,
        //                                       ),
        //                                     )
        //                                   ],
        //                                 )
        //                               ],
        //                             )
        //                           ],
        //                         ),
        //                       ),
        //                     ),
        //                     Obx(() => ExpandedSection(
        //                           expand: selectedIndex.value == i,
        //                           child: ListView.builder(
        //                             itemCount:
        //                                 purchaseList[i]['MaterialList'].length,
        //                             physics:
        //                                 const NeverScrollableScrollPhysics(),
        //                             shrinkWrap: true,
        //                             itemBuilder: (ctx1, index) {
        //                               return SwipeActionCell(
        //                                 controller: controller,
        //                                 index: i,
        //                                 key: UniqueKey(),
        //                                 normalAnimationDuration: 500,
        //                                 deleteAnimationDuration: 400,
        //                                 backgroundColor: Colors.transparent,
        //                                 swipeCallBack: (j) {},
        //                                 closeCallBack: () {},
        //                                 firstActionWillCoverAllSpaceOnDeleting:
        //                                     false,
        //                                 trailingActions: [
        //                                   swipeActionEdit((handler) async {
        //                                     numPadUtils["isNumPadOpen"] = true;
        //                                     if (needReturnQty.value) {
        //                                       numPadUtils[
        //                                           "numPadVal"] = purchaseList[i]
        //                                                   ['MaterialList']
        //                                               [index]['ReturnQuantity']
        //                                           .toString();
        //                                       numPadUtils["numPadSubTitle"] =
        //                                           "Return Quantity";
        //                                       numPadUtils["numPadType"] = 2;
        //                                     } else {
        //                                       numPadUtils["numPadVal"] =
        //                                           purchaseList[i]
        //                                                       ['MaterialList']
        //                                                   [index]['Quantity']
        //                                               .toString();
        //                                       numPadUtils["numPadSubTitle"] =
        //                                           "Quantity";
        //                                       numPadUtils["numPadType"] = 1;
        //                                     }
        //
        //                                     numPadUtils["numPadTitle"] =
        //                                         purchaseList[i]['MaterialList']
        //                                                 [index]['MaterialName']
        //                                             .toString();
        //                                     numPadUtils['departmentIndex'] = i;
        //                                     numPadUtils['productIndex'] = index;
        //                                     controller.closeAllOpenCell();
        //                                   }, needBG: true),
        //                                   swipeActionDelete((
        //                                     handler,
        //                                   ) async {
        //                                     if (purchaseList[i]['MaterialList']
        //                                             [index]['IsDelete'] ??
        //                                         false) {
        //                                       CustomAlert(
        //                                               cancelCallback: () {},
        //                                               callback: () async {
        //                                                 purchaseList[i]
        //                                                         ['MaterialList']
        //                                                     .removeAt(index);
        //                                                 if (purchaseList[i][
        //                                                             'MaterialList']
        //                                                         .length ==
        //                                                     0) {
        //                                                   selectedIndex.value =
        //                                                       -1;
        //                                                   purchaseList
        //                                                       .removeAt(i);
        //                                                 }
        //                                                 purchaseList.refresh();
        //                                                 await handler(true);
        //                                               })
        //                                           .yesOrNoDialog2(
        //                                               "assets/icons/delete.svg",
        //                                               "Are you sure want to Delete ?",
        //                                               true);
        //                                     }
        //                                   },
        //                                       hasAccess: purchaseList[i]
        //                                                   ['MaterialList']
        //                                               [index]['IsDelete'] ??
        //                                           false,
        //                                       needBG: true),
        //                                 ],
        //                                 child: Container(
        //                                   margin: const EdgeInsets.only(
        //                                       left: 7, right: 7),
        //                                   padding: const EdgeInsets.fromLTRB(
        //                                       0, 10, 0, 10),
        //                                   decoration: BoxDecoration(
        //                                       border: Border(
        //                                           bottom: BorderSide(
        //                                               color: ColorUtil
        //                                                   .greyBorder))),
        //                                   //  decoration:ColorUtil.formContBoxDec,
        //                                   child: Column(
        //                                     mainAxisSize: MainAxisSize.min,
        //                                     crossAxisAlignment:
        //                                         CrossAxisAlignment.start,
        //                                     children: [
        //                                       Text(
        //                                         "${purchaseList[i]['MaterialList'][index]['MaterialName']}",
        //                                         style: ts20M(
        //                                             ColorUtil.themeBlack,
        //                                             fontsize: 18),
        //                                       ),
        //                                       Visibility(
        //                                         visible: purchaseList[i]
        //                                                         ['MaterialList']
        //                                                     [index]
        //                                                 ['MaterialBrandName']
        //                                             .toString()
        //                                             .isNotEmpty,
        //                                         child: Text(
        //                                           "${purchaseList[i]['MaterialList'][index]['MaterialBrandName']}",
        //                                           style: ts20M(ColorUtil.red2,
        //                                               fontsize: 15),
        //                                         ),
        //                                       ),
        //                                       inBtwHei(),
        //                                       Row(
        //                                         mainAxisSize: MainAxisSize.min,
        //                                         children: [
        //                                           gridCardText(
        //                                               "Qty",
        //                                               purchaseList[i]
        //                                                       ['MaterialList']
        //                                                   [index]['Quantity']),
        //                                           Text(
        //                                             "  ${purchaseList[i]['MaterialList'][index]['PrimaryUnitName']}",
        //                                             style: ts20M(
        //                                                 ColorUtil.text2,
        //                                                 fontfamily: 'ALO',
        //                                                 fontsize: 15),
        //                                           ),
        //                                           const Spacer(),
        //                                           gridCardText(
        //                                               "Return Qty",
        //                                               purchaseList[i]['MaterialList']
        //                                                           [index][
        //                                                       'ReturnQuantity'] ??
        //                                                   0),
        //                                           Text(
        //                                             "  ${purchaseList[i]['MaterialList'][index]['PrimaryUnitName']}",
        //                                             style: ts20M(
        //                                                 ColorUtil.text2,
        //                                                 fontfamily: 'ALO',
        //                                                 fontsize: 15),
        //                                           ),
        //                                         ],
        //                                       ),
        //                                       inBtwHei(),
        //                                       /*Row(
        //                                     children: [
        //                                       gridCardText("Qty",purchaseList[i]['MaterialList'][index]['Quantity']),
        //                                       Text("  ${purchaseList[i]['MaterialList'][index]['UnitName']}",style: ts20M(ColorUtil.text2,fontfamily: 'ALO',fontsize: 15),),
        //                                       const Spacer(),
        //                                       gridCardText("SubTotal",getRupeeString(purchaseList[i]['MaterialList'][index]['SubTotal'])),
        //                                     ],
        //                                   ),
        //                                   inBtwHei(),*/
        //                                     ],
        //                                   ),
        //                                 ),
        //                               );
        //                             },
        //                           ),
        //                         ))
        //                   ],
        //                 ),
        //               );
        //             },
        //           )),
        //     )
        //   ],
        // ),
        // Obx(() => Blur(
        //       value: numPadUtils['isNumPadOpen'] as bool,
        //     )),
        // Obx(() => NumberPadPopUp(
        //       isSevenInch: true,
        //       isOpen: numPadUtils['isNumPadOpen'] as bool,
        //       value: numPadUtils['numPadVal'].toString(),
        //       title: numPadUtils['numPadTitle'].toString(),
        //       subTitle: numPadUtils['numPadSubTitle'].toString(),
        //       onCancel: () {
        //         numPadUtils['isNumPadOpen'] = false;
        //         clearNumPadUtils();
        //       },
        //       numberTap: (e) {
        //         numPadUtils['numPadVal'] = e;
        //       },
        //       onDone: () {
        //         onProductQtyUpdate();
        //       },
        //     )),
        Obx(() => Loader(
              value: showLoader.value,
            )),
      ],
    ));
  }

  @override
  void assignWidgets() async {
    unitDropDown.onChange = (e) {
      unitName.value = e['Text'];
    };
    widgets.clear();
    widgets['YieldQuantity'] = AddNewLabelTextField(
      dataname: 'YieldQuantity',
      hasInput: true,
      required: false,
      labelText: "Yield Quantity",
      regExp: null,
      textInputType: TextInputType.number,
      onChange: (v) {},
      onEditComplete: () {
        FocusScope.of(context).unfocus();
      },
      maxlines: null,
    );
    widgets['RecipeName'] = AddNewLabelTextField(
      dataname: 'RecipeName',
      hasInput: true,
      required: false,
      labelText: "Recipe Name",
      regExp: null,
      onChange: (v) {},
      onEditComplete: () {
        FocusScope.of(context).unfocus();
      },
      maxlines: null,
    );

    widgets['RecipeTypeId'] = SlideSearch(
        dataName: "RecipeTypeId",
        selectedValueFunc: (e) {},
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
      propertyName: "value",
    );
    widgets['UnitId'] = SlideSearch(
      dataName: "UnitId",
      required: false,
      selectedValueFunc: (e) {},
      hinttext: "Select Unit",
      data: [],
      propertyName: "value",
    );
    widgets['RecipeChefId'] = SlideSearch(
      dataName: "RecipeChefId",
      required: false,
      selectedValueFunc: (e) {},
      hinttext: "Select Recipe Chef",
      data: [],
      propertyName: "value",
    );
    widgets['RecipeChefId'] = SlideSearch(
      dataName: "RecipeChefId",
      required: false,
      selectedValueFunc: (e) {},
      hinttext: "Select Recipe Chef",
      data: [],
      propertyName: "value",
    );
    widgets['PreParationTime'] = AddNewLabelTextField(
      dataname: 'PreParationTime',
      hasInput: true,
      required: true,
      labelText: "PreParation Time",
      scrollPadding: 150,
      regExp: MyConstants.decimalReg,
      textInputType: TextInputType.number,
      onChange: (v) {},
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
      textLength: MyConstants.maximumQty,
    );

    materialForm['MaterialId'] = SlideSearch(
        dataName: "MaterialId",
        selectedValueFunc: (e) {},
        hinttext: "Select Material",
        data: []);
    materialForm['MaterialBrandId'] = SlideSearch(
        dataName: "MaterialBrandId",
        selectedValueFunc: (e) {},
        hinttext: "Select Material Brand",
        data: []);
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

    staffForm['StaffCategoryId'] = SlideSearch(
        dataName: "StaffCategoryId",
        selectedValueFunc: (e) {},
        hinttext: "Select Staff Category",
        data: []);
    staffForm['TotalStaff'] = AddNewLabelTextField(
      dataname: 'TotalStaff',
      hasInput: true,
      required: false,
      labelText: "Count",
      regExp: null,
      onChange: (v) {},
      onEditComplete: () {
        FocusScope.of(context).unfocus();
      },
      maxlines: null,
    );
    staffForm['WorkingTime'] = AddNewLabelTextField(
      dataname: 'WorkingTime',
      hasInput: true,
      required: false,
      labelText: "hh:mm",
      regExp: null,
      onChange: (v) {},
      onEditComplete: () {
        FocusScope.of(context).unfocus();
      },
      maxlines: null,
    );
    staffForm['SalaryCost'] = AddNewLabelTextField(
      dataname: 'SalaryCost',
      hasInput: true,
      required: false,
      labelText: "Cost",
      regExp: null,
      onChange: (v) {},
      onEditComplete: () {
        FocusScope.of(context).unfocus();
      },
      maxlines: null,
    );
    vesselForm['VesselId'] = SlideSearch(
        dataName: "VesselId",
        selectedValueFunc: (e) {},
        hinttext: "Select",
        data: []);
    vesselForm['UsageTime'] = AddNewLabelTextField(
      dataname: 'UsageTime',
      hasInput: true,
      required: false,
      labelText: "UsageTime",
      regExp: null,
      onChange: (v) {},
      onEditComplete: () {
        FocusScope.of(context).unfocus();
      },
      maxlines: null,
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
        refId: "");
    fillTreeDrp(widgets, "CuisineId",
        page: page,
        spName: Sp.masterSp,
        extraParam: MyConstants.extraParam,
        refType: "",
        refId: "");
    fillTreeDrp(widgets, "UnitId",
        page: page,
        spName: Sp.masterSp,
        extraParam: MyConstants.extraParam,
        refType: "",
        refId: "");
    fillTreeDrp(widgets, "RecipeChefId",
        page: page,
        spName: Sp.masterSp,
        extraParam: MyConstants.extraParam,
        refType: "",
        refId: "");
    fillTreeDrp(vesselForm, "VesselId",
        page: page,
        spName: Sp.masterSp,
        extraParam: MyConstants.extraParam,
        refType: "",
        refId: "");
    fillTreeDrp(staffForm, "StaffCategoryId",
        page: page,
        spName: Sp.masterSp,
        extraParam: MyConstants.extraParam,
        refType: "",
        refId: "");
    fillTreeDrp(materialForm, "MaterialId",
        page: page,
        spName: Sp.masterSp,
        extraParam: MyConstants.extraParam,
        refType: "",
        refId: "");
    fillTreeDrp(materialForm, "MaterialBrandId",
        page: page,
        spName: Sp.masterSp,
        extraParam: MyConstants.extraParam,
        refType: "",
        refId: "");

    await parseJson(widgets, "",
        dataJson: widget.dataJson,
        traditionalParam: traditionalParam,
        extraParam: MyConstants.extraParam,
        loader: showLoader, resCb: (e) {
      try {
        console("parseJson $e");
        batchNo.value = " - ${e['Table'][0]['BatchNumber']}";
        expectedDate.value =
            checkNullEmpty(e['Table'][0]['DepartmentDistributionDate'])
                ? DateTime.now()
                : DateTime.parse(e['Table'][0]['DepartmentDistributionDate']);
        if (!checkNullEmpty(e['Table'][0]['OutPutJson'])) {
          purchaseList.value = jsonDecode(e['Table'][0]['OutPutJson']);
        }
      } catch (e, t) {
        assignWidgetErrorToastLocal(e, t);
      }
    });
  }

  void onMaterialChange(e) {
    unitDropDown.clearValues();
    if (!checkNullEmpty(e['UnitId'])) {
      unitDropDown.setValue(getUnitIdNameList(e['UnitId'], e['UnitName']));
      if (unitDropDown.unitList.isNotEmpty) {
        unitDropDown.setValue(unitDropDown.unitList[0]);
        unitName.value = unitDropDown.selectedUnit.value['Text'];
      }
    }
    fillTreeDrp(materialForm, "MaterialBrandId",
        page: page,
        spName: Sp.masterSp,
        extraParam: MyConstants.extraParam,
        refId: e['Id'],
        toggleRequired: true,
        needToDisable: true);
  }

  void onMaterialAdd() async {
    List<ParamModel> a = await getFrmCollection(materialForm);
    if (a.isNotEmpty) {
      FocusScope.of(context).unfocus();
      Map vDrp = materialForm['DepartmentId'].getValueMap();
      Map mDrp = materialForm['MaterialId'].getValueMap();
      Map mbDrp = materialForm['MaterialBrandId'].getValueMap();
      var brandId = mbDrp.isEmpty ? null : mbDrp['Id'];
      console(vDrp);
      console(mDrp);
      console(mbDrp);
      int existsVendorIndex = purchaseList
          .indexWhere((element) => element['DepartmentId'] == vDrp['Id']);
      int rNo = purchaseList.length;
      if (existsVendorIndex == -1) {
        var obj = {
          "DepartmentId": vDrp['Id'],
          "DepartmentName": vDrp['Text'],
          "IsDelete": true,
          "MaterialList": []
        };
        purchaseList.add(obj);
      } else {
        rNo = existsVendorIndex;
      }

      List productList = purchaseList[rNo]['MaterialList'];
      int existsProductIndex = productList.indexWhere((element) =>
          element['MaterialId'] == mDrp['Id'] &&
          element['MaterialBrandId'] == brandId);
      if (existsProductIndex == -1) {
        var pObj = {
          "DepartmentDistributionMaterialMappingId": null,
          "MaterialId": mDrp['Id'],
          "MaterialName": mDrp['value'],
          "MaterialBrandId": brandId,
          "MaterialBrandName": brandId != null ? mbDrp['value'] : "",
          "PrimaryUnitId": unitDropDown.selectedUnit.value['Id'],
          "PrimaryUnitName": unitDropDown.selectedUnit.value['Text'],
          "ReturnQuantity": null,
          "Quantity": parseDouble(materialForm['MaterialQty'].getValue()),
          "DepartmentId": purchaseList[rNo]['DepartmentId'],
          "IsDelete": true,
        };
        productList.add(pObj);
        clearAllV2(materialForm);
        setFrmValues(materialForm, [
          {"DepartmentId": vDrp['Id']}
        ]);
        unitDropDown.clearValues();
        unitName.value = "Unit";
      } else {
        CustomAlert().cupertinoAlert("Material Already Exits");
      }
    }
  }

  void onProductQtyUpdate() {
    double qty = parseDouble(numPadUtils['numPadVal']);
    if (numPadUtils['departmentIndex'] != -1 &&
        numPadUtils['productIndex'] != -1) {
      if (numPadUtils['numPadType'] == 1) {
        if (qty <= 0) {
          CustomAlert().cupertinoAlert("Enter Quantity...");
          return;
        }
        purchaseList[numPadUtils['departmentIndex'] as int]['MaterialList']
            [numPadUtils['productIndex'] as int]['Quantity'] = qty;
      } else if (numPadUtils['numPadType'] == 2) {
        if (qty <= 0) {
          CustomAlert().cupertinoAlert("Enter Return Quantity...");
          return;
        }
        int di = numPadUtils['departmentIndex'] as int;
        int pi = numPadUtils['productIndex'] as int;
        double cQty =
            parseDouble(purchaseList[di]['MaterialList'][pi]['Quantity']);
        if (qty > cQty) {
          CustomAlert()
              .cupertinoAlert("Return Quantity should less than ${cQty}...");
          return;
        }
        purchaseList[di]['MaterialList'][pi]['ReturnQuantity'] = qty;
      }
      purchaseList.refresh();
    }

    numPadUtils['isNumPadOpen'] = false;
    clearNumPadUtils();
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
    materialForm.clear();
    purchaseList.clear();
    clearOnDispose();
    super.dispose();
  }
}
