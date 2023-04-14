import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_utils/utils/utils.dart';
import 'package:get/get.dart';
import 'package:restainventorymobile/pages/dashboard/Dashboard.dart';
import 'package:restainventorymobile/pages/indentOrder/indentGrid.dart';
import 'package:restainventorymobile/pages/purchaseOrder/purchaseGrid.dart';
import 'package:restainventorymobile/utils/constants.dart';
import 'package:restainventorymobile/widgets/customAppBar.dart';

import '../notifier/configuration.dart';
import '../utils/colorUtil.dart';
import '../utils/sizeLocal.dart';
import '../utils/utils.dart';
import '../widgets/accessWidget.dart';
import '../widgets/circle.dart';
import '../widgets/customNetworkImg.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver{

  GlobalKey <ScaffoldState> scaffoldkey=new GlobalKey<ScaffoldState>();

  Directory? imgPath;


  @override
  void initState(){
    WidgetsBinding.instance.addObserver(this);
    loadCredentials();
    super.initState();
  }


  @override
  void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  var  profileImage="".obs;
  var  storeName="".obs;
  void loadCredentials() async{
    imgPath=await getApplicationPath();
    profileImage.value=await getSharedPrefStringUtil(SP_USERIMG);
    storeName.value=await getSharedPrefStringUtil(SP_STORENAME);

  }

  void closeDrawer(){
    scaffoldkey.currentState!.openEndDrawer();
  }

  void openDrawer(){
    scaffoldkey.currentState!.openDrawer();
  }

  List<dynamic> menuList=[
    {"Title":'Dashboard',"PageNumber":1,"accessId": 100},
    {"Title":'Indent Order',"PageNumber":2,"accessId": 100},
    {"Title":'Purchase Order',"PageNumber":3,"accessId": 100},
  ];

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      bottom: MyConstants.bottomSafeArea,
      child: Scaffold(
        key: scaffoldkey,
        backgroundColor: ColorUtil.bgColor,
        drawer: Container(
          height: SizeConfig.screenHeight,
          width: SizeConfig.screenWidth!*0.7,
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white
          ),
          child:Column(
            children: [
              /*Obx(() => CustomNetworkImg(
                dbFilePath: profileImage.value,
                directoryPath:imgPath==null?"": imgPath!.path,
                width: 100,
                height: 100,
                errorBuilder: Icon(Icons.person_outline_outlined,color: ColorUtil.themeWhite,),
              )),*/
              Row(
                children: [
                  CustomCircle(
                    hei: 70,
                    color: ColorUtil.red,
                    widget: Icon(Icons.person_2_outlined,color: Colors.white,size: 30,),
                  ),
                  const Spacer(),
                  CloseBtnV1(
                    onTap:closeDrawer,
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              for(int i=0;i<menuList.length;i++)
                AccessWidget(
                  hasAccess:/*menuList[i]['accessId']==null?true: isHasAccess(menuList[i]['accessId'])*/true,
                  needToHide: true,
                  widget:   DrawerContent(
                    title: menuList[i]['Title'],
                    Img: '',
                    pageNumber: menuList[i]['PageNumber'],
                  ),
                  onTap: (){
                    menuSel.value=menuList[i]['PageNumber'];
                    closeDrawer();
                  },
                ),

              const Spacer(),
              const Divider(),
              const SizedBox(height: 5,),
              Align(
                alignment: Alignment.centerLeft,
                child: Obx(() => Text("${storeName.value}",style: ts20(ColorUtil.themeBlack,fontfamily: 'AM'),textAlign: TextAlign.start,)),
              ),
              const SizedBox(height: 5,),
              const Divider(),
            ],
          ),
        ),
        body: Obx(() =>
          menuSel.value==1?Dashboard(
            navCallback: openDrawer,
          ):
          menuSel.value==2?IndentGrid(
            navCallback: openDrawer,
          ):
          menuSel.value==3?PurchaseGrid(
            navCallback: openDrawer,
          ):
              Container()
        ),
      ),
    );
  }
}

class DrawerContent extends StatelessWidget {
  String title;
  String Img;
  bool isSvg;
  int pageNumber;
  DrawerContent({required this.title,required this.Img,this.isSvg=false,this.pageNumber=1});
  late double width;

  @override
  Widget build(BuildContext context) {
    width=MediaQuery.of(context).size.width;
    return Container(
      height: 40,
      color: Colors.transparent,
      child: Row(
        children: [
          /*Container(
            height: 70,
            width: SizeConfig.screenWidth!*0.20,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child:isSvg?SvgPicture.asset('$Img',fit: BoxFit.cover,): Image.asset('$Img',fit: BoxFit.cover,),
            ),
          ),
          SizedBox(height: 5,),*/
          Obx(() => Text("$title", style: ts20(pageNumber==menuSel.value?ColorUtil.red:Color(0xffA8A8A8,),fontfamily: 'AR'),)
          ),
        ],
      ),
    );
  }
}