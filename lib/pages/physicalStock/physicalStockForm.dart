import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/mixins/extensionMixin.dart';
import 'package:flutter_utils/model/parameterModel.dart';
import 'package:flutter_utils/utils/apiUtils.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:get/get.dart';
import 'package:restainventorymobile/widgets/calculation.dart';
import 'package:restainventorymobile/widgets/loader.dart';
import 'package:restainventorymobile/widgets/searchDropdown/search2.dart';
import '../../widgets/staticColumnScroll/materialInnerGrid.dart';
import '/api/apiUtils.dart';
import '/api/sp.dart';
import '/utils/constants.dart';
import '/utils/sizeLocal.dart';
import '/utils/utils.dart';
import '/widgets/alertDialog.dart';
import '/widgets/circle.dart';
import '/widgets/customAppBar.dart';
import '/utils/colorUtil.dart';
import '/utils/utilWidgets.dart';

class PhysicalStockForm extends StatefulWidget {
  bool isEdit;
  Function? closeCb;
  String dataJson;
  String packageName;
  PhysicalStockForm({Key? key,this.isEdit=false,this.closeCb,this.dataJson="",this.packageName=""}) : super(key: key);


  @override
  State<PhysicalStockForm> createState() => _PhysicalStockFormState();
}

class _PhysicalStockFormState extends State<PhysicalStockForm> with HappyExtension implements HappyExtensionHelperCallback  {

  Map widgets={};


  RxList<dynamic> productList=RxList();
  List primaryProductList=[];
  final FlutterUtils _flutterUtils=FlutterUtils();

  TraditionalParam traditionalParam=TraditionalParam(
      getByIdSp: "IV_PhysicalStock_GetByPhysicalStockIdDetail",
      insertSp: "IV_PhysicalStock_InsertPhysicalStockDetail",
      updateSp: "IV_PhysicalStock_UpdatePhysicalStockDetail"
  );

  @override
  void initState(){
    assignWidgets();
    super.initState();
  }

  TextStyle headerTS=ts20M(Colors.white,fontsize: 18);
  TextStyle bodyTS=ts20M(ColorUtil.themeBlack,fontsize: 15);
  TextStyle bodyLowerValueTS=ts20M(ColorUtil.red2,fontsize: 15);
  TextStyle bodyHigherValueTS=ts20M(Colors.green,fontsize: 15);

  double width2=140;
  var isKeyboardVisible=false.obs;

