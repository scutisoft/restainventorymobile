
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

class PurchaseForm extends StatefulWidget {
  bool isEdit;
  Function? closeCb;
  String dataJson;
  PurchaseForm({Key? key,this.isEdit=false,this.closeCb,this.dataJson=""}) : super(key: key);

  @override
  State<PurchaseForm> createState() => _PurchaseFormState();
}

class _PurchaseFormState extends State<PurchaseForm> with HappyExtension implements HappyExtensionHelperCallback{

  Map widgets={};
  Map materialForm={};
  String page="PurchaseOrder";
  TraditionalParam traditionalParam=TraditionalParam(
      getByIdSp: "IV_Purchase_GetbyPurchaseOrderIdDetail",
      insertSp: "IV_Purchase_InsertPurchaseOrderDetail",
      updateSp: "IV_Purchase_UpdatePurchaseOrderDetail"
  );
  var isKeyboardVisible=false.obs;

  Rxn<DateTime> expectedDate=Rxn<DateTime>();
  var unitName="Unit".obs;
  var poNum="".obs;


  RxList<dynamic> purchaseList=RxList<dynamic>();
  RxList<dynamic> indentMappingList=RxList<dynamic>();


  Map vendorNames={};
  List vendorIdList=[];

  var isCartOpen=false.obs;
  var isIndentOpen=false.obs;

  var selectedIndex=(-1).obs;
  final FlutterUtils _flutterUtils=FlutterUtils();

