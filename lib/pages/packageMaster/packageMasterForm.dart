
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
class PackageMasterForm extends StatefulWidget {
  bool isEdit;
  Function? closeCb;
  String dataJson;
  PackageMasterForm({Key? key,this.isEdit=false,this.closeCb,this.dataJson=""}) : super(key: key);
  @override
  State<PackageMasterForm> createState() => _PackageMasterFormState();
}

class _PackageMasterFormState extends State<PackageMasterForm> with HappyExtension implements HappyExtensionHelperCallback {
  Map widgets={};
  Map recipeForm={};
  String page="PackageMaster";
  TraditionalParam traditionalParam=TraditionalParam(
      getByIdSp: "IV_PackageMaster_GetPackageByIdDetail",
      insertSp: "IV_PackageMaster_InsertPackageDetail",
      updateSp: "IV_PackageMaster_UpdatePackageDetail"
  );
  var isKeyboardVisible=false.obs;

  var unitName="Unit".obs;

  RxList<dynamic> recipeList=RxList<dynamic>();


  var isCartOpen=false.obs;

  var selectedIndex=(-1).obs;
  final FlutterUtils _flutterUtils=FlutterUtils();

  late SwipeActionController controller;

  var numPadUtils={
    "isNumPadOpen":false,
    "numPadVal":"",
    "numPadTitle":"",
    "numPadSubTitle":"",
    "productIndex":-1
  }.obs;
  double sw=SizeConfig.screenWidth!-30;
  double col1Wid=0.0,col2Wid=0.0,col3Wid=0.0;