  @override
  Widget build(BuildContext context) {
    isKeyboardVisible.value = MediaQuery.of(context).viewInsets.bottom != 0;
    return PageBody(
      body: Container(
        height: SizeConfig.screenHeight,
        child: Stack(
          children: [
            CustomAppBar(
              title: "${widget.isEdit?"Update":"Add"} Physical Stock",
              width: SizeConfig.screenWidth!-100,
              prefix: ArrowBack(
                onTap: (){
                  Get.back();
                },
              ),
            ),

            Positioned(
              top: 75,
              child: Obx(() => MaterialInnerGrid(
                height: SizeConfig.screenHeight!-150,
                staticWidth: 200,
                staticHeaderWidget: Container(
                  width: 200,
                  height: 60,
                  padding: const EdgeInsets.only(left: 15),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(5)),
                    color: ColorUtil.red,
                  ),
                  child: Text("Item",style: headerTS,),
                ),
                staticWidget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: productList.asMap().map((key, value) =>MapEntry(key,
                    GestureDetector(
                      onTap: (){
                      },
                      child: Container(
                        height: 55,
                        width: 200,
                        padding: const EdgeInsets.only(left: 15),
                        // margin: EdgeInsets.only(bottom: key==In.PO_purchaseList.length-1?350:0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(bottom: BorderSide(color: ColorUtil.greyBorder))
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${value['MaterialName']}", style: ts20M(ColorUtil.themeBlack,fontsize: 15),),
                            Visibility(
                              visible: !checkNullEmpty(value['MaterialBrandName']),
                              child:  Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text("${value['MaterialBrandName']}", style: ts20M(ColorUtil.red2,fontsize: 14),),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  ).values.toList(),
                ),
                scrollableHeaderWidget: Row(
                  children: [
                    Container(
                      width: width2,
                      child: Text("Physical Count",style: headerTS,textAlign: TextAlign.center,),
                    ),
                    Container(
                      width: width2,
                      child: Text("Digital Count",style: headerTS,textAlign: TextAlign.center,),
                    ),
                    Container(
                      width: width2,
                      child: Text("Different Count",style: headerTS,textAlign: TextAlign.center,),
                    ),
                    Container(
                      width: width2,
                      child: Text("Digital Price",style: headerTS,textAlign: TextAlign.center,),
                    ),
                    Container(
                      width: width2,
                      child: Text("Physical Price",style: headerTS,textAlign: TextAlign.center,),
                    ),
                    Container(
                      width: width2,
                      child: Text("Different Price",style: headerTS,textAlign: TextAlign.center,),
                    ),
                  ],
                ),
                scrollableWidget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: productList.asMap().map((key, value) =>MapEntry(key,
                      GestureDetector(
                        onTap: (){

                        },
                        child: Container(
                          height: 55,
                          //padding: EdgeInsets.only(top: 0,bottom: 0,),
                          //  margin: EdgeInsets.only(bottom: key==In.PO_purchaseList.length-1?350:0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(bottom: BorderSide(color:ColorUtil.greyBorder))
                          ),
                          child: Row(
                            children: [

                              Container(
                                // height: hei,
                                width: width2,
                                height: 40,
                                padding: EdgeInsets.only(left: 5),
                                child:physicalCountTextEdit(value['PhysicalCount'],key,value['UnitName'])
                                /*child: TextField(
                                  controller: TextEditingController(text: value['PhysicalCount']==null?"":value['PhysicalCount'].toString()),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      suffixIcon: UnitCircle(unitName: value['UnitName'],)
                                  ),
                                  inputFormatters:[
                                    LengthLimitingTextInputFormatter(MyConstants.maximumQty),
                                    FilteringTextInputFormatter.allow(RegExp(MyConstants.decimalReg)),
                                  ],
                                  onChanged: (v){
                                    onPhysicalCountChg(v, key);
                                  },
                                ),*/
                              ),
                              Container(
                                width: width2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text("${value['DigitalCount']}",style: bodyTS,textAlign: TextAlign.center,),
                                    UnitCircle(unitName: value['UnitName'],),
                                  ],
                                ),
                              ),
                              Container(
                                // height: hei,
                                width: width2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text("${value['DifferentCount']}",style: parseDouble(value['DifferentCount']) >0?bodyHigherValueTS:bodyLowerValueTS,textAlign: TextAlign.center,),
                                    UnitCircle(unitName: value['UnitName'],),
                                  ],
                                ),
                              ),

                              Container(
                                width: width2,
                                padding: const EdgeInsets.only(left: 5),
                                alignment: Alignment.centerLeft,
                                child: Text(getRupeeString(value['DigitalValue']),style: bodyTS,textAlign: TextAlign.center,),
                              ),
                              Container(
                                width: width2,
                                padding: const EdgeInsets.only(left: 5),
                                alignment: Alignment.centerLeft,
                                child: Text(getRupeeString(value['PhysicalValue']),style: bodyTS,textAlign: TextAlign.center,),
                              ),
                              Container(
                                width: width2,
                                padding: const EdgeInsets.only(left: 5),
                                alignment: Alignment.centerLeft,
                                child: Text(getRupeeString(value['DifferentValue']),style: parseDouble(value['DifferentValue']) >0?bodyHigherValueTS:bodyLowerValueTS,textAlign: TextAlign.center,),
                              ),
                            ],
                          ),
                        ),
                      )
                  )
                  ).values.toList(),
                ),
              )),
            ),

