
import 'package:flutter/material.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:flutter_utils/utils/extensionUtils.dart';
import 'package:get/get.dart';

import '../utils/colorUtil.dart';
import '../utils/constants.dart';
import 'alertDialog.dart';

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
      child: Text("* Swipe Left to Edit, Delete...",style: ts20(ColorUtil.red,fontsize: 14),),
    );
  }
}
