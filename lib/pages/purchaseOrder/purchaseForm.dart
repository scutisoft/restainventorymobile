
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/model/parameterModel.dart';
import 'package:flutter_utils/utils/apiUtils.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:flutter_utils/utils/utils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
  String page="PurchaseOrder";
  TraditionalParam traditionalParam=TraditionalParam(
      getByIdSp: "IV_Purchase_GetbyPurchaseOrderIdDetail",
      insertSp: "IV_Purchase_InsertPurchaseOrderDetail",
      updateSp: "IV_Purchase_UpdatePurchaseOrderDetail"
  );
  var isKeyboardVisible=false.obs;

  Rxn<DateTime> expectedDate=Rxn<DateTime>();

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
                    title: "${widget.isEdit?"Update":"Add"} Purchase Order",
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
                        widgets['Notes'],
                        LeftHeader(title: "+ Add Purchase Material"),
                        LeftHeader(title: "Vendor"),
                        widgets['VendorId'],
                        LeftHeader(title: "Material"),
                        widgets['MaterialId'],
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



            Obx(() => Loader(value: showLoader.value,)),
          ],
        )
    );
  }

  @override
  void assignWidgets() async{
    widgets.clear();
    widgets['ExpectedDate']=HiddenController(dataname: "ExpectedDate");
    widgets['Notes']=AddNewLabelTextField(
      dataname: 'Notes',
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
    widgets['VendorId']=SlideSearch(dataName: "VendorId",
      selectedValueFunc: (e){
        console(e);
        fillTreeDrp(widgets, "MaterialId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,
            refType: "MaterialId",refId: e['Id'],needToDisable: true);
      },
      hinttext: "Select Vendor",data: []);

    widgets['MaterialId']=SlideSearch(dataName: "MaterialId",
      selectedValueFunc: (e){
        console(e);
        //onMaterialChange(e);
      },
      hinttext: "Select Material",data: [],propertyId: "MaterialId",propertyName: "MaterialName",);


    if(!widget.isEdit){
      expectedDate.value=DateTime.now();
    }

    fillTreeDrp(widgets, "VendorId",page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "",clearValues: false);
  }


  @override
  void dispose(){
    widgets.clear();
    clearOnDispose();
    super.dispose();
  }
}