            SaveCloseBtn(
                isEdit: widget.isEdit,
                onSave: (){
                  sysSubmit(widgets,
                      isEdit: widget.isEdit,
                      needCustomValidation: true,
                      traditionalParam: traditionalParam,
                      loader: showLoader,
                      extraParam: MyConstants.extraParam,
                      onCustomValidation: (){
                        if(productList.isEmpty){
                          CustomAlert().cupertinoAlert("No Materials...");
                          return false;
                        }
                        foundWidgetByKey(widgets, "PhysicalStockListJson",needSetValue: true,value: jsonEncode(productList));

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
                isKeyboardVisible: isKeyboardVisible,saveBtnText: isNeedApproved?"Approve":"Update",),
            Positioned(
                top: 130,
                child: ShimmerLoader(loader: showLoader)),
          ],
        ),
      ),
    );
  }

  bool isNeedApproved=false;

  @override
  void assignWidgets() async{
    widgets['OverAllPhysicalStockId']=HiddenController(dataname: "OverAllPhysicalStockId");
    widgets['PhysicalStockListJson']=HiddenController(dataname: "PhysicalStockListJson");
    if(!widget.isEdit){
      Timer(Duration(milliseconds: 300), () {
        getProductList();
      });
    }

    await parseJson(widgets, "",dataJson: widget.dataJson,traditionalParam: traditionalParam,extraParam: MyConstants.extraParam,loader: showLoader,
    resCb: (e){
      try{
        console("parseJson $e");
        if(e['Table'].length>0){
          primaryProductList=e['Table'];
          productList.value=primaryProductList;
        }
        if(e['Table1']!=null && e['Table1'].length>0){
          isNeedApproved=e['Table1'][0]['IsApproved'];
          setState(() {});
        }
      }catch(e,t){
        assignWidgetErrorToastLocal(e,t);
      }
    });
  }

  void getProductList() async{

    List<ParamModel> parameterList=await getParamEssential(extraParam: MyConstants.extraParam);
    _flutterUtils.getInvoke(parameterList,loader: showLoader,url: "${GetBaseUrl()}/api/PhysicalStockApi/GetPhysicalStockProducts").then((value){
      if(value[0]){
        var parsed=jsonDecode(value[1]);
        if(parsed['Table'].length>0){
          primaryProductList=parsed['Table'];
          productList.value=primaryProductList;
        }
      }
    });
  }

  void onPhysicalCountChg(String value,int index){
    double physicalCount=parseDouble(value);
    if(value.isEmpty){
      productList[index]['PhysicalCount']=null;
      productList[index]['DifferentCount']=0;
      productList[index]['PhysicalValue']=0;
      productList[index]['DifferentValue']=0;
      productList[index]['PhysicalStockTypeId']=3;
    }
    else{
      productList[index]['PhysicalCount']=physicalCount;
      productList[index]['DifferentCount']=Calculation().sub(productList[index]['PhysicalCount'], productList[index]['DigitalCount']);
      productList[index]['PhysicalValue']=Calculation().mul(productList[index]['PhysicalCount'], productList[index]['MaterialPrice']);
      productList[index]['DifferentValue']=Calculation().mul(productList[index]['DifferentCount'], productList[index]['MaterialPrice']);

      if (productList[index]['PhysicalCount'] == productList[index]['DigitalCount']) {
        productList[index]['PhysicalStockTypeId'] = 3;
      }
      else if (productList[index]['PhysicalCount'] > productList[index]['DigitalCount']) {
        productList[index]['PhysicalStockTypeId'] = 1;
      }
      else if (productList[index]['PhysicalCount'] < productList[index]['DigitalCount']) {
        productList[index]['PhysicalStockTypeId'] = 2;
      }
    }
    productList.refresh();
  }

  Widget physicalCountTextEdit(dynamic value,int index,dynamic unitName){
    return TextFormField(
      initialValue: value==null?"":value.toString(),
      //controller: TextEditingController(text: value==null?"":value.toString()),
      //controller: textEditingController,
      keyboardType: TextInputType.number,
      cursorColor: ColorUtil.cursorColor,
      decoration: InputDecoration(
          suffixIcon: UnitCircle(unitName: unitName??"",),
        border: OutlineInputBorder(borderSide: BorderSide(color: ColorUtil.greyBorder)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorUtil.greyBorder)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorUtil.greyBorder)),

        contentPadding: EdgeInsets.symmetric(vertical: 5,horizontal: 5)
      ),
      maxLines: 1,
      inputFormatters:[
        LengthLimitingTextInputFormatter(MyConstants.maximumQty),
        FilteringTextInputFormatter.allow(RegExp(MyConstants.decimalReg)),
      ],
      onChanged: (v){
        onPhysicalCountChg(v, index);
      },
    );
  }
}

class UnitCircle extends StatelessWidget {
  String unitName;
  UnitCircle({Key? key,required this.unitName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCircle(
      hei: 45,
      margin: const EdgeInsets.only(right: 0,top: 12,bottom: 3),
      color: ColorUtil.themeWhite,
      widget: FittedBox(
        child:Text(" $unitName ",style: ts20M(ColorUtil.themeBlack.withOpacity(0.5,),fontsize: 15),),
      ),
    );
  }
}