  @override
  void initState(){
    controller = SwipeActionController(selectedIndexPathsChangeCallback: (changedIndexPaths, selected, currentCount) {},);
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
                  title: "${widget.isEdit?"Update":"Add"} Package",
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
                      LeftHeader(title: "Package Name"),
                      widgets['PackageName'],
                      inBtwHei(height: 20),
                      Row(
                        children: [
                          LeftHeader(title: "+ Add Recipe",width: SizeConfig.screenWidth!-140,),
                          const Spacer(),
                          Obx(() => cartIcon(
                              onTap:(){
                                isCartOpen.value=true;
                              },
                              count: recipeList.length
                          )),
                          const SizedBox(width: 20,)
                        ],
                      ),

                      inBtwHei(height: 30),
                      recipeForm['RecipeId'],
                      inBtwHei(),
                      recipeForm['Quantity'],
                      inBtwHei(height: 30),
                      Align(
                        alignment: Alignment.center,
                        child: DoneBtn(onDone: onRecipeAdd, title: "Add"),
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
            onSave: () {
              sysSubmit(widgets,
                  isEdit: widget.isEdit,
                  needCustomValidation: true,
                  traditionalParam: traditionalParam,
                  loader: showLoader,
                  extraParam: MyConstants.extraParam,
                  onCustomValidation: () {
                    if (recipeList.isEmpty) {
                      CustomAlert()
                          .cupertinoAlert("Select Recipe to add Package...");
                      return false;
                    }
                    foundWidgetByKey(widgets, "Datajson", needSetValue: true, value: jsonEncode(recipeList));
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
              text: "Recipe (${recipeList.length} Numbers)",
              textStyle: ts20M(ColorUtil.themeBlack,fontsize: 18),
            )),
            widgets: [
              Row(
                children: [
                  GridTitleCard(
                    width: col1Wid+col2Wid,
                    content: "Recipe Name",
                  ),
                  GridTitleCard(
                    width: col3Wid,
                    content: "Qty",
                  ),
                ],
              ),
              const SwipeNotes(),
              Expanded(
                child: Obx(() => ListView.builder(
                  shrinkWrap: true,
                  itemCount: recipeList.length,
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
                            numPadUtils['isNumPadOpen']=true;
                            numPadUtils['numPadTitle']=recipeList[i]['RecipeName'];
                            numPadUtils['numPadSubTitle']="Quantity";
                            numPadUtils['numPadVal']=recipeList[i]['Quantity'];
                            numPadUtils['numPadUnit']=recipeList[i]['UnitShortCode'];
                            numPadUtils['productIndex']=i;
                            controller.closeAllOpenCell();
                          },needBG: true),
                          swipeActionDelete((handler) async {
                            recipeList.removeWhere((element) => element['RecipeId']==recipeList[i]['RecipeId']);
                            await handler(true);
                          },needBG: true),
                        ],
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 0),
                          padding: const EdgeInsets.fromLTRB(5, 12, 5, 12),
                          decoration:ColorUtil.formContBoxDec,
                          child: Row(
                            children: [
                              SizedBox(
                                width:(col1Wid+col2Wid)-15-30,
                                child: Text("${recipeList[i]['RecipeName']}",
                                  style: ts20M(ColorUtil.themeBlack,fontsize: 18),
                                ),
                              ),
                              FittedText(
                                height: 25,
                                width:col2Wid+30,
                                alignment: Alignment.centerRight,
                                text: "${recipeList[i]['Quantity']} ${recipeList[i]['UnitShortCode']}",
                                textStyle: ts20M(ColorUtil.red2,fontsize: 18),
                              ),
                            ],
                          ),
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
              onRecipeUpdate();
            },
          )),
        ],
      ),
    );
  }

  @override
  void assignWidgets() async{
    widgets['PackageId']=HiddenController(dataname: "PackageId");
    widgets['Datajson']=HiddenController(dataname: "Datajson");
    widgets['PackageName']=AddNewLabelTextField(
      dataname: 'PackageName',
      hasInput: true,
      required: true,
      labelText: "Package Name",
      regExp: null,
      onChange: (v){},
      onEditComplete: (){
        FocusScope.of(context).unfocus();
      },
    );

    recipeForm['RecipeId']=SlideSearch(dataName: "RecipeId",
      selectedValueFunc: (e){
        onRecipeChg(e);

      },
      hinttext: "Select Recipe",data: []);
    recipeForm['Quantity']=AddNewLabelTextField(
      dataname: 'Quantity',
      hasInput: true,
      required: true,
      labelText: "Quantity",
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
        child: Obx(() => Text("${unitName.value}",style: ts20M(ColorUtil.themeWhite),)),
      ),
      textLength: MyConstants.maximumQty,
    );

    fillTreeDrp(recipeForm, "RecipeId",clearValues: false,page: page,refId: "",extraParam: MyConstants.extraParam,spName: Sp.masterSp,);
    await parseJson(widgets, "",
        dataJson: widget.dataJson,
        traditionalParam: traditionalParam,
        extraParam: MyConstants.extraParam,
        loader: showLoader, resCb: (e) {
          try {
            console("parseJson $e");
            recipeList.value=e['Table1'];
          } catch (e, t) {
            assignWidgetErrorToastLocal(e, t);
          }
        });

  }

  double recipePrice=0.0,recipeCost=0.0;
  int unitId=-1;
  void onRecipeChg(e) async{
    recipeCost=0.0;recipePrice=0.0;
    List<ParamModel> parameterList=await getParamEssential(extraParam: MyConstants.extraParam);
    parameterList.add(ParamModel(Key: "HiraricalId", Type: "String", Value: ""));
    parameterList.add(ParamModel(Key: "RefId", Type: "String", Value: e['Id']));
    parameterList.add(ParamModel(Key: "RefTypeName", Type: "String", Value: ""));
    parameterList.add(ParamModel(Key: "TypeName", Type: "String", Value: "RecipeDetail"));
    parameterList.add(ParamModel(Key: "Page", Type: "String", Value: page));
    _flutterUtils.getInvoke(parameterList,loader: showLoader,url: "${GetBaseUrl()}/api/Common/GetMasterDataList").then((value){
      if(value[0]){
        var parsed=jsonDecode(value[1]);
        if(parsed['Table'].length>0){
          unitName.value=parsed['Table'][0]['UnitShortCode'];
          unitId=parsed['Table'][0]['UnitId'];
          recipePrice=parseDouble(parsed['Table'][0]['Price']);
        }
      }
    });
  }

  void onRecipeAdd() async{
    List<ParamModel> a=await getFrmCollection(recipeForm);
    if(a.isNotEmpty){
      FocusScope.of(context).unfocus();
      Map  rDrp=recipeForm['RecipeId'].getValueMap();
      double qty=parseDouble(recipeForm['Quantity'].getValue());
      int existIndex=recipeList.indexWhere((element) => element['RecipeId']==rDrp['Id']);
      if(existIndex==-1){
        var obj={
          "PackageMasterRecipeMappingId": null,
          "ProductId": null,
          "RecipeId": rDrp['Id'],
          "RecipeName": rDrp['Text'],
          "Quantity": qty,
          "UnitId": unitId,
          "UnitShortCode": unitName.value,
          "Price": recipePrice,
          "Cost": Calculation().mul(qty, recipePrice),
          "IsActive": "1"
        };
        recipeList.add(obj);
        clearAllV2(recipeForm);
        unitId=-1;
        recipePrice=0.0;
        recipeCost=0.0;
      }
      else{
        CustomAlert().cupertinoAlert("Recipe Already Exists...");
      }
    }
  }

  void onRecipeUpdate(){
    double qty=parseDouble(numPadUtils['numPadVal']);
    if(qty<=0){
      CustomAlert().cupertinoAlert("Enter Quantity...");
      return;
    }
    int index=numPadUtils['productIndex'] as int;
    if(index!=-1){
      recipeList[index]['Quantity']=qty;
      recipeList[index]['Cost']=Calculation().mul(qty,   recipeList[index]['Price']);
      numPadUtils['isNumPadOpen']=false;
      clearNumPadUtils();
      recipeList.refresh();
    }
  }

  void clearNumPadUtils() {
    numPadUtils['numPadVal'] = "";
    numPadUtils['numPadTitle'] = "";
    numPadUtils['numPadSubTitle'] = "";
    numPadUtils['numPadUnit'] = "";
    numPadUtils['productIndex'] = -1;
    numPadUtils['numPadType'] = 0;
  }
}
