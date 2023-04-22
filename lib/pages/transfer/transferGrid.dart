import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_utils/mixins/extensionMixin.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:flutter_utils/utils/extensionUtils.dart';
import 'package:get/get.dart';
import '../commonView.dart';
import '/pages/transfer/transferForm.dart';
import '/widgets/inventoryWidgets.dart';
import '/utils/constants.dart';
import '/utils/utils.dart';
import '/api/apiUtils.dart';
import '/utils/colorUtil.dart';
import '/widgets/listView/HE_ListView.dart';
import '/widgets/loader.dart';
import '/utils/sizeLocal.dart';
import '/widgets/customAppBar.dart';

class TransferGrid extends StatefulWidget {
  VoidCallback navCallback;
  TransferGrid({Key? key,required this.navCallback}) : super(key: key);

  @override
  State<TransferGrid> createState() => _TransferGridState();
}

class _TransferGridState extends State<TransferGrid> with HappyExtension implements HappyExtensionHelperCallback{


  Map widgets={};
  var totalCount=0.obs;
  late HE_ListViewBody he_listViewBody;

  @override
  void initState() {
    he_listViewBody=HE_ListViewBody(
      data: [],
      getWidget: (e){
        return HE_TransferContent(
          data: e,
          onDelete: (dataJson){
            //sysDeleteHE_ListView(he_listViewBody, "LandId",dataJson: dataJson);
          },
          onEdit: (updatedMap){
            he_listViewBody.updateArrById("TransferOrderId", updatedMap);
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
            title: "Transfer Material",
            onTap: widget.navCallback,
          ),
          CustomAppBar2(
            title:  "Total Transfer",
            subTitle: "Transfer Available",
            count: totalCount,
            addCb: (){
              fadeRoute(TransferForm(closeCb: (e){
                he_listViewBody.addData(e['Table'][0]);
                totalCount.value=he_listViewBody.data.length;
              },));
            },
          ),
          Flexible(child:he_listViewBody),
          Obx(() => NoData(show: he_listViewBody.widgetList.isEmpty,)),
        ],
      ),
    );
  }



  @override
  void assignWidgets() {
    var dj={"TransferOrderId":null };
    parseJson(widgets, "",traditionalParam: TraditionalParam(getByIdSp: "IV_Transfer_GetTransferOrderDetail"),needToSetValue: false,resCb: (res){
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


class HE_TransferContent extends StatelessWidget implements HE_ListViewContentExtension{
  Map data;
  Function(Map)? onEdit;
  Function(String)? onDelete;
  GlobalKey globalKey;
  HE_TransferContent({Key? key,required this.data,this.onEdit,this.onDelete,required this.globalKey}) : super(key: key){
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
                    Text("${dataListener['TransferOrderNumber']}",style: ts20M(ColorUtil.red),),
                    inBtwHei(),
                    Text("${dataListener['Source']}",style: ts20M(ColorUtil.themeBlack),),
                    inBtwHei(),
                    Text("${dataListener['Destination']}",style: ts20M(ColorUtil.themeBlack),),
                    inBtwHei(),
                    StatusTxt(status: dataListener['Status']),

                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("${dataListener['Date']}",style: ts20M(ColorUtil.red,fontfamily: 'AH',fontsize: 18),),
                  //inBtwHei(height: 3),
                  //Text("${dataListener['DeliveryType']}",style: ts20M(ColorUtil.red,fontfamily: 'AH',fontsize: 18),),
                  inBtwHei(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      EyeIcon(
                        onTap: (){
                          fadeRoute(CommomView(
                            pageTitle: "Transfer Order",
                            spName: "IV_Transfer_GetTransferOrderViewDetail",
                            page: "Transfer",
                            dataJson: getDataJsonForGrid({
                              "TransferOrderId":dataListener['TransferOrderId'],
                            }),
                          ));
                        },
                      ),
                      GridEditIcon(
                        hasAccess: dataListener['IsEdit'],
                        onTap: (){
                          /*fadeRoute(IndentForm(
                            isEdit: true,
                            dataJson: getDataJsonForGrid({"IndentOrderId":dataListener['IndentOrderId']}),
                            closeCb: (e){
                              updateDataListener(e['Table'][0]);
                              onEdit!(e['Table'][0]);
                            },
                          ));*/
                        },
                      ),
                      GridDeleteIcon(hasAccess: dataListener['IsDelete'],),
                    ],
                  )
                ],
              )

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