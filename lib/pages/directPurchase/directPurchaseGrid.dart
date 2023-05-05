import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_utils/mixins/extensionMixin.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:flutter_utils/utils/extensionUtils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restainventorymobile/pages/directPurchase/directPurchaseForm.dart';
import '../commonView.dart';
import '/utils/constants.dart';
import '/utils/utils.dart';
import '/api/apiUtils.dart';
import '/utils/colorUtil.dart';
import '/widgets/listView/HE_ListView.dart';
import '/widgets/loader.dart';
import '/utils/sizeLocal.dart';
import '/widgets/customAppBar.dart';

class DirectPurchaseGrid extends StatefulWidget {
  VoidCallback navCallback;
  DirectPurchaseGrid({Key? key,required this.navCallback}) : super(key: key);

  @override
  State<DirectPurchaseGrid> createState() => _DirectPurchaseGridState();
}

class _DirectPurchaseGridState extends State<DirectPurchaseGrid> with HappyExtension implements HappyExtensionHelperCallback{


  Map widgets={};
  var totalCount=0.obs;
  late HE_ListViewBody he_listViewBody;
  RxBool loader=RxBool(false);

  @override
  void initState() {
    he_listViewBody=HE_ListViewBody(
      data: [],
      getWidget: (e){
        return HE_DirectPurchaseContent(
          data: e,
          onDelete: (dataJson){

          },
          onEdit: (updatedMap){
            he_listViewBody.updateArrById("PurchaseOrderId", updatedMap);
          },
          globalKey: GlobalKey(),
        );
      },
    );
    assignWidgets();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeConfig.screenHeight,
      width: SizeConfig.screenWidth,
      child: Column(
        children: [
          CustomAppBar(
            title: "Direct Purchase",
            onTap: widget.navCallback,
          ),
          CustomAppBar2(
            title:  "Total Direct Purchase",
            subTitle: "Available",
            count: totalCount,
            addCb: (){
              fadeRoute(DirectPurchaseForm(closeCb: (e){
                he_listViewBody.addData(e['Table'][0]);
                totalCount.value=he_listViewBody.data.length;
              },));
            },
            needDatePicker: true,
            onDateSel: (a){
              dj=a;
              assignWidgets();
            },
          ),
          Flexible(child:he_listViewBody),
          Obx(() => NoData(show: he_listViewBody.widgetList.isEmpty && !loader.value,)),
          ShimmerLoader(loader: loader,),
        ],
      ),
    );
  }

  var dj={"FromDate":DateFormat(MyConstants.dbDateFormat).format(DateTime.now()),
    "ToDate":DateFormat(MyConstants.dbDateFormat).format(DateTime.now())
  };

  @override
  void assignWidgets() {

    parseJson(widgets, "",traditionalParam: TraditionalParam(getByIdSp: "IV_PurchaseDirectAndFreeAndProcessed_GetPurchaseOrderDirectAndFreeAndProcessedDetail"),needToSetValue: false,resCb: (res){
      console(res);
      try{
        totalCount.value=res['Table'].length;
        he_listViewBody.assignWidget(res['Table']);
      }catch(e){}
    },loader: showLoader,dataJson:  jsonEncode(dj),extraParam: MyConstants.extraParam);
  }

  @override
  void dispose(){
    he_listViewBody.clearData();
    clearOnDispose();
    super.dispose();
  }
}


class HE_DirectPurchaseContent extends StatelessWidget implements HE_ListViewContentExtension{
  Map data;
  Function(Map)? onEdit;
  Function(String)? onDelete;
  GlobalKey globalKey;
  HE_DirectPurchaseContent({Key? key,required this.data,this.onEdit,this.onDelete,required this.globalKey}) : super(key: key){
    dataListener.value=data;
  }

  var dataListener={}.obs;
  //var separatorHeight = 50.0.obs;

  @override
  Widget build(BuildContext context) {
    /*WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      separatorHeight.value=parseDouble(globalKey.currentContext!.size!.height)-30;
    });*/
    return Obx(
            ()=> Container(
          key: globalKey,
          margin: const EdgeInsets.only(bottom: 10,left: 15,right: 10),
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
                    Text("${dataListener['Date']}",style: ts20M(ColorUtil.red,fontfamily: 'AH',fontsize: 18),),
                    inBtwHei(),
                    gridCardText("Type: ", dataListener['PurchaseOrderTypeName']),
                    inBtwHei(),
                    gridCardText("No of Material: ", dataListener['NoOfMaterial']),
                    inBtwHei(),
                    Text(getRupeeString(dataListener['TotalAmount']),style: ts20M(ColorUtil.themeBlack,fontfamily: 'AH',fontsize: 18),),
                  ],
                ),
              ),
              EyeIcon(
                onTap: (){
                  fadeRoute(CommomView(
                    pageTitle: "Direct Purchase",
                    spName: "IV_PurchaseDirectAndFreeAndProcessed_GetByIdPurchaseOrderDirectAndFreeAndProcessedViewDetail",
                    page: "DirectPurchase",
                    dataJson: getDataJsonForGrid({
                      "PurchaseOrderId":dataListener['PurchaseOrderId'],
                      "PurchaseOrderTypeId":dataListener['PurchaseOrderTypeId'],
                    }),
                  ));
                },
              ),
              /*GridEditIcon(
                hasAccess: true,
                onTap: (){
                  fadeRoute(DepartmentDistributionForm(
                    isEdit: true,
                    dataJson: getDataJsonForGrid({"PurchaseOrderId":dataListener['PurchaseOrderId']}),
                    closeCb: (e){
                      updateDataListener(e['Table'][0]);
                      onEdit!(e['Table'][0]);
                    },
                  ));
                },
              ),*/
              /* GridDeleteIcon(
                hasAccess: true,
                onTap: (){
                  onDelete!(getDataJsonForGrid({"PurchaseOrderId":dataListener['PurchaseOrderId']}));
                },
              ),*/

            ],
          ),
        )
    );
  }

  @override
  updateDataListener(Map data) {
    data.forEach((key, value) {
      if(dataListener.containsKey(key)){
        dataListener[key]=value;
      }
    });
  }
}