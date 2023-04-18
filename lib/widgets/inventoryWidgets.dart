
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:flutter_utils/utils/extensionUtils.dart';
import 'package:get/get.dart';

import '../utils/colorUtil.dart';
import '../utils/constants.dart';
import '../utils/sizeLocal.dart';
import 'alertDialog.dart';
import 'circle.dart';
import 'customAppBar.dart';

class UnitDropDown extends StatelessWidget implements ExtensionCallback{

  Function? onChange;
  UnitDropDown({Key? key,this.onChange}) : super(key: key);

  var unitList=[].obs;
  Rxn<dynamic> selectedUnit=Rxn<dynamic>();

  @override
  Widget build(BuildContext context) {
    return Obx(()=>Container(
      width: 100,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(top: 10,bottom: 10,right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color:  ColorUtil.red,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left:10.0,right: 10),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<dynamic>(
              value: selectedUnit.value,
              hint: Text("Unit",style: ts20M(Colors.white),),
              style: ts20M(Colors.white),
              icon: const Icon(
                Icons.keyboard_arrow_down_outlined,
                color: Colors.white,
              ),
              dropdownColor: ColorUtil.red,
              items: unitList.value.map((value) {
                return DropdownMenuItem<dynamic>(
                  value: value,
                  child: Text(
                    "${value['Text']}",
                    style: ts20M(ColorUtil.themeWhite),
                  ),
                );
              }).toList(),
              onChanged: (v) {
                print(v);
                selectedUnit.value=v;
                if(onChange!=null){
                  onChange!(v);
                }
              }
          ),
        ),
      ),
    ));
  }

  @override
  void clearValues() {
    selectedUnit.value=null;
    unitList.clear();
  }

  @override
  String getDataName() {
    // TODO: implement getDataName
    throw UnimplementedError();
  }

  @override
  int getOrderBy() {
    // TODO: implement getOrderBy
    throw UnimplementedError();
  }

  @override
  String getType() {
    // TODO: implement getType
    throw UnimplementedError();
  }

  @override
  getValue() {
    return selectedUnit.value;
  }

  @override
  setOrderBy(int oBy) {
    // TODO: implement setOrderBy
    throw UnimplementedError();
  }

  @override
  setValue(value) {
    if(HE_IsMap(value)){
      selectedUnit.value=value;
    }
    else if(HE_IsList(value)){
      unitList.value=value;
    }

  }

  @override
  bool validate() {
    // TODO: implement validate
    throw UnimplementedError();
  }

  getValueMap(){
    return selectedUnit.value;
  }
}

getUnitIdNameList(String id,String name){
  List finalArr=[];
  List idList=id.split(",");
  List nameList=name.split(",");
  if(idList.length==nameList.length){
    for (int i = 0; i < idList.length; i++) {
      finalArr.add({ "Id": idList[i], "Text": nameList[i] });
    }
  }
  else{
    CustomAlert().cupertinoAlert("Unit Name Mismatch...");
  }
  return finalArr;
}

class GridTitleCard extends StatelessWidget {
  double width;
  dynamic content;
  Alignment alignment;
  GridTitleCard({Key? key,required this.width,required this.content,this.alignment=Alignment.centerLeft}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      alignment: alignment,
      child: Text("$content",style: ts20M(ColorUtil.themeBlack,fontsize: 16),textAlign: TextAlign.center,),
    );
  }
}

class SwipeNotes extends StatelessWidget {
  const SwipeNotes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(bottom: 5),
      child: Text("* Swipe Left to Edit, Delete...",style: ts20(Colors.blue,fontsize: 14),),
    );
  }
}

Widget cartIcon({VoidCallback? onTap,int count=0}){
  return GestureDetector(
    onTap:onTap,
    child: Stack(
      children: [
        CustomCircle(
          hei: 50,
          color: ColorUtil.themeWhite,
          widget: SvgPicture.asset("assets/icons/cart.svg"),
        ),
        Positioned(
          right: 8,
          top: 0,
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(50),
                color: Color(0xFF444C66),
                shape: BoxShape.circle
            ),
            child: Text("$count",style: ts20(ColorUtil.themeWhite,fontsize: 12),),
          ),
        )
      ],
    ),
  );
}

class StatusTxt extends StatelessWidget {
  String status;
  StatusTxt({Key? key,required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: status.toString().length*10,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: ColorUtil.bgColor
      ),
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      alignment: Alignment.center,
      child: Text(status,style: ts20(ColorUtil.red,fontsize: 15),maxLines: 1,overflow: TextOverflow.ellipsis,),
    );
  }
}


class SlidePopUp extends StatelessWidget {
  RxBool isOpen;
  Widget? appBar;
  List<Widget> widgets;
  SlidePopUp({Key? key,required this.isOpen,this.appBar,this.widgets=const []}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => AnimatedContainer(
      duration: MyConstants.animeDuration,
      curve: MyConstants.animeCurve,
      width: SizeConfig.screenWidth,
      height: SizeConfig.screenHeight,
      transform:  Matrix4.translationValues(isOpen.value? 0:SizeConfig.screenWidth!, 0, 0),
      padding: ColorUtil.formMargin,
      decoration: const BoxDecoration(
          color: ColorUtil.bgColor
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTapIcon(
                    alignment:Alignment.centerLeft,
                    widget: Icon(Icons.arrow_back_rounded,color: ColorUtil.themeBlack,),
                    onTap: (){
                      isOpen.value=false;
                    },
                  ),
                  Text("Back",style: ts20M(ColorUtil.themeBlack,fontsize: 18),),
                ],
              ),
              appBar??Container(),
            ],
          ),
          for(int i=0;i<widgets.length;i++)
            widgets[i]
        ],
      ),
    ));
  }
}
