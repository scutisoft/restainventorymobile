import 'package:flutter/material.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:restainventorymobile/utils/utilWidgets.dart';
import '../api/apiUtils.dart';
import '../utils/colorUtil.dart';
import '../utils/constants.dart';
import '../widgets/staticColumnScroll/reportDataTableWithoutModel.dart';
import '/utils/utils.dart';
import 'package:get/get.dart';
import '../utils/sizeLocal.dart';
import '../widgets/customAppBar.dart';
class CommomView extends StatefulWidget {
  String pageTitle;
  String page;
  String dataJson;
  String spName;
  CommomView({Key? key,required this.pageTitle,this.dataJson="",required this.spName,required this.page}) : super(key: key);

  @override
  State<CommomView> createState() => _CommomViewState();
}

class _CommomViewState extends State<CommomView> with HappyExtension{

  String title="";
  Map header={};
  Map fromStore={};
  Map toStore={};

  List<ReportGridStyleModel2> columnList=[
    ReportGridStyleModel2(columnName: "Description of Goods",dataName: "MaterialName"),
    ReportGridStyleModel2(columnName: "Requested Quantity",dataName: "RequestedQuantity"),
    ReportGridStyleModel2(columnName:"Approved Quantity",dataName: "ApprovedQuantity"),
  ];
  RxList<dynamic> gridData=RxList();

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
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomAppBar(
                  title: "${widget.pageTitle} View",
                  width: SizeConfig.screenWidth!-100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: ColorUtil.greyBorder))
                  ),
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
                      Container(
                        width: SizeConfig.screenWidth,
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(title,style: ts20M(Color(0xFFA1A1C2),fontsize: 44,fontfamily: 'AH'),),
                            for (MapEntry<dynamic, dynamic> item in header.entries)
                              item.value
                          ],
                        ),
                      ),
                      Container(
                        width: SizeConfig.screenWidth,
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (MapEntry<dynamic, dynamic> item in fromStore.entries)
                              item.value
                          ],
                        ),
                      ),
                      Container(
                        width: SizeConfig.screenWidth,
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (MapEntry<dynamic, dynamic> item in toStore.entries)
                              item.value
                          ],
                        ),
                      ),


                      Obx(() =>
                          ReportDataTable2(
                            topMargin: 20,
                            gridBodyReduceHeight: 300,
                            selectedIndex: -1,
                            gridData: gridData.value,
                            gridDataRowList: columnList,
                            func: (index){
                            },
                          )
                      ),
                      inBtwHei(height: 20)
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  TextStyle textStyle1=ts20M(ColorUtil.text1);
  TextStyle textStyleBold1=ts20M(ColorUtil.themeBlack,fontsize: 34,fontfamily: 'AH');
  Color dividerColor=Colors.grey;

  void getData() async{
    header.clear();

    if(widget.page=="Indent"){
      title="Indent";
      header['IndentOrderNumber']=HE_WrapText2(dataname: "IndentOrderNumber",content: "Indent Order # : ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);
      header['Date']=HE_WrapText2(dataname: "Date",content: "Indent On : ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);
      header['DeliveryType']=HE_WrapText2(dataname: "DeliveryType",content: "Delivery Type : ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);
      header['Status']=HE_WrapText2(dataname: "Status",content: "Status : ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);

      fromStore["Source"]=HE_Text(dataname: "Source", contentTextStyle: textStyleBold1);
      fromStore["FromStoreAddress"]=HE_Text(dataname: "FromStoreAddress", contentTextStyle: textStyle1);
      fromStore["Divider"]=Padding(
        padding: const EdgeInsets.only(top: 5,bottom: 10),
        child: Divider(color: dividerColor,height: 5,),
      );
      fromStore["FromStorePhoneNumber"]=HE_WrapText2(dataname: "FromStorePhoneNumber",content: "Phone : ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);
      fromStore["FromStoreEmail"]=HE_WrapText2(dataname: "FromStoreEmail",content: "Mail : ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);

      toStore["Destination"]=HE_Text(dataname: "Destination", contentTextStyle: textStyleBold1);
      toStore["ToStoreAddress"]=HE_Text(dataname: "ToStoreAddress", contentTextStyle: textStyle1,textAlign: TextAlign.end,);
      toStore["Divider"]=Padding(
        padding: const EdgeInsets.only(top: 5,bottom: 10),
        child: Divider(color: dividerColor,height: 5,),
      );
      toStore["ToStorePhoneNumber"]=HE_WrapText2(dataname: "ToStorePhoneNumber",content: "Phone : ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);
      toStore["ToStoreEmail"]=HE_WrapText2(dataname: "ToStoreEmail",content: "Mail : ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);


    }
    else if(widget.page=="Purchase"){
      title="Purchase";
    }

    setState(() {});
    parseJson([], "",traditionalParam: TraditionalParam(getByIdSp: widget.spName),needToSetValue: false,resCb: (res){
      console(res);
      try{
        setFrmValues(header, res['Table']);
        setFrmValues(fromStore, res['Table']);
        setFrmValues(toStore, res['Table']);
        gridData.value=res['Table1'];
      }catch(e,t){
        assignWidgetErrorToastLocal(e, t);
      }
    },loader: showLoader,dataJson: widget.dataJson,extraParam: MyConstants.extraParam);
  }
}
