

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/mixins/extensionMixin.dart';
import 'package:flutter_utils/model/parameterModel.dart';
import 'package:flutter_utils/utils/apiUtils.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:get/get.dart';
import '../../widgets/alertDialog.dart';
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
  final FlutterUtils _flutterUtils=FlutterUtils();

  @override
  void initState(){
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
                      var obj={
                        "PackageDistributionId": null,
                        "PackageId": widgets['PackageId'].getValue(),
                        "OutletId": widgets['OutletId'].getValue(),
                        "ProductId": widgets['ProductId'].getValue(),
                        "PackageDistributionQuantity": widgets['PackageDistributionQuantity'].getValue(),
                        "ProductionQuantity": widgets['ProductionQuantity'].getValue(),
                      };
                      foundWidgetByKey(widgets, "Datajson",needSetValue: true,value: jsonEncode([obj]));return true;
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
            Obx(() => Loader(value: showLoader.value,)),
          ],
        )
    );
  }

  @override
  void assignWidgets() async{
    widgets.clear();
    widgets['Datajson']=HiddenController(dataname: "Datajson");
    widgets['ProductionQuantity']=AddNewLabelTextField(
      dataname: 'ProductionQuantity',
      hasInput: true,
      required: false,
      labelText: "Production Quantity",
      regExp: MyConstants.decimalReg,
      isEnabled: false,
      onChange: (v){},
      onEditComplete: (){
        FocusScope.of(context).unfocus();
      },
      textInputType: TextInputType.number,
    );
    widgets['PackageDistributionQuantity']=AddNewLabelTextField(
      dataname: 'ProductionQuantity',
      hasInput: true,
      required: true,
      labelText: "Quantity",
      regExp: MyConstants.decimalReg,
      onChange: (v){},
      onEditComplete: (){
        FocusScope.of(context).unfocus();
      },
      textInputType: TextInputType.number,
      textLength: MyConstants.maximumQty,
    );
    widgets['PackageId']=SlideSearch(dataName: "PackageId",selectedValueFunc: (e){getProducts(); }, hinttext: "Select Package",data: []);
    widgets['OutletId']=SlideSearch(dataName: "OutletId",selectedValueFunc: (e){getProducts(); }, hinttext: "Select Outlet",data: []);
    widgets['ProductId']=SlideSearch(dataName: "ProductId",selectedValueFunc: (e){ }, hinttext: "Select Product",data: [],isEnable: false,);

    fillTreeDrp(widgets, "PackageId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "",clearValues: false);
    fillTreeDrp(widgets, "OutletId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "",clearValues: false);


    await parseJson(widgets, "",dataJson: widget.dataJson,traditionalParam: traditionalParam,extraParam: MyConstants.extraParam,loader: showLoader,
        resCb: (e){
          try{
            // console("parseJson $e");
          }catch(e,t){
            assignWidgetErrorToastLocal(e,t);
          }
        });
  }


  void getProducts(){
    var outletId=widgets['OutletId'].getValue();
    var packageId=widgets['PackageId'].getValue();
    console("outletId $outletId $packageId");
    if(outletId!=null && packageId!=null){
      fillTreeDrp(widgets, "ProductId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "",
          clearValues: true,needToDisable: true,refId: outletId,hierarchicalId: packageId);
    }
    if(packageId!=null){
      getProductionQty(packageId);
    }
  }

  void getProductionQty(packageId) async{
    foundWidgetByKey(widgets, "ProductionQuantity",needSetValue: true,value: "0.0");
    List<ParamModel> parameterList=await getParamEssential(extraParam: MyConstants.extraParam);
    parameterList.add(ParamModel(Key: "PackageId", Type: "String", Value: packageId));

    _flutterUtils.getInvoke(parameterList,loader: showLoader,url: "${GetBaseUrl()}/api/PackageProductApi/GetPackageProductionDetail").then((value){
      if(value[0]){
        var parsed=jsonDecode(value[1]);
        if(parsed['Table']!=null && parsed['Table'].length>0){
          foundWidgetByKey(widgets, "ProductionQuantity",needSetValue: true,value: parsed['Table'][0]['PackageQty']);
        }
      }
      else{
        CustomAlert().cupertinoAlert(value[1]);
      }
    });
  }

  @override
  void dispose(){
    widgets.clear();
    clearOnDispose();
    super.dispose();
  }
}