  late SwipeActionController controller;


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
                    title: "${widget.isEdit?"Update":"Add"} Purchase Order ${poNum.value}",
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
                        LeftHeader(title: "Notes"),
                        widgets['VendorNotes'],
                        inBtwHei(height: 20),
                        Row(
                          children: [
                            LeftHeader(title: "+ Add Purchase Material"),
                            const Spacer(),
                            GestureDetector(
                              onTap: (){
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
                                  isCartOpen.value=true;
                                },
                                count: purchaseList.length
                            )),
                            const SizedBox(width: 20,)
                          ],
                        ),
                        LeftHeader(title: "Vendor"),
                        materialForm['VendorId'],
                        LeftHeader(title: "Material"),
                        materialForm['MaterialId'],
                        LeftHeader(title: "Material Brand"),
                        materialForm['MaterialBrandId'],
                        LeftHeader(title: "Material Price"),
                        materialForm['MaterialPrice'],
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
                        CustomAlert().cupertinoAlert("Select Material to raise Purchase...");
                        return false;
                      }
                      foundWidgetByKey(widgets, "Datajson",needSetValue: true,value: jsonEncode(purchaseList));
                      foundWidgetByKey(widgets, "ExpectedDate",needSetValue: true,value: DateFormat(MyConstants.dbDateFormat).format(expectedDate.value!));
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

                  const SwipeNotes(),
                  Expanded(
                    child: ListView.builder(
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
                                            Text("${purchaseList[i]['VendorName']}",style: ts20M(ColorUtil.red),),
                                            inBtwHei(),
                                            gridCardText("SubTotal",getRupeeString(purchaseList[i]['SubTotal'])),
                                            inBtwHei(),
                                            gridCardText("Tax",getRupeeString(purchaseList[i]['TaxAmount'])),
                                            inBtwHei(),
                                            gridCardText("Total",getRupeeString(purchaseList[i]['GrandTotalAmount'])),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          gridCardText("Materials",(purchaseList[i]['PMD'].length)),
                                          inBtwHei(height: 15),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              GridDeleteIcon(
                                                hasAccess: true,
                                                onTap: (){
                                                  CustomAlert(
                                                    cancelCallback: (){},
                                                    callback: (){
                                                      purchaseList.removeAt(i);
                                                      overAllCalc();
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
                                  itemCount: purchaseList[i]['PMD'].length,
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
                                          numPadUtils["numPadVal"]=purchaseList[i]['PMD'][index]['Quantity'].toString();
                                          numPadUtils["numPadTitle"]=purchaseList[i]['PMD'][index]['MaterialName'].toString();
                                          numPadUtils["numPadSubTitle"]=purchaseList[i]['PMD'][index]['MaterialBrandName'].toString();
                                          numPadUtils['vendorIndex']=i;
                                          numPadUtils['productIndex']=index;
                                          controller.closeAllOpenCell();
                                        }),
                                        swipeActionDelete((handler) async {
                                          CustomAlert(
                                              cancelCallback: (){},
                                              callback: () async{
                                                purchaseList[i]['PMD'].removeAt(index);
                                                if( purchaseList[i]['PMD'].length==0){
                                                  purchaseList.removeAt(i);
                                                  selectedIndex.value=-1;
                                                }
                                                totalCalc();
                                                overAllCalc();
                                                purchaseList.refresh();
                                                await handler(true);
                                              }
                                          ).yesOrNoDialog2("assets/icons/delete.svg", "Are you sure want to Delete ?", true);

                                        }),
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
                                            Text("${purchaseList[i]['PMD'][index]['MaterialName']}",
                                              style: ts20M(ColorUtil.themeBlack,fontsize: 18),
                                            ),
                                            Visibility(
                                              visible: purchaseList[i]['PMD'][index]['MaterialBrandName'].toString().isNotEmpty,
                                              child: Text("${purchaseList[i]['PMD'][index]['MaterialBrandName']}",
                                                style: ts20M(ColorUtil.red2,fontsize: 15),
                                              ),
                                            ),
                                            inBtwHei(),
                                            gridCardText("Price",getRupeeString(purchaseList[i]['PMD'][index]['Price'])),
                                            inBtwHei(),
                                            Row(
                                              children: [
                                                gridCardText("Qty",purchaseList[i]['PMD'][index]['Quantity']),
                                                Text("  ${purchaseList[i]['PMD'][index]['UnitName']}",style: ts20M(ColorUtil.text2,fontfamily: 'ALO',fontsize: 15),),
                                                const Spacer(),
                                                gridCardText("SubTotal",getRupeeString(purchaseList[i]['PMD'][index]['SubTotal'])),
                                              ],
                                            ),
                                            inBtwHei(),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                gridCardText("Tax",getRupeeString(purchaseList[i]['PMD'][index]['TaxAmount'])),
                                                gridCardText("Total",getRupeeString(purchaseList[i]['PMD'][index]['TotalAmount']))
                                              ],
                                            ),


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
                    ),
                  )
                ],
              ),
            )),

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
                                        Visibility(
                                          visible: indentMappingList[i]['hasProduct']??false,
                                          child: CustomCircle(
                                              hei: 30,
                                              color: ColorUtil.red2,
                                              margin: const EdgeInsets.only(right: 10),
                                            widget: Text("${indentMappingList[i]['MaterialList'].where((z)=>z['IsSelect']==true).toList().length}",
                                              style: ts20M(ColorUtil.themeWhite,fontfamily: 'RR'),
                                            ),
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
                                              width:SizeConfig.screenWidth!-230,
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
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                FittedText(
                                                  height: 25,
                                                  width:150,
                                                  alignment: Alignment.centerLeft,
                                                  text: "${indentMappingList[i]['MaterialList'][index]['IndentQuantity']??0} ${indentMappingList[i]['MaterialList'][index]['UnitName']}",
                                                  textStyle:  ts20M(ColorUtil.themeBlack,fontsize: 18),
                                                ),
                                                Container(
                                                  width: 140,
                                                  height: 35,
                                                  clipBehavior: Clip.antiAlias,
                                                  margin: const EdgeInsets.only(top: 0,bottom: 0,right: 0),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(5),
                                                    color:  Color.fromRGBO(255, 0, 34,0.2),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left:10.0,right: 10),
                                                    child: DropdownButtonHideUnderline(
                                                      child: DropdownButton<dynamic>(
                                                          isExpanded: true,
                                                          value: indentMappingList[i]['MaterialList'][index]['VendorId']!=null?
                                                          vendorIdList.contains(indentMappingList[i]['MaterialList'][index]['VendorId'])?indentMappingList[i]['MaterialList'][index]['VendorId']
                                                          :null:indentMappingList[i]['MaterialList'][index]['VendorId'],
                                                          hint: Text("Select Vendor",style: ts20M(ColorUtil.themeBlack.withOpacity(0.5),fontsize: 15),),
                                                          style: ts20M(ColorUtil.themeBlack,fontsize: 15),
                                                          selectedItemBuilder: (ctx){
                                                            return vendorIdList.map<Widget>((item) {
                                                              return Container(
                                                                alignment: Alignment.centerLeft,
                                                                constraints: const BoxConstraints(maxWidth: 120),
                                                                child: Text(
                                                                  "${vendorNames[item.toString()]}",
                                                                  style: TextStyle(color: ColorUtil.themeBlack, fontSize: 14),
                                                                ),
                                                              );
                                                            }).toList();
                                                          },
                                                          icon:  Icon(
                                                            Icons.keyboard_arrow_down_outlined,
                                                            color: ColorUtil.themeBlack.withOpacity(0.5),
                                                          ),
                                                          dropdownColor: ColorUtil.red,
                                                          items: vendorIdList.map((value) {
                                                            return DropdownMenuItem<dynamic>(
                                                              value: value,
                                                              child: Text(
                                                                "${vendorNames[value.toString()]}",
                                                                style: ts20M(ColorUtil.themeWhite,fontsize: 15),
                                                              ),
                                                            );
                                                          }).toList(),
                                                          onChanged: (v) {
                                                            indentMappingList[i]['MaterialList'][index]['VendorId']=v;
                                                            indentMappingList.refresh();
                                                          }
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
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
                inBtwHei(height: 20)
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
    widgets.clear();
    widgets['PurchaseOrderId']=HiddenController(dataname: "PurchaseOrderId");
    widgets['ExpectedDate']=HiddenController(dataname: "ExpectedDate");
    widgets['Datajson']=HiddenController(dataname: "Datajson");
    widgets['GrandTotalAmount']=HiddenController(dataname: "GrandTotalAmount");
    widgets['TaxAmount']=HiddenController(dataname: "TaxAmount");
    widgets['SubTotal']=HiddenController(dataname: "SubTotal");
    widgets['DiscountedSubTotal']=HiddenController(dataname: "DiscountedSubTotal",);
    widgets['DiscountAmount']=HiddenController(dataname: "DiscountAmount");
    widgets['DiscountValue']=HiddenController(dataname: "DiscountValue");
    widgets['IsPercentage']=HiddenController(dataname: "IsPercentage");
    widgets['IsDiscount']=HiddenController(dataname: "IsDiscount");
    widgets['Notes']=HiddenController(dataname: "Notes");
    widgets['VendorNotes']=AddNewLabelTextField(
      dataname: 'VendorNotes',
      hasInput: false,
      required: false,
      labelText: "Notes",
      regExp: null,
      onChange: (v){},
      onEditComplete: (){
        FocusScope.of(context).unfocus();
      },
      maxlines: null,
    );

    materialForm['VendorId']=SlideSearch(dataName: "VendorId",
      selectedValueFunc: (e){
        console(e);
        fillTreeDrp(materialForm, "MaterialId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,
            refType: "MaterialId",refId: e['Id'],needToDisable: true);
      },
      hinttext: "Select Vendor",data: []);

    materialForm['MaterialId']=SlideSearch(dataName: "MaterialId",selectedValueFunc:onMaterialChange,hinttext: "Select Material",data: [],propertyId: "MaterialId",propertyName: "MaterialName",);
    materialForm['MaterialBrandId']=SlideSearch(dataName: "MaterialBrandId",required: false,selectedValueFunc: onMaterialBrandChange, hinttext: "Select Material Brand",data: [],propertyName: "value",);
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
      suffixIcon:CustomCircle(
          hei: 45,
          margin: const EdgeInsets.only(right: 7,top: 7,bottom: 7),
          color: ColorUtil.red,
        widget: FittedBox(
          child: Obx(() => Text(" ${unitName.value} ",style: ts20M(ColorUtil.themeWhite),)),
        ),
      ),
      textLength: MyConstants.maximumQty,
    );

    if(!widget.isEdit){
      expectedDate.value=DateTime.now();
      setFrmValues(widgets, [{"DiscountedSubTotal":0,"DiscountAmount":0,"DiscountValue":0,"IsPercentage":false,"IsDiscount":false,}]);

    }

    fillTreeDrp(materialForm, "VendorId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "",clearValues: false,resCb: (arr){
      vendorIdList.clear();
      vendorNames.clear();
      for(var vd in arr){
        vendorIdList.add(vd['Id']);
        vendorNames[vd['Id'].toString()]=vd['Text'];
      }
      getIndentOrders();
    });
    await parseJson(widgets, "",dataJson: widget.dataJson,traditionalParam: traditionalParam,extraParam: MyConstants.extraParam,loader: showLoader,
        resCb: (e){
          try{
            console("parseJson $e");
            poNum.value=" - ${e['Table'][0]['PurchaseOrder']}";
            expectedDate.value=DateTime.parse(e['Table'][0]['ExpectedDate']);
            var t1=e['Table1'][0]['OutPutJson'];
            if(!checkNullEmpty(t1)){
              purchaseList.value=jsonDecode(t1);
            }

          }catch(e,t){
            assignWidgetErrorToastLocal(e,t);
          }

        });



  }


  void onMaterialChange(e){
    console(e);
    if(!checkNullEmpty(e['PrimaryUnitName'])){
      unitName.value=e['PrimaryUnitName'];
    }
    else{
      unitName.value="Unit";
    }
    updateMPrice(e);
    fillTreeDrp(materialForm, "MaterialBrandId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,
        refType: "MaterialId",refId: e['MaterialId'],toggleRequired: true,needToDisable: true);
  }

  void onMaterialBrandChange(e){
    console(e);
    updateMPrice(e);
  }

  void updateMPrice(e){
    double mPrice=parseDouble(e['MaterialPrice']);
    foundWidgetByKey(materialForm, "MaterialPrice",needSetValue: true,value: mPrice>0?mPrice:"");
  }

  void onMaterialAdd() async{
    List<ParamModel> a=await getFrmCollection(materialForm);
    if(a.isNotEmpty){
      FocusScope.of(context).unfocus();
      Map vDrp=materialForm['VendorId'].getValueMap();
      Map mDrp=materialForm['MaterialId'].getValueMap();
      Map mbDrp=materialForm['MaterialBrandId'].getValueMap();
      var brandId=mbDrp.isEmpty?null:mbDrp['Id'];
      console(vDrp);
      console(mDrp);
      console(mbDrp);
      int existsVendorIndex=purchaseList.indexWhere((element) => element['VendorId']==vDrp['Id']);
      int rNo=purchaseList.length;
      if(existsVendorIndex==-1){
        var obj = {
          "RNo": rNo + 1,
          "PurchaseOrderVendorMappingId": null,
          "PurchaseOrderId": null,
          "VendorId": vDrp['Id'],
          "VendorName": vDrp['Text'],
          "Notes": "",
          "SubTotal": 0.0,
          "IsDiscount": false,
          "IsPercentage": false,
          "DiscountValue": 0.0,
          "DiscountAmount": 0.0,
          "DiscountedSubTotal": 0.0,
          "TaxAmount": 0.0,
          "GrandTotalAmount": 0.0,
          "InventoryStatusId": null,
          "InventoryStatusName": "",
          "PMD": []
        };
        purchaseList.add(obj);
      }
      else{
        rNo=existsVendorIndex;
      }

      List productList=purchaseList[rNo]['PMD'];
      int existsProductIndex=productList.indexWhere((element) => element['MaterialId']==mDrp['MaterialId'] && element['MaterialBrandId']==brandId);
      if(existsProductIndex==-1){
        var pObj = {
          "PurchaseOrderMaterialMappingId": null,
          "PurchaseOrderId": null,
          "MaterialId": mDrp['MaterialId'],
          "MaterialName": mDrp['value'],
          "MaterialBrandId": brandId,
          "MaterialBrandName": brandId!=null ? mbDrp['value'] : "",
          "UnitId": mDrp['PrimaryUnitId'],
          "UnitName": mDrp['PrimaryUnitName']??"",
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
          "PurchaseOrderVendorMappingId": null,
          "VendorId": purchaseList[rNo]['VendorId']
        };
        productList.add(pObj);
        clearAllV2(materialForm);
        unitName.value="Unit";
        totalCalc();
        overAllCalc();
      }
      else{
        CustomAlert().cupertinoAlert("Material Already Exits");
      }
    }
  }

  void totalCalc(){
    for (var element in purchaseList) {
      productCalc(element);
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

  void overAllCalc(){
    double sT=0.0,tax=0.0,tA=0.0;
    for (var element in purchaseList) {
      sT=Calculation().add(sT, element['SubTotal']);
      tax=Calculation().add(tax, element['TaxAmount']);
      tA=Calculation().add(tA, element['GrandTotalAmount']);
    }
    setFrmValues(widgets, [{"SubTotal":sT,"GrandTotalAmount":tA,"TaxAmount":tax}]);
  }

  void onProductQtyUpdate(){
    double qty=parseDouble( numPadUtils['numPadVal']);
    if(qty<=0){
      CustomAlert().cupertinoAlert("Enter Quantity...");
      return;
    }
    if(numPadUtils['vendorIndex']!=-1 && numPadUtils['productIndex']!=-1){
      purchaseList[numPadUtils['vendorIndex'] as int]['PMD'][numPadUtils['productIndex'] as int]['Quantity']=qty;
      productCalc(purchaseList[numPadUtils['vendorIndex'] as int]);
      overAllCalc();
      purchaseList.refresh();
    }
    numPadUtils['isNumPadOpen']=false;
    clearNumPadUtils();
  }

  void getIndentOrders() async{
    indentMappingList.clear();
    List<ParamModel> parameterList=await getParamEssential(extraParam: MyConstants.extraParam);
    _flutterUtils.getInvoke(parameterList,loader: showLoader,url: "${GetBaseUrl()}/api/PurchaseApi/GetIndentOrdersList").then((value){
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
    List<dynamic> tempIndentSelList=[];
    tempIndentSelList=indentMappingList.where((p0) => p0['hasProduct']==true).toList();
    //bool chkCt=indentMappingList.any((element) => element['MaterialList'].any((p)=>p['IsSelect']==true)==true);
    if(tempIndentSelList.isNotEmpty){
     /* bool proceed=false;
      for(var vd in tempIndentSelList){
        for(var pd in  vd['MaterialList'].where((y)=>y['IsSelect']==true).toList()){
          proceed=checkNullEmpty(pd['VendorId']) || vendorNames[pd['VendorId'].toString()]!=null;
          console("proceed ${pd['VendorId']} ${checkNullEmpty(pd['VendorId'])} ${vendorNames[pd['VendorId'].toString()]} $proceed");
        }
      }*/
      bool hasNotVendor=tempIndentSelList.any((element) => element['MaterialList'].any((p)=>p['IsSelect']==true &&
          !(checkNullEmpty(p['VendorId']) || vendorNames[p['VendorId'].toString()]!=null))==true);
      if(hasNotVendor){
        CustomAlert().cupertinoAlert("Select Vendor to Add...");
      }
      else{
       // console(tempIndentSelList);
        for(var vd in tempIndentSelList){
          for(var pd in  vd['MaterialList'].where((y)=>y['IsSelect']==true).toList()){
            int existsVendorIndex=purchaseList.indexWhere((element) => element['VendorId']==pd['VendorId']);
            if(existsVendorIndex!=-1){
              List productList=purchaseList[existsVendorIndex]['PMD'];
              int existsProductIndex=productList.indexWhere((element) => element['MaterialId']==pd['MaterialId'] &&
                  element['MaterialBrandId']==pd['MaterialBrandId']);
              if(existsProductIndex!=-1){
                purchaseList[existsVendorIndex]['PMD'][existsProductIndex]['Quantity']=0.0;
              }
            }
          }
        }
        for(var vd in tempIndentSelList){
          for(var pd in  vd['MaterialList'].where((y)=>y['IsSelect']==true).toList()){
            int existsVendorIndex=purchaseList.indexWhere((element) => element['VendorId']==pd['VendorId']);
            int rNo=purchaseList.length;
            if(existsVendorIndex==-1){
              var obj = {
                "RNo": rNo + 1,
                "PurchaseOrderVendorMappingId": null,
                "PurchaseOrderId": null,
                "VendorId": pd['VendorId'],
                "VendorName": vendorNames[pd['VendorId'].toString()],
                "Notes": "",
                "SubTotal": 0.0,
                "IsDiscount": false,
                "IsPercentage": false,
                "DiscountValue": 0.0,
                "DiscountAmount": 0.0,
                "DiscountedSubTotal": 0.0,
                "TaxAmount": 0.0,
                "GrandTotalAmount": 0.0,
                "InventoryStatusId": null,
                "InventoryStatusName": "",
                "PMD": []
              };
              purchaseList.add(obj);
            }
            else{
              rNo=existsVendorIndex;
            }
            List productList=purchaseList[rNo]['PMD'];
            int existsProductIndex=productList.indexWhere((element) => element['MaterialId']==pd['MaterialId'] &&
                element['MaterialBrandId']==pd['MaterialBrandId']);
            if(existsProductIndex==-1){
              var pObj = {
                "PurchaseOrderMaterialMappingId": null,
                "PurchaseOrderId": null,
                "MaterialId": pd['MaterialId'],
                "MaterialName": pd['MaterialName'],
                "MaterialBrandId": pd['MaterialBrandId'],
                "MaterialBrandName": pd['MaterialBrandId']!=null ? pd['MaterialBrandName'] : "",
                "UnitId": pd['UnitId'],
                "UnitName": pd['UnitName']??"",
                "Price": parseDouble(pd['MaterialPrice']),
                "Quantity": parseDouble(pd['Quantity']),
                "IsPercentage": false,
                "DiscountValue": 0.0000,
                "DiscountAmount": 0.0000,
                "TaxId": pd['TaxId'],
                "TaxValue": parseDouble(pd['TaxValue']),
                "TaxAmount": 0.0000,
                "TotalAmount": 0.0000,
                "SubTotal": 0.0000,
                "DiscountedSubTotal": 0.0000,
                "PurchaseOrderVendorMappingId": null,
                "VendorId": purchaseList[rNo]['VendorId']
              };
              productList.add(pObj);

            }
            else{
              productList[existsProductIndex]['Quantity']=Calculation().add(productList[existsProductIndex]['Quantity'], parseDouble(pd['Quantity']));
            }
          }
        }
        totalCalc();
        overAllCalc();
        purchaseList.refresh();
        isIndentOpen.value=false;
      }
    }
    else{
      CustomAlert().cupertinoAlert("No Materials Selected to add...");
    }
  }

  void clearNumPadUtils(){
    numPadUtils['numPadVal']="";
    numPadUtils['numPadTitle']="";
    numPadUtils['numPadSubTitle']="";
    numPadUtils['vendorIndex']=-1;
    numPadUtils['productIndex']=-1;
  }

  @override
  void dispose(){
    widgets.clear();
    materialForm.clear();
    clearOnDispose();
    super.dispose();
  }
}
