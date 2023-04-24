import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_utils/mixins/extensionMixin.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:flutter_utils/utils/extensionUtils.dart';
import 'package:get/get.dart';
import '../commonView.dart';
import '/utils/constants.dart';
import '/utils/utils.dart';
import '/utils/colorUtil.dart';
import '/widgets/listView/HE_ListView.dart';
import '/widgets/loader.dart';
import '/utils/sizeLocal.dart';
import '/widgets/customAppBar.dart';
import 'productionForm.dart';

class ProductionGrid extends StatefulWidget {
  VoidCallback navCallback;
  ProductionGrid({Key? key,required this.navCallback}) : super(key: key);

  @override
  State<ProductionGrid> createState() => _ProductionGridState();
}

class _ProductionGridState extends State<ProductionGrid> with HappyExtension implements HappyExtensionHelperCallback{


  Map widgets={};
  var totalCount=0.obs;
  late HE_ListViewBody he_listViewBody;
  RxBool loader=RxBool(false);

  @override
  void initState() {
    he_listViewBody=HE_ListViewBody(
      data: [],
      getWidget: (e){
        return HE_ProductionContent(
          data: e,
          onDelete: (dataJson){
            //sysDeleteHE_ListView(he_listViewBody, "LandId",dataJson: dataJson);
          },
          onEdit: (updatedMap){
            he_listViewBody.updateArrById("ProductionId", updatedMap);
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
            title: "Production",
            onTap: widget.navCallback,
          ),
          CustomAppBar2(
            title:  "Total Production",
            subTitle: "Production Available",
            count: totalCount,
            addCb: (){
              fadeRoute(ProductionForm(closeCb: (e){
                he_listViewBody.addData(e['Table'][0]);
                totalCount.value=he_listViewBody.data.length;
              },));
            },
          ),
          Flexible(child:he_listViewBody),
          Obx(() => NoData(show: he_listViewBody.widgetList.isEmpty && !loader.value,)),
          ShimmerLoader(loader: loader,),
        ],
      ),
    );
  }

  @override
  void assignWidgets() {
    var dj={"ProductionId":null };
    parseJson(widgets, "",traditionalParam: TraditionalParam(getByIdSp: "IV_Production_GetProductionDetail"),needToSetValue: false,resCb: (res){
      console(res);
      try{
        totalCount.value=res['Table'].length;
        he_listViewBody.assignWidget(res['Table']);
      }catch(e){}
    },loader: loader,dataJson:  jsonEncode(dj),extraParam: MyConstants.extraParam);
  }



  @override
  void dispose(){
    he_listViewBody.clearData();
    clearOnDispose();
    super.dispose();
  }
}


class HE_ProductionContent extends StatelessWidget implements HE_ListViewContentExtension{
  Map data;
  Function(Map)? onEdit;
  Function(String)? onDelete;
  GlobalKey globalKey;
  HE_ProductionContent({Key? key,required this.data,this.onEdit,this.onDelete,required this.globalKey}) : super(key: key){
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
                    gridCardText("Production Quantity: ", dataListener['TotalProductionQty']),
                    inBtwHei(),
                    gridCardText("Production Price: ", dataListener['TotalCost']),
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
                  fadeRoute(ProductionForm(
                    isEdit: true,
                    dataJson: getDataJsonForGrid({"ProductionId":dataListener['ProductionId']}),
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