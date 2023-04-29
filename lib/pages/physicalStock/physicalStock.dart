import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/mixins/extensionMixin.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:flutter_utils/utils/extensionUtils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restainventorymobile/pages/physicalStock/physicalStockForm.dart';
import '../../widgets/listView/HE_ListView.dart';
import '../../widgets/loader.dart';
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

class PhysicalStock extends StatefulWidget {
  VoidCallback navCallback;
  PhysicalStock({Key? key, required this.navCallback}) : super(key: key);

  @override
  State<PhysicalStock> createState() => _PhysicalStockState();
}

class _PhysicalStockState extends State<PhysicalStock>  with HappyExtension implements HappyExtensionHelperCallback{

  Map widgets={};
  var totalCount=0.obs;
  late HE_ListViewBody he_listViewBody;
  RxBool loader=RxBool(false);

  @override
  void initState() {
    he_listViewBody=HE_ListViewBody(
      data: [],
      getWidget: (e){
        return HE_PhyStockContent(
          data: e,
          onDelete: (dataJson){

          },
          onEdit: (updatedMap){
            he_listViewBody.updateArrById("OverAllPhysicalStockId", updatedMap);
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
            title: "Physical Stock",
            onTap: widget.navCallback,
          ),
          CustomAppBar2(
            title:  "Total Physical Stock",
            subTitle: "Available",
            count: totalCount,
            addCb: (){
              fadeRoute(PhysicalStockForm(closeCb: (e){
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

    parseJson(widgets, "",traditionalParam: TraditionalParam(getByIdSp: "IV_PhysicalStock_GetOverAllPhysicalStockDetail"),needToSetValue: false,resCb: (res){
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
class HE_PhyStockContent extends StatelessWidget implements HE_ListViewContentExtension{
  Map data;
  Function(Map)? onEdit;
  Function(String)? onDelete;
  GlobalKey globalKey;
  HE_PhyStockContent({Key? key,required this.data,this.onEdit,this.onDelete,required this.globalKey}) : super(key: key){
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
                    Text("${dataListener['PhysicalStockDate']}",style: ts20M(ColorUtil.red,fontfamily: 'AH',fontsize: 18),),
                    inBtwHei(),
                    gridCardText("No of Items: ", dataListener['NoOfItems']),
                    inBtwHei(),
                    gridCardText("Different Count: ", dataListener['OverAllDifferentCount']),
                    inBtwHei(),
                    gridCardText("Different Amount: ", getRupeeString(dataListener['OverAllDifferentValue'])),
                    inBtwHei(),
                  ],
                ),
              ),
             /* EyeIcon(
                onTap: (){
                  fadeRoute(CommomView(
                    pageTitle: "Department Distribution",
                    spName: "IV_DepartmentDistribution_ViewDepartmentDistributionDetail",
                    page: "DepartmentDistribution",
                    dataJson: getDataJsonForGrid({
                      "DepartmentDistributionId":dataListener['DepartmentDistributionId'],
                    }),
                  ));
                },
              ),*/
              GridEditIcon(
                hasAccess: dataListener['IsEdit']??false,
                onTap: (){
                  fadeRoute(PhysicalStockForm(
                    isEdit: true,
                    dataJson: getDataJsonForGrid({"OverAllPhysicalStockId":dataListener['OverAllPhysicalStockId']}),
                    closeCb: (e){
                      updateDataListener(e['Table'][0]);
                      onEdit!(e['Table'][0]);
                    },
                  ));
                },
              ),
              /* GridDeleteIcon(
                hasAccess: true,
                onTap: (){
                  onDelete!(getDataJsonForGrid({"DepartmentDistributionId":dataListener['DepartmentDistributionId']}));
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