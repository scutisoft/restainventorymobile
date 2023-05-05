

import 'package:flutter/material.dart';
import 'package:flutter_utils/mixins/extensionMixin.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:get/get.dart';
import '../../widgets/numberPadPopUp/numberPadPopUp.dart';
import '/widgets/loader.dart';
import '/api/apiUtils.dart';
import '/widgets/inventoryWidgets.dart';
import '/api/sp.dart';
import '/utils/constants.dart';
import '/utils/sizeLocal.dart';
import '/utils/utils.dart';
import '/widgets/customAppBar.dart';
import '/widgets/searchDropdown/search2.dart';
import '/utils/utilWidgets.dart';
import '/widgets/swipe2/core/controller.dart';

class PackageDisForm extends StatefulWidget {
  bool isEdit;
  Function? closeCb;
  String dataJson;
  PackageDisForm({Key? key,this.isEdit=false,this.closeCb,this.dataJson=""}) : super(key: key);

  @override
  State<PackageDisForm> createState() => _PackageDisFormState();
}

class _PackageDisFormState extends State<PackageDisForm> with HappyExtension implements HappyExtensionHelperCallback{

  Map widgets={};
  String page="PackageDistribution";
  TraditionalParam traditionalParam=TraditionalParam(
      getByIdSp: "IaV_PackgeDistribution_GetByIdPackageDistributionDetail",
      insertSp: "IV_PackageDistribution_InsertPackageDistributionDetail",
      updateSp: "IV_PackageDistribution_UpdatePackageDistributionDetail"
  );
  var isKeyboardVisible=false.obs;

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
                  CustomAppBar(
                    title: "${widget.isEdit?"Update":"Add"} Package Distribution",
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
                        LeftHeader(title: "Package"),
                        widgets['PackageId'],
                        LeftHeader(title: "Production Quantity"),
                        widgets['ProductionQuantity'],
                        LeftHeader(title: "Outlet"),
                        widgets['OutletId'],
                         LeftHeader(title: "Product"),
                        widgets['ProductId'],
                        LeftHeader(title: "Quantity"),
                        widgets['PackageDistributionQuantity'],
                        inBtwHei(height: 30),
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
                      /*if(purchaseList.isEmpty){
                        CustomAlert().cupertinoAlert("Select Material to Distribute...");
                        return false;
                      }
                      foundWidgetByKey(widgets, "DepartmentDistributionMaterialJson",needSetValue: true,value: jsonEncode(purchaseList));
                      foundWidgetByKey(widgets, "DepartmentDistributionDate",needSetValue: true,value: DateFormat(MyConstants.dbDateFormat).format(expectedDate.value!));
                      return true;*/
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
                // onProductQtyUpdate();
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
    widgets['ProductionQuantity']=AddNewLabelTextField(
      dataname: 'ProductionQuantity',
      hasInput: true,
      required: false,
      labelText: "Production Quantity",
      regExp: null,
      onChange: (v){},
      onEditComplete: (){
        FocusScope.of(context).unfocus();
      },
      textInputType: TextInputType.number,
      maxlines: null,
    );
    widgets['PackageDistributionQuantity']=AddNewLabelTextField(
      dataname: 'ProductionQuantity',
      hasInput: true,
      required: false,
      labelText: "Quantity",
      regExp: null,
      onChange: (v){},
      onEditComplete: (){
        FocusScope.of(context).unfocus();
      },
      textInputType: TextInputType.number,
      maxlines: null,
    );
    widgets['PackageId']=SlideSearch(dataName: "PackageId",selectedValueFunc: (e){ }, hinttext: "Select Package",data: []);
    widgets['OutletId']=SlideSearch(dataName: "OutletId",selectedValueFunc: (e){ }, hinttext: "Select Outlet",data: []);
    widgets['ProductId']=SlideSearch(dataName: "ProductId",selectedValueFunc: (e){ }, hinttext: "Select Product",data: []);

    fillTreeDrp(widgets, "PackageId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "",clearValues: false);
    fillTreeDrp(widgets, "OutletId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "",clearValues: false);
    fillTreeDrp(widgets, "ProductId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "",clearValues: false);

    await parseJson(widgets, "",dataJson: widget.dataJson,traditionalParam: traditionalParam,extraParam: MyConstants.extraParam,loader: showLoader,
        resCb: (e){
          try{
            // console("parseJson $e");
            // batchNo.value=" - ${e['Table'][0]['BatchNumber']}";
          }catch(e,t){
            assignWidgetErrorToastLocal(e,t);
          }
        });

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
    clearOnDispose();
    super.dispose();
  }
}
