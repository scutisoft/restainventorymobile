import 'package:flutter/material.dart';
import 'package:flutter_utils/utils/extensionUtils.dart';
import 'package:flutter_utils/utils/utils.dart';
import 'package:get/get.dart';
import 'package:restainventorymobile/notifier/configuration.dart';
import 'package:restainventorymobile/pages/homePage.dart';
import 'package:restainventorymobile/widgets/customAppBar.dart';
import '/api/sp.dart';
import '/utils/constants.dart';
import '/utils/colorUtil.dart';
import '/utils/sizeLocal.dart';
import '/utils/utils.dart';

class StoreSelection extends StatefulWidget {
  const StoreSelection({Key? key}) : super(key: key);

  @override
  State<StoreSelection> createState() => _StoreSelectionState();
}

class _StoreSelectionState extends State<StoreSelection> {

  RxList<dynamic> stores=RxList();

  @override
  void initState(){
    getStoreList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageBody(
      body: Container(
        height: SizeConfig.screenHeight,
        width: SizeConfig.screenWidth,
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Text("Select Store",style: ts20(ColorUtil.red,fontfamily: 'AR',fontWeight: FontWeight.w500),),
                  const Spacer(),
                  CloseBtnV1(onTap: (){
                    Get.back();
                  },),
                ],
              ),
            ),
            Flexible(
              child: Obx(() => ListView.builder(
                itemCount: stores.length,
                  itemBuilder: (ctx,i){
                    return GestureDetector(
                      onTap: (){
                        setStore(stores[i]);
                      },
                      child: Container(
                        height: 50,
                        width: SizeConfig.screenWidth,
                        alignment: Alignment.centerLeft,
                        color: Colors.white,
                        margin:  MyConstants.LRPadding,
                        child: Text("${stores[i]['Text']}",style: ts20(ColorUtil.text1,fontfamily: 'AR'),),
                      ),
                    );
                  }
              ),)
            )
          ],
        ),
      ),
    );
  }

  void getStoreList(){
    getMasterDrp("", "StoreId", null, null, null, Sp.masterSp,extraParam: MyConstants.extraParam).then((value){
      console(value);
      stores.value=value;
    });
  }

  void setStore(e){
    setSharedPrefStringUtil(e['Id'], SP_STOREID);
    setSharedPrefStringUtil(e['Text'], SP_STORENAME);
    MyConstants.rupeeString=e['Value'];
    setState(() {});
    Get.close(2);
    fadeRoute(HomePage());
  }
}
