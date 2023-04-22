import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_utils/mixins/extensionMixin.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:flutter_utils/utils/extensionUtils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restainventorymobile/pages/commonView.dart';
import 'package:restainventorymobile/utils/utilWidgets.dart';
import 'package:restainventorymobile/widgets/alertDialog.dart';
import '/widgets/inventoryWidgets.dart';
import '/utils/constants.dart';
import '/utils/utils.dart';
import '/api/apiUtils.dart';
import '/utils/colorUtil.dart';
import '/widgets/listView/HE_ListView.dart';
import '/widgets/loader.dart';
import '/utils/sizeLocal.dart';
import '/widgets/customAppBar.dart';
import 'indentForm.dart';
class IndentGrid extends StatefulWidget {
  VoidCallback navCallback;
  IndentGrid({Key? key,required this.navCallback}) : super(key: key);

  @override
  State<IndentGrid> createState() => _IndentGridState();
}

class _IndentGridState extends State<IndentGrid> with HappyExtension implements HappyExtensionHelperCallback{


  Map widgets={};
  var totalCount=0.obs;
  late HE_ListViewBody he_listViewBody;

  @override
  void initState() {
    he_listViewBody=HE_ListViewBody(
      data: [],
      getWidget: (e){
        return HE_IndentContent(
          data: e,
          onDelete: (dataJson){
            gridDelete(() {
              sysDeleteHE_ListView(he_listViewBody, "IndentOrderId",dataJson: dataJson,loader: showLoader,
                  traditionalParam: TraditionalParam(executableSp: "IV_Indent_DeleteIndentOrderDetail"),isCustomDialog: true,successCallback: deleteCallback);
            });
          },
          onEdit: (updatedMap){
            he_listViewBody.updateArrById("IndentOrderId", updatedMap);
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
            title: "Indent Order",
            onTap: widget.navCallback,
          ),
          CustomAppBar2(
            title:  "Total Indent Order",
            subTitle: "Indent Available",
            count: totalCount,
            addCb: (){
              fadeRoute(IndentForm(closeCb: (e){
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
          Obx(() => NoData(show: he_listViewBody.widgetList.isEmpty,)),
        ],
      ),
    );
  }

  var dj={"FromDate":DateFormat(MyConstants.dbDateFormat).format(DateTime.now()),
    "ToDate":DateFormat(MyConstants.dbDateFormat).format(DateTime.now())
  };

  @override
  void assignWidgets() {
    he_listViewBody.clearData();
    parseJson(widgets, "",traditionalParam: TraditionalParam(getByIdSp: "IV_Indent_GetIndentOrderDetail"),needToSetValue: false,resCb: (res){
      console(res);
      try{
        totalCount.value=res['Table'].length;
        he_listViewBody.assignWidget(res['Table']);
      }catch(e){}
    },loader: showLoader,dataJson: jsonEncode(dj),extraParam: MyConstants.extraParam);
  }

  @override
  void dispose(){
    he_listViewBody.clearData();
    clearOnDispose();
    super.dispose();
  }
}


class HE_IndentContent extends StatelessWidget implements HE_ListViewContentExtension{
  Map data;
  Function(Map)? onEdit;
  Function(String)? onDelete;
  GlobalKey globalKey;
  HE_IndentContent({Key? key,required this.data,this.onEdit,this.onDelete,required this.globalKey}) : super(key: key){
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
                    Text("${dataListener['IndentOrderNumber']}",style: ts20M(ColorUtil.red),),
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
                  inBtwHei(height: 3),
                  Text("${dataListener['DeliveryType']}",style: ts20M(ColorUtil.red,fontfamily: 'AH',fontsize: 18),),
                  inBtwHei(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      EyeIcon(
                        onTap: (){
                          fadeRoute(CommomView(
                              pageTitle: "Indent Order",
                            spName: "IV_Indent_GetIndentOrderViewDetail",
                            dataJson: getDataJsonForGrid({"IndentOrderId":dataListener['IndentOrderId']}),
                            page: "Indent",
                          ));
                        },
                      ),
                      GridEditIcon(
                        hasAccess: dataListener['IsEdit'],
                        onTap: (){
                          fadeRoute(IndentForm(
                            isEdit: true,
                            dataJson: getDataJsonForGrid({"IndentOrderId":dataListener['IndentOrderId']}),
                            closeCb: (e){
                              updateDataListener(e['Table'][0]);
                              onEdit!(e['Table'][0]);
                            },
                          ));
                        },
                      ),
                      GridDeleteIcon(
                        hasAccess: dataListener['IsDelete'],
                        onTap: (){
                          onDelete!(getDataJsonForGrid({"IndentOrderId":dataListener['IndentOrderId']}));
                        },
                      ),
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