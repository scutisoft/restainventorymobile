
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/mixins/extensionMixin.dart';
import 'package:flutter_utils/model/parameterModel.dart';
import 'package:flutter_utils/utils/apiUtils.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:flutter_utils/utils/extensionUtils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../widgets/customCheckBox.dart';
import '../../widgets/fittedText.dart';
import '../../widgets/numberPadPopUp/numberPadPopUp.dart';
import '../../widgets/staticColumnScroll/reportGrid.dart';
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

class Report extends StatefulWidget {
  Map reportDetail;
  Report({Key? key,required this.reportDetail}) : super(key: key);

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {

  final FlutterUtils _flutterUtils=FlutterUtils();

  List<ReportGridStyleModel> columnList=[];
  List<dynamic> primaryList=[];
  RxList<dynamic> filterList=RxList();

  @override
  void initState(){
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageBody(
      body: Stack(
        children: [
          Container(
            height: SizeConfig.screenHeight,
            width: SizeConfig.screenWidth,
            color: Colors.white,
            child: Column(
              children: [
                CustomAppBar(
                  title: "${widget.reportDetail['Title']}",
                  width: SizeConfig.screenWidth!-100,
                  prefix: ArrowBack(
                    onTap: (){
                      Get.back();
                    },
                  ),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.4)))
                  ),
                ),
                inBtwHei(height: 10),
                addNewLabelTextField,
                Obx(() =>
                    ReportGrid(
                      topMargin: 10,
                      gridBodyReduceHeight: 0,
                      selectedIndex: -1,
                      gridData: filterList.value,
                      gridDataRowList: columnList,
                      staticColWidth: 180,
                      func: (index){
                      },
                    )
                ),

              ],
            ),
          ),

          Obx(() => Loader(value: showLoader.value,)),
        ],
      ),
    );
  }

  late AddNewLabelTextField addNewLabelTextField;

  void getData() async{
    addNewLabelTextField=AddNewLabelTextField(
      dataname: 'Search',
      hasInput: false,
      required: false,
      labelText: "Search",
      regExp: MyConstants.addressRegEx,
      onChange: (v){
        if(v.isEmpty){
          filterList.value=primaryList;
        }
        else{
          filterList.value=primaryList.where((element) => getValuesFromMap(element).contains(v.toLowerCase())).toList();
        }
      },
      onEditComplete: (){
        FocusScope.of(context).unfocus();
      },
      suffixIcon: Icon(Icons.search,size: 25,color: ColorUtil.red2,),
    );
    if(widget.reportDetail['ReportName']=="StockReport"){
      columnList=[
        ReportGridStyleModel(dataName: "MaterialName",columnName: "Material Name",columnType: ColumnType.material,brandDataName: "MaterialBrandName"),
        ReportGridStyleModel(dataName: "MaterialCategoryName",columnName: "Category",width: 120,maxWidth: 120),
        ReportGridStyleModel(dataName: "TotalPrimaryAvailableStock",columnName: "Total Qty",columnType: ColumnType.colSpan,width: 200,
        colSpanTitle: ["Primary","Secondary"],brandDataName: "TotalSecondaryAvailableStock"),
        ReportGridStyleModel(dataName: "PrimaryUsedStock",columnName: "Used Qty",columnType: ColumnType.colSpan,width: 200,
        colSpanTitle: ["Primary","Secondary"],brandDataName: "SecondaryUsedStock"),
        ReportGridStyleModel(dataName: "BalancePrimaryStock",columnName: "Available Stock Qty",columnType: ColumnType.colSpan,width: 200,
        colSpanTitle: ["Primary","Secondary "],brandDataName: "BalanceSecondaryStock"),
      ];
    }
    setState(() {});
    List<ParamModel> parameterList=await getParamEssential(extraParam: MyConstants.extraParam);
    parameterList.add(ParamModel(Key: "ReportName", Type: "String", Value: widget.reportDetail['ReportName']));
    parameterList.add(ParamModel(Key: "ReportType", Type: "String", Value: ""));
    parameterList.add(ParamModel(Key: "ReportCategory", Type: "String", Value: ""));
    _flutterUtils.getInvoke(parameterList,loader: showLoader,url: "${GetBaseUrl()}${widget.reportDetail['Url']}").then((value){

      if(value[0]){
        var parsed=jsonDecode(value[1]);
        //console(parsed);
        primaryList=parsed['Table'];
        filterList.value=primaryList;
      }
    });
  }
}
