import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restainventorymobile/utils/constants.dart';
import 'package:restainventorymobile/utils/utils.dart';
import '../../api/apiUtils.dart';
import '../../utils/colorUtil.dart';
import '../../widgets/fittedText.dart';
import '../../widgets/listView/HE_ListView.dart';
import '../../widgets/loader.dart';
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
  late HE_ListViewBody he_listViewBody;

  @override
  void initState() {
    he_listViewBody=HE_ListViewBody(
      data: [],
      getWidget: (e){
        return HE_IndentContent(
          data: e,
          onDelete: (dataJson){
            //sysDeleteHE_ListView(he_listViewBody, "LandId",dataJson: dataJson);
          },
          onEdit: (updatedMap){
            //he_listViewBody.updateArrById("LandId", updatedMap);
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
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex:3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FlexFittedText(
                        text: "Total Indent Order",
                        textStyle: ts20(ColorUtil.themeBlack,fontfamily: 'AM'),
                      ),
                      const SizedBox(height: 5,),
                      Row(
                        children: [
                          Obx(() => Text("${totalIndent.value}",style: ts20(ColorUtil.red,fontfamily: 'AM',fontsize: 36),)),
                          const SizedBox(width: 10,),
                          Text("Indent Available",style: ts20(ColorUtil.text2,fontfamily: 'AM'),),
                        ],
                      )
                    ],
                  ),
                ),
                const Spacer(),
                GridAddIcon(
                  onTap: (){
                    fadeRoute(IndentForm());
                  },
                ),
              ],
            ),
          ),

          Flexible(child:he_listViewBody),
          Obx(() => NoData(show: he_listViewBody.widgetList.isEmpty,)),
        ],
      ),
    );
  }

  var totalIndent=0.obs;

  @override
  void assignWidgets() {
    var dj={"FromDate":DateFormat(MyConstants.dbDateFormat).format(DateTime.now()),
      "ToDate":DateFormat(MyConstants.dbDateFormat).format(DateTime.now())
    };
    parseJson(widgets, "",traditionalParam: TraditionalParam(getByIdSp: "IV_Indent_GetIndentOrderDetail"),needToSetValue: false,resCb: (res){
      console(res);
      try{
        totalIndent.value=res['Table'].length;
        he_listViewBody.assignWidget(res['Table']);
      }catch(e){}
    },loader: showLoader,dataJson: jsonEncode(dj),extraParam: MyConstants.extraParam);
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
                    Container(
                      width: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: ColorUtil.bgColor
                      ),
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      alignment: Alignment.center,
                      child: Text("${dataListener['Status']}",style: ts20(ColorUtil.red,fontsize: 15),maxLines: 1,overflow: TextOverflow.ellipsis,),
                    )
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