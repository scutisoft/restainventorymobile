import 'package:flutter/material.dart';
import 'package:flutter_utils/mixins/extensionMixin.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import '../widgets/fittedText.dart';
import '../widgets/loader.dart';
import '/utils/utilWidgets.dart';
import '/api/apiUtils.dart';
import '/utils/colorUtil.dart';
import '/utils/constants.dart';
import '/widgets/staticColumnScroll/commonViewGrid.dart';
import '/utils/utils.dart';
import 'package:get/get.dart';
import '/utils/sizeLocal.dart';
import '/widgets/customAppBar.dart';
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
  var billFooter={}.obs;
  var notes="".obs;
  var amtInWords="".obs;
  RxBool loader=RxBool(false);
  List<CommonViewGridStyleModel> columnList=[];
  RxList<dynamic> gridData=RxList();

  bool hasBillFooter=false;
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 150,
                              width: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: ColorUtil.red2
                              ),
                              alignment: Alignment.center,
                              child: Image.asset("assets/icons/invoice-logo.png",width: 90,),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(title,style: ts20M(Color(0xFFA1A1C2),fontsize: 30,fontfamily: 'AH'),),
                                  for (MapEntry<dynamic, dynamic> item in header.entries)
                                    item.value
                                ],
                              ),
                            ),
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
                          CommonViewGrid(
                            topMargin: 20,
                            gridBodyReduceHeight: 260,
                            selectedIndex: -1,
                            gridData: gridData.value,
                            gridDataRowList: columnList,
                            staticColWidth: widget.page=="Transfer"?(SizeConfig.screenWidth!-160): 180,
                            func: (index){
                            },
                          )
                      ),
                      inBtwHei(height: 20),
                      Visibility(
                        visible: hasBillFooter,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: SizeConfig.screenWidth!*0.7,
                            padding: const EdgeInsets.all(15),
                            child: Obx(() => Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                for (MapEntry<dynamic, dynamic> item in billFooter.entries)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 5),
                                    decoration:item.key=="Grand Total"? BoxDecoration(
                                      color: ColorUtil.red2,
                                      borderRadius: BorderRadius.circular(3)
                                    ):null,
                                    alignment: Alignment.center,
                                    padding: item.key=="Grand Total"?const EdgeInsets.fromLTRB(10, 5, 10, 5):null,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text("${item.key} ",style: ts20M(item.key=="Grand Total"?ColorUtil.themeWhite:ColorUtil.themeBlack,fontsize: 20),),
                                        FlexFittedText(
                                          text: "${item.value}",
                                          textStyle: ts20M(item.key=="Grand Total"?ColorUtil.themeWhite:ColorUtil.themeBlack,fontsize: 22),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),)
                          ),
                        ),
                      ),
                      Obx(() => Visibility(
                        visible: notes.isNotEmpty,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10,bottom: 10,left: 15,right: 15),
                          child: Text("NOTE: ${notes}",style: ts20M(ColorUtil.themeBlack),),
                        ),
                      )),
                      Obx(() => Visibility(
                        visible: amtInWords.isNotEmpty,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15,right: 15),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Amount Chargeable (in words)",style: ts20M(ColorUtil.themeBlack,fontsize: 15),),
                              inBtwHei(height: 7),
                              Text("$amtInWords",style: ts20M(ColorUtil.themeBlack),),
                              inBtwHei(height: 20),
                            ],
                          ),
                        ),
                      )),
                    ],
                  ),
                )
              ],
            ),
          ),
          Positioned(top: 80,child: ShimmerLoader(loader: loader)),
        ],
      ),
    );
  }

  TextStyle textStyle1=ts20M(ColorUtil.text1,fontsize: 16);
  TextStyle textStyleBold1=ts20M(ColorUtil.themeBlack,fontsize: 34,fontfamily: 'AH');
  Color dividerColor=Colors.grey;
  CrossAxisAlignment wrapTextCA=CrossAxisAlignment.start;

  void getData() async{
    header.clear();

    if(widget.page=="Indent"){
      title="Indent";
      header['IndentOrderNumber']=HE_WrapText2(dataname: "IndentOrderNumber",content: "Indent Order #: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);
      header['Date']=HE_WrapText2(dataname: "Date",content: "Indent On: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);
      header['DeliveryType']=HE_WrapText2(dataname: "DeliveryType",content: "Delivery Type: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);
      header['Status']=HE_WrapText2(dataname: "Status",content: "Status: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);

      fromStore["Source"]=HE_Text(dataname: "Source", contentTextStyle: textStyleBold1);
      fromStore["FromStoreAddress"]=HE_Text(dataname: "FromStoreAddress", contentTextStyle: textStyle1);
      fromStore["Divider"]=Padding(
        padding: const EdgeInsets.only(top: 5,bottom: 10),
        child: Divider(color: dividerColor,height: 5,),
      );
      fromStore["FromStorePhoneNumber"]=HE_WrapText2(dataname: "FromStorePhoneNumber",content: "Phone: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);
      fromStore["FromStoreEmail"]=HE_WrapText2(dataname: "FromStoreEmail",content: "Mail: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);

      toStore["Destination"]=HE_Text(dataname: "Destination", contentTextStyle: textStyleBold1);
      toStore["ToStoreAddress"]=HE_Text(dataname: "ToStoreAddress", contentTextStyle: textStyle1,textAlign: TextAlign.end,);
      toStore["Divider"]=Padding(
        padding: const EdgeInsets.only(top: 5,bottom: 10),
        child: Divider(color: dividerColor,height: 5,),
      );
      toStore["ToStorePhoneNumber"]=HE_WrapText2(dataname: "ToStorePhoneNumber",content: "Phone: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);
      toStore["ToStoreEmail"]=HE_WrapText2(dataname: "ToStoreEmail",content: "Mail: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);

      columnList=[
        CommonViewGridStyleModel(columnName: "Description of Goods",dataName: "MaterialName",brandDataName: "MaterialBrandName",isMaterial: true),
        CommonViewGridStyleModel(columnName: "Requested Quantity",dataName: "RequestedQuantity"),
        CommonViewGridStyleModel(columnName:"Approved Quantity",dataName: "ApprovedQuantity"),
      ];
    }
    else if(widget.page=="Purchase"){
      title="Purchase";
      header['PurchaseOrder']=HE_WrapText2(dataname: "PurchaseOrder",content: "Purchase Order #: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);
      header['PurchaseOn']=HE_WrapText2(dataname: "PurchaseOn",content: "Purchase On: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);
      header['ExpectedOn']=HE_WrapText2(dataname: "ExpectedOn",content: "Expected On: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);
      header['NoOfItem']=HE_WrapText2(dataname: "NoOfItem",content: "No.of Items: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);

      fromStore["CompanyName"]=HE_Text(dataname: "CompanyName", contentTextStyle: textStyleBold1);
      fromStore["CompanyAddress"]=HE_Text(dataname: "CompanyAddress", contentTextStyle: textStyle1);
      fromStore["Divider"]=Padding(
        padding: const EdgeInsets.only(top: 5,bottom: 10),
        child: Divider(color: dividerColor,height: 5,),
      );
      fromStore["CompanyPhoneNumber"]=HE_WrapText2(dataname: "CompanyPhoneNumber",content: "Phone: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);
      fromStore["CompanyEmail"]=HE_WrapText2(dataname: "CompanyEmail",content: "Mail: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);
      fromStore["CompanyGSTNumber"]=HE_WrapText2(dataname: "CompanyGSTNumber",content: "GST No: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);

      toStore["VendorName"]=HE_Text(dataname: "VendorName", contentTextStyle: textStyleBold1);
      toStore["VendorPermanentAddress"]=HE_Text(dataname: "VendorPermanentAddress", contentTextStyle: textStyle1,textAlign: TextAlign.end,);
      toStore["Divider"]=Padding(
        padding: const EdgeInsets.only(top: 5,bottom: 10),
        child: Divider(color: dividerColor,height: 5,),
      );
      toStore["VendorContactNumber"]=HE_WrapText2(dataname: "VendorContactNumber",content: "Phone: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);
      toStore["VendorEmail"]=HE_WrapText2(dataname: "VendorEmail",content: "Mail: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);
      toStore["VendorGSTNumber"]=HE_WrapText2(dataname: "VendorGSTNumber",content: "GST No: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);

      columnList=[
        CommonViewGridStyleModel(columnName: "Description of Goods",dataName: "MaterialName",brandDataName: "MaterialBrandName",isMaterial: true),
        CommonViewGridStyleModel(columnName: "Price",dataName: "Price",width: 100,needRupeeFormat: true),
        CommonViewGridStyleModel(columnName:"Quantity",dataName: "Quantity",width: 100),
        CommonViewGridStyleModel(columnName:"Amount",dataName: "Subtotal",width: 100,needRupeeFormat: true),
      ];
      hasBillFooter=true;
      billFooter.clear();
    }
    else if(widget.page=="Goods"){
      title="Goods";
      header['PurchaseOrderNumber']=HE_WrapText2(dataname: "PurchaseOrderNumber",content: "Purchase Order: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,crossAxisAlignment: wrapTextCA,);
      header['GoodsReceivedNumber']=HE_WrapText2(dataname: "GoodsReceivedNumber",content: "Goods Order: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,crossAxisAlignment: wrapTextCA,);
      header['PurchaseOn']=HE_WrapText2(dataname: "PurchaseOn",content: "Purchase On: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,crossAxisAlignment: wrapTextCA,);
      header['ExpectedOn']=HE_WrapText2(dataname: "ExpectedOn",content: "Expected On: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,crossAxisAlignment: wrapTextCA,);
      header['DeliveryOn']=HE_WrapText2(dataname: "DeliveryOn",content: "Delivery On: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,crossAxisAlignment: wrapTextCA,);
      header['Status']=HE_WrapText2(dataname: "Status",content: "Status: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,crossAxisAlignment: wrapTextCA,);

      fromStore["StoreName"]=HE_Text(dataname: "StoreName", contentTextStyle: textStyleBold1);
      fromStore["StoreAddress"]=HE_Text(dataname: "StoreAddress", contentTextStyle: textStyle1);
      fromStore["Divider"]=Padding(
        padding: const EdgeInsets.only(top: 5,bottom: 10),
        child: Divider(color: dividerColor,height: 5,),
      );
      fromStore["StoreContactNumber"]=HE_WrapText2(dataname: "StoreContactNumber",content: "Phone: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);
      fromStore["StoreEmail"]=HE_WrapText2(dataname: "StoreEmail",content: "Mail: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);
      fromStore["StoreGSTNumber"]=HE_WrapText2(dataname: "StoreGSTNumber",content: "GST No: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);

      toStore["VendorName"]=HE_Text(dataname: "VendorName", contentTextStyle: textStyleBold1);
      toStore["VendorAddress"]=HE_Text(dataname: "VendorAddress", contentTextStyle: textStyle1,textAlign: TextAlign.end,);
      toStore["Divider"]=Padding(
        padding: const EdgeInsets.only(top: 5,bottom: 10),
        child: Divider(color: dividerColor,height: 5,),
      );
      toStore["VendorContactNumber"]=HE_WrapText2(dataname: "VendorContactNumber",content: "Phone: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);
      toStore["VendorEmail"]=HE_WrapText2(dataname: "VendorEmail",content: "Mail: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);
      toStore["VendorGSTNumber"]=HE_WrapText2(dataname: "VendorGSTNumber",content: "GST No: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);


      columnList=[
        CommonViewGridStyleModel(columnName: "Description of Goods",dataName: "MaterialName",brandDataName: "MaterialBrandName",isMaterial: true),
        CommonViewGridStyleModel(columnName: "Ordered Qty",dataName: "OrderedQty",width: 100,),
        CommonViewGridStyleModel(columnName:"Received Qty",dataName: "TotalReceivedQty",width: 100),
        CommonViewGridStyleModel(columnName:"Price",dataName: "AmountPerQty",width: 120,needRupeeFormat: true),
        CommonViewGridStyleModel(columnName:"Amount",dataName: "TotalReceivedAmt",width: 120,needRupeeFormat: true),
      ];
      hasBillFooter=true;
      billFooter.clear();
    }
    else if(widget.page=="Transfer") {
      title = "Transfer";
      header['TransferOrderNumber']=HE_WrapText2(dataname: "TransferOrderNumber",content: "Transfer Order: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,crossAxisAlignment: wrapTextCA,);
      header['TransferDate']=HE_WrapText2(dataname: "TransferDate",content: "Transfer On: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,crossAxisAlignment: wrapTextCA,);
      header['TransferPerson']=HE_WrapText2(dataname: "TransferPerson",content: "Transfer By: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,crossAxisAlignment: wrapTextCA,);
      header['NoOfItems']=HE_WrapText2(dataname: "NoOfItems",content: "No.of Items: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,crossAxisAlignment: wrapTextCA,);

      fromStore["FromStoreName"]=HE_Text(dataname: "FromStoreName", contentTextStyle: textStyleBold1);
      fromStore["FromStoreAddress"]=HE_Text(dataname: "FromStoreAddress", contentTextStyle: textStyle1);
      fromStore["Divider"]=Padding(
        padding: const EdgeInsets.only(top: 5,bottom: 10),
        child: Divider(color: dividerColor,height: 5,),
      );
      fromStore["FromStorePhoneNumber"]=HE_WrapText2(dataname: "FromStorePhoneNumber",content: "Phone: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);
      fromStore["FromStoreEmail"]=HE_WrapText2(dataname: "FromStoreEmail",content: "Mail: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);

      toStore["ToStoreName"]=HE_Text(dataname: "ToStoreName", contentTextStyle: textStyleBold1);
      toStore["ToStoreAddress"]=HE_Text(dataname: "ToStoreAddress", contentTextStyle: textStyle1,textAlign: TextAlign.end,);
      toStore["Divider"]=Padding(
        padding: const EdgeInsets.only(top: 5,bottom: 10),
        child: Divider(color: dividerColor,height: 5,),
      );
      toStore["ToStorePhoneNumber"]=HE_WrapText2(dataname: "ToStorePhoneNumber",content: "Phone: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);
      toStore["ToStoreEmail"]=HE_WrapText2(dataname: "ToStoreEmail",content: "Mail: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);


      columnList=[
        CommonViewGridStyleModel(columnName: "Description of Goods",dataName: "MaterialName",brandDataName: "MaterialBrandName",isMaterial: true),
        CommonViewGridStyleModel(columnName: "Quantity",dataName: "TotalQuantity")
      ];
    }
    else if(widget.page=="DepartmentDistribution"){
      title="Department\nDistribution";
      header['BatchNumber']=HE_WrapText2(dataname: "BatchNumber",content: "Batch Number: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);
      header['DistributionDate']=HE_WrapText2(dataname: "DistributionDate",content: "Date: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);

      fromStore["StoreName"]=HE_Text(dataname: "StoreName", contentTextStyle: textStyleBold1);
      fromStore["StoreAddress"]=HE_Text(dataname: "StoreAddress", contentTextStyle: textStyle1);
      fromStore["Divider"]=Padding(
        padding: const EdgeInsets.only(top: 5,bottom: 10),
        child: Divider(color: dividerColor,height: 5,),
      );
      fromStore["StoreContactNumber"]=HE_WrapText2(dataname: "StoreContactNumber",content: "Phone: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);
      fromStore["StoreEmail"]=HE_WrapText2(dataname: "StoreEmail",content: "Mail: ", contentTextStyle: textStyle1, contentTextStyle2:textStyle1,);

      columnList=[
        CommonViewGridStyleModel(columnName: "Department Name",dataName: "DepartmentName",width: 180),
        CommonViewGridStyleModel(columnName: "Description of Goods",dataName: "MaterialName",brandDataName: "MaterialBrandName",isMaterial: true),
        CommonViewGridStyleModel(columnName:"Quantity",dataName: "Quantity"),
        CommonViewGridStyleModel(columnName:"Return Quantity",dataName: "ReturnQuantity"),
      ];
    }



    setState(() {});
    parseJson([], "",traditionalParam: TraditionalParam(getByIdSp: widget.spName),needToSetValue: false,resCb: (res){
      //console(res);
      try{
        setFrmValues(header, res['Table']);
        setFrmValues(fromStore, res['Table']);
        setFrmValues(toStore, res['Table']);
        if(widget.page=="Goods"){
          gridData.value=res['Table2'];
          billFooter['SubTotal']=getRupeeString(res['Table'][0]['SubTotal']);
          billFooter['Tax']=getRupeeString(res['Table'][0]['GST']);
          billFooter['Other Cost']=getRupeeString(res['Table'][0]['OtherCharges']);
          billFooter['Grand Total']=getRupeeString(res['Table'][0]['GrandTotal']);
          amtInWords.value=res['Table'][0]['AmountInWords'];
        }
        else{
          gridData.value=res['Table1'];
        }

        if(widget.page=="Purchase"){
          billFooter['SubTotal']=getRupeeString(res['Table'][0]['Subtotal']);
          billFooter['Tax']=getRupeeString(res['Table'][0]['TaxAmount']);
          billFooter['Grand Total']=getRupeeString(res['Table'][0]['GrandTotalAmount']);
          notes.value=res['Table'][0]['Notes'];
          amtInWords.value=res['Table'][0]['AmountInWords'];
        }
      }catch(e,t){
        assignWidgetErrorToastLocal(e, t);
      }
    },loader: loader,dataJson: widget.dataJson,extraParam: MyConstants.extraParam);
  }
}
