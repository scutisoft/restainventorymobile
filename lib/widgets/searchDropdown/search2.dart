import 'package:flutter/material.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:flutter_utils/utils/extensionUtils.dart';

import 'package:get/get.dart';
import 'package:restainventorymobile/utils/utils.dart';
import 'package:restainventorymobile/widgets/customAppBar.dart';
import '../validationErrorText.dart';
import '/utils/colorUtil.dart';
import '/utils/constants.dart';
import '../../helper/language.dart';
import '../../utils/sizeLocal.dart';
import 'dropdown_search.dart';


Color addNewTextFieldText=Color(0xFF646464);

class Search2 extends StatelessWidget {
  VoidCallback? scrollTap;
  double? width;
  double? dialogWidth;
  //String selectedValue;
  List<dynamic>? data;
  Function(int)? onitemTap;
  Function(dynamic)? selectedValueFunc;
  bool? isToJson;
  String propertyName;
  String propertyId;
  String? hinttext;
  String labelText;
  bool isEnable;
  BoxDecoration? selectWidgetBoxDecoration;
  EdgeInsets? margin;
  EdgeInsets? dialogMargin;
  bool showSearch;
  var selectedValue;
  double selectWidgetHeight;
  String dataName;
  bool hasInput;
  bool required;

  Mode mode;
  double maxHeight;

  Search2({ this.width,this.selectedValueFunc,
    this.data, this.onitemTap, this.isToJson,this.propertyName="Text",this.propertyId="Id", this.hinttext,
    this.isEnable=true, this.scrollTap,this.margin,this.dialogMargin,this.selectWidgetHeight=70.0,
    this.selectWidgetBoxDecoration,this.showSearch=true,this.selectedValue=const {},this.dialogWidth,
    required this.dataName,this.hasInput=true,this.required=false,this.mode=Mode.MENU,this.maxHeight=400.0,
    this.labelText="Select"
  }){
    if(this.selectedValue.isNotEmpty){
      selectedData.value=selectedValue;
    }
    if(this.data!=null ){
      if(this.data!.isNotEmpty){
        dataNotifier.value=data!;
      }
    }
  }

  FocusNode f4 = FocusNode();
  // final ValueNotifier<List<dynamic>> dataNotifier = ValueNotifier([]);
  var dataNotifier=[].obs;
  var selectedData={}.obs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: DropdownSearch<String>(

        popupBackgroundColor: Colors.white,
        dropdownSearchDecoration: InputDecoration(),
        mode: mode,
        showSelectedItems: false,
        popupElevation: 2,
        showClearButton: false,
        showSearchBox: false,
        dropDownButton: const Icon(Icons.eleven_mp),
        searchDelay: const Duration(milliseconds: 0),

        ontap: (){
          scrollTap!();
          dataNotifier.value=data!;
        },
        selectWidget: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn,
          height: selectWidgetHeight,
          width: width,
          margin:margin ?? EdgeInsets.only(left:SizeConfig.width100!,right:SizeConfig.width100!,top:0),
          decoration:selectWidgetBoxDecoration?? BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color:ColorUtil.text4),
            color: Colors.white,
          ),
          alignment: Alignment.centerLeft,
          padding: MyConstants.LRPadding,
          child: Row(
            children: [
              Obx(() => Text(selectedData.isEmpty?hinttext:isToJson!?selectedData[propertyName]??hinttext:selectedData['value'],
                style: ts20(selectedData.isEmpty?ColorUtil.text2:ColorUtil.themeBlack,fontfamily: selectedData.isEmpty?'ALO':'AM'),),),
              const Spacer(),
              Icon(Icons.keyboard_arrow_down_rounded,color: ColorUtil.red,),
            ],
          ),
        ),
        dialogWidget: Obx(
                ()=>Container(
              height:dataNotifier.isEmpty?150:  (data!.length*45.0)+(showSearch?80:0),
              width: dialogWidth??SizeConfig.screenWidth,
              margin:dialogMargin==null? EdgeInsets.only(left:SizeConfig.width100!,right:SizeConfig.width100!,top:5):dialogMargin,
              //padding: EdgeInsets.only(top: 10),
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.topCenter,

              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: Offset(0,0)
                    )
                  ]
              ),
              constraints: BoxConstraints(
                  maxHeight: maxHeight
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  !showSearch?Container():Container(
                    height: 50,
                    width: width,
                    margin: const EdgeInsets.all(15),
                    alignment: Alignment.centerLeft,
                    child: TextFormField(
                      //    style: textFormTs1,
                      focusNode: f4,
                      //scrollPadding: EdgeInsets.only(bottom: 200),
                      decoration: const InputDecoration(
                          hintText: "Search",
                          // hintStyle: textFormHintTs1,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 0.0)
                      ),
                      onEditingComplete: (){
                        f4.unfocus();
                      },
                      onChanged: (v){
                        dataNotifier.value=data!.where((element) => element.toString().toLowerCase().contains(v.toLowerCase())).toList();
                      },
                    ),
                  ),
                  dataNotifier.isEmpty?Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: const Text("No Data Found",),
                  ):
                  Flexible(child: ListView.builder(
                    itemCount: dataNotifier.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemBuilder: (ctx,index){
                      return   GestureDetector(
                        onTap:(){
                          Navigator.pop(ctx);
                          if(isToJson!)
                            selectedData.value=dataNotifier[index];
                          else
                            selectedData.value={"value":dataNotifier[index]};
                          onitemTap!(index);
                          selectedValueFunc!(dataNotifier[index]);
                        },
                        child: Container(
                          height: 45,
                          width:width,
                          padding: const EdgeInsets.only(left: 20,),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color:(isToJson!?"${dataNotifier[index][propertyId].toString()}":"${dataNotifier[index].toString()}" )== (isToJson!?selectedData[propertyId].toString():selectedData['value'])?ColorUtil.search2ActBg:ColorUtil.search2InActBg,
                          ),
                          child:  Text(isToJson!?"${dataNotifier[index][propertyName]}":"${dataNotifier[index]}",
                            style: (isToJson!?"${dataNotifier[index][propertyId].toString()}":"${dataNotifier[index].toString()}" )== (isToJson!?selectedData[propertyId].toString():selectedData['value'].toString())?
                            ColorUtil.search2ActiveTS:ColorUtil.search2InActiveTS,
                          ),
                        ),
                      );
                    },
                  ))
                ],
              ),
            )
        ),
        onChanged: (s){},
        clearButtonSplashRadius: 20,
        selectedItem:"",
        onBeforeChange: (a, b) {
          return Future.value(true);
        },
      ),
    );
  }
  getValue(){
    return isToJson!?selectedData[propertyId]:selectedData['value'];
  }
  getValueMap(){
    return selectedData;
  }
  setValues(Map value){
    selectedData.value=value;
    selectedValueFunc!(value);
    reload();
  }
  setDataArray(List dataList){
    data=dataList;
    dataNotifier.value=dataList;
    reload();
  }
  clearValues(){
    selectedData.value={};
  }
  void reload(){
    //return;
    if(selectedData.isNotEmpty && dataNotifier.isNotEmpty){
      try{
        var tempVal=dataNotifier.firstWhere((element) => element[propertyId].toString()==selectedData[propertyId].toString());
        selectedData.value=tempVal;
      }catch(e){}
      //_typeAheadController.text=tempVal['Text'];
    }
  }

  String getDataName(){
    return this.dataName;
  }
  getType(){
    return 'searchDrp';
  }
  validate(){
    return getValue()!=null && getValue()!='';
  }
}

class Search2V3 extends StatelessWidget {
  VoidCallback? scrollTap;
  double? width;
  double? dialogWidth;
  //String selectedValue;
  List<dynamic>? data;
  Function(int)? onitemTap;
  Function(dynamic)? selectedValueFunc;
  bool? isToJson;
  String propertyName;
  String propertyId;
  String? hinttext;
  String labelText;
  bool isEnable;
  BoxDecoration? selectWidgetBoxDecoration;
  EdgeInsets? margin;
  EdgeInsets? dialogMargin;
  bool showSearch;
  var selectedValue;
  double selectWidgetHeight;
  String dataName;
  bool hasInput;
  bool required;

  Mode mode;
  double maxHeight;

  Search2V3({ this.width,this.selectedValueFunc,
    this.data, this.onitemTap, this.isToJson,this.propertyName="Text",this.propertyId="Id", this.hinttext,
    this.isEnable=true, this.scrollTap,this.margin,this.dialogMargin,this.selectWidgetHeight=70.0,
    this.selectWidgetBoxDecoration,this.showSearch=true,this.selectedValue=const {},this.dialogWidth,
    required this.dataName,this.hasInput=true,this.required=false,this.mode=Mode.DIALOG,this.maxHeight=400.0,
    this.labelText="Select"
  }){
    if(this.selectedValue.isNotEmpty){
      selectedData.value=selectedValue;
    }
    if(this.data!=null ){
      if(this.data!.isNotEmpty){
        dataNotifier.value=data!;
      }
    }
  }

  FocusNode f4 = FocusNode();
  // final ValueNotifier<List<dynamic>> dataNotifier = ValueNotifier([]);
  var dataNotifier=[].obs;
  var selectedData={}.obs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: DropdownSearch<String>(

        popupBackgroundColor: Colors.white,
        dropdownSearchDecoration: InputDecoration(),
        mode: mode,
        showSelectedItems: false,
        popupElevation: 2,
        showClearButton: false,
        showSearchBox: false,
        dropDownButton: const Icon(Icons.eleven_mp),
        searchDelay: const Duration(milliseconds: 0),

        ontap: (){
          scrollTap!();
          dataNotifier.value=data!;
        },
        selectWidget: Container(
          height: 120,
          width: 100,
          decoration:BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color:ColorUtil.primary,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset('assets/Slice/hand-leaf.png',fit:BoxFit.contain,width: 50,),
              Text(hinttext??"Select",style: TextStyle(fontSize: 13,color: ColorUtil.themeWhite,fontFamily: 'RB'),textAlign: TextAlign.center,),
              Obx(
                    ()=>Flexible(
                  child: Text("${selectedData.isEmpty? "": isToJson!?selectedData[propertyName]??hinttext:selectedData['value']}",
                    style: TextStyle(color: ColorUtil.themeWhite,fontSize: 10,fontFamily: 'Bold'),
                    overflow: TextOverflow.ellipsis,textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        dialogWidget: Obx(
                ()=>Container(
              height:dataNotifier.isEmpty?150:  (data!.length*45.0)+(showSearch?80:0),
              width: dialogWidth??SizeConfig.screenWidth,
              margin:dialogMargin==null? EdgeInsets.only(left:SizeConfig.width100!,right:SizeConfig.width100!,top:5):dialogMargin,
              //padding: EdgeInsets.only(top: 10),
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.topCenter,

              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: Offset(0,0)
                    )
                  ]
              ),
              constraints: BoxConstraints(
                  maxHeight: maxHeight
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  !showSearch?Container():Container(
                    height: 50,
                    width: dialogWidth,
                    margin: const EdgeInsets.all(15),
                    alignment: Alignment.centerLeft,
                    child: TextFormField(
                      //    style: textFormTs1,
                      focusNode: f4,
                      //scrollPadding: EdgeInsets.only(bottom: 200),
                      decoration: const InputDecoration(
                          hintText: "Search",
                          // hintStyle: textFormHintTs1,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 0.0)
                      ),
                      onEditingComplete: (){
                        f4.unfocus();
                      },
                      onChanged: (v){
                        dataNotifier.value=data!.where((element) => element.toString().toLowerCase().contains(v.toLowerCase())).toList();
                      },
                    ),
                  ),
                  dataNotifier.isEmpty?Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: const Text("No Data Found",),
                  ):
                  Flexible(child: ListView.builder(
                    itemCount: dataNotifier.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemBuilder: (ctx,index){
                      return   GestureDetector(
                        onTap:(){
                          Navigator.pop(ctx);
                          if(isToJson!)
                            selectedData.value=dataNotifier[index];
                          else
                            selectedData.value={"value":dataNotifier[index]};
                          onitemTap!(index);
                          selectedValueFunc!(dataNotifier[index]);
                        },
                        child: Container(
                          height: 45,
                          width:width,
                          padding: const EdgeInsets.only(left: 20,),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color:(isToJson!?"${dataNotifier[index][propertyId].toString()}":"${dataNotifier[index].toString()}" )== (isToJson!?selectedData[propertyId].toString():selectedData['value'])?ColorUtil.search2ActBg:ColorUtil.search2InActBg,
                          ),
                          child:  Text(isToJson!?"${dataNotifier[index][propertyName]}":"${dataNotifier[index]}",
                            style: (isToJson!?"${dataNotifier[index][propertyId].toString()}":"${dataNotifier[index].toString()}" )== (isToJson!?selectedData[propertyId].toString():selectedData['value'].toString())?
                            ColorUtil.search2ActiveTS:ColorUtil.search2InActiveTS,
                          ),
                        ),
                      );
                    },
                  ))
                ],
              ),
            )
        ),
        onChanged: (s){},
        clearButtonSplashRadius: 20,
        selectedItem:"",
        onBeforeChange: (a, b) {
          return Future.value(true);
        },
      ),
    );
  }
  getValue(){
    return isToJson!?selectedData[propertyId]:selectedData['value'];
  }
  getValueMap(){
    return selectedData;
  }
  setValues(Map value){
    selectedData.value=value;
    selectedValueFunc!(value);
    reload();
  }
  setDataArray(List dataList){
    data=dataList;
    dataNotifier.value=dataList;
    reload();
  }
  clearValues(){
    selectedData.value={};
  }
  void reload(){
    //return;
    if(selectedData.isNotEmpty && dataNotifier.isNotEmpty){
      try{
        var tempVal=dataNotifier.firstWhere((element) => element[propertyId].toString()==selectedData[propertyId].toString());
        selectedData.value=tempVal;
      }catch(e){}
      //_typeAheadController.text=tempVal['Text'];
    }
  }

  String getDataName(){
    return this.dataName;
  }
  getType(){
    return 'searchDrp';
  }
  validate(){
    return getValue()!=null && getValue()!='';
  }
}

class Search2MultiSelect extends StatelessWidget {
  String dataName;
  VoidCallback? scrollTap;
  double? width;
  //String selectedValue;
  List<dynamic>? data;
  Function(int)? onitemTap;
  Function(dynamic)? selectedValueFunc;
  bool? isToJson;
  String propertyName;
  String propertyId;
  String? hinttext;
  bool isEnable;
  BoxDecoration? selectWidgetBoxDecoration;
  EdgeInsets? margin;
  EdgeInsets? dialogMargin;
  bool showSearch;
  Function(String) doneCallback;
  bool hasInput;
  bool required;

  Mode mode;
  double maxHeight;

  Search2MultiSelect({ this.width,this.selectedValueFunc,
    this.data, this.onitemTap, this.isToJson,this.propertyName="Text",this.propertyId="Id", this.hinttext,
    this.isEnable=true, this.scrollTap,this.margin,required this.dataName,this.hasInput=true,this.required=false,
    this.dialogMargin, this.selectWidgetBoxDecoration,this.showSearch=true,required this.doneCallback,this.mode=Mode.MENU,this.maxHeight=400.0,});

  FocusNode f4 = FocusNode();
  // final ValueNotifier<List<dynamic>> dataNotifier = ValueNotifier([]);
  var dataNotifier=[].obs;
  var selectedData=[].obs;
  var selectedText=[].obs;
  var checked=false.obs;

  double hei1=50.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: DropdownSearch<String>(

        popupBackgroundColor: Colors.white,
        dropdownSearchDecoration: InputDecoration(),
        mode: Mode.MENU,
        showSelectedItems: false,
        popupElevation: 2,
        showClearButton: false,
        showSearchBox: false,
        dropDownButton: Icon(Icons.eleven_mp),
        searchDelay: Duration(milliseconds: 0),
        ontap: (){
          scrollTap!();
          dataNotifier.value=data!;
          checked.value=!checked.value;
        },
        selectWidget: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeIn,
          height: hei1,
          width: width,
          margin:margin==null? addNewPageMargin:margin,
          decoration:selectWidgetBoxDecoration?? BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color:Color(0xFFCDCDCD)),
            color: Colors.white,
          ),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 15),
          child: Row(
            children: [
              Obx(
                    ()=>Expanded(
                  child: Text(selectedText.isEmpty? hinttext!: isToJson!?selectedText.join(','):selectedText.join(','),
                    style: TextStyle(color:selectedData.isEmpty? addNewTextFieldText.withOpacity(0.8):addNewTextFieldText,fontSize: 15,fontFamily: 'RR',overflow: TextOverflow.ellipsis),
                  ),
                ),
              ),
              Icon(Icons.keyboard_arrow_down,size: 30,color: Colors.grey,),
              SizedBox(width: 15,)
            ],
          ),
        ),
        dialogWidget: Obx(
              ()=>Container(
            height: (dataNotifier.length*hei1)+150.0,
            width: width,
            margin:dialogMargin ?? EdgeInsets.only(left:SizeConfig.width100!,right:SizeConfig.width100!,top:5),
            //padding: EdgeInsets.only(top: 10),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: Offset(0,0)
                  )
                ]
            ),
            constraints: BoxConstraints(
                maxHeight: maxHeight
            ),
            child: Column(
              children: [
                !showSearch?Container():Container(
                  height: hei1,
                  width: width,
                  margin: EdgeInsets.all(15),
                  alignment: Alignment.centerLeft,
                  child: TextFormField(
                    //    style: textFormTs1,
                    focusNode: f4,
                    decoration: InputDecoration(
                        hintText: "Search",
                        // hintStyle: textFormHintTs1,
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 15.0,)
                    ),
                    onEditingComplete: (){
                      f4.unfocus();
                    },
                    onChanged: (v){
                      dataNotifier.value=data!.where((element) => element.toString().toLowerCase().contains(v.toLowerCase())).toList();
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    //SizedBox(width: 15,),
                    GestureDetector(
                      onTap: (){
                        clearValues();
                      },
                      child: Container(
                        height: 50,
                        //width: 100,
                        padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                        alignment: Alignment.centerLeft,
                        child: Text("Clear All",style: TextStyle(fontSize: 15,fontFamily: 'RR'),),
                      ),
                    ),
                    //SizedBox(width: 15,),
                    GestureDetector(
                      onTap: (){
                        setValues(
                            data!.map((e) => e[propertyId]).toList().join(","),
                            data!.map((e) => e[propertyName]).toList().join(",")
                        );
                      },
                      child: Container(
                        height: 50,
                        //width: 100,
                        padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                        alignment: Alignment.centerLeft,
                        child: Text("Select All",style: TextStyle(fontSize: 15,fontFamily: 'RR'),),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.pop(context);
                        doneCallback(getValue());
                      },
                      child: Container(
                        height: 50,
                        //width: 100,
                        padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                        alignment: Alignment.centerLeft,
                        color: Colors.transparent,
                        child: Text("Done",style: TextStyle(fontSize: 15,fontFamily: 'RR'),),
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: Obx(
                          ()=>dataNotifier.isEmpty?Container(
                        height: 50,
                        alignment: Alignment.center,
                        child: Text("No Data Found",),
                      ):
                      ListView.builder(
                        itemCount: checked.value?dataNotifier.length:dataNotifier.length,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemBuilder: (ctx,index){
                          return   InkWell(
                            onTap:(){
                              // Navigator.pop(ctx);
                              /* onitemTap(index);
                              selectedValueFunc(dataNotifier[index]);*/
                              checked.value=!checked.value;
                              if(selectedData.contains(dataNotifier[index][propertyId].toString())){
                                dataNotifier[index]['checked']=false;
                                selectedData.remove(dataNotifier[index][propertyId].toString());
                                selectedText.remove(dataNotifier[index][propertyName]);
                              }
                              else{
                                dataNotifier[index]['checked']=true;
                                selectedData.add(dataNotifier[index][propertyId].toString());
                                selectedText.add(dataNotifier[index][propertyName]);
                              }

                            },
                            child: Container(
                              height: 50,
                              width:width,
                              padding: EdgeInsets.only(left: 15,),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                //color:(isToJson?"${t[index][propertyName]}":"${t[index]}" )== (isToJson?selectedData[propertyName]:selectedData['value'])?AppTheme.restroTheme:Colors.white,
                              ),
                              child:  Row(
                                children: [
                                  Obx(
                                        ()=>AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeIn,
                                      height:checked.value? 25:25,
                                      width: 25,
                                      margin: EdgeInsets.only(left: 0,right: 15),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color:dataNotifier[index]['checked']? ColorUtil.primary:Colors.white,
                                          border: Border.all(color:dataNotifier[index]['checked']? Colors.transparent: Colors.grey,)
                                      ),
                                      child: Icon(Icons.done, color:dataNotifier[index]['checked']? Colors.white:Colors.grey, size: 15,),
                                    ),
                                  ),
                                  Text(isToJson!?"${dataNotifier[index][propertyName]}":"${dataNotifier[index]}",
                                    style: TextStyle(fontFamily: 'RR',fontSize: 15, color: Colors.grey,
                                      // color:(isToJson?"${t[index][propertyName]}":"${t[index]}" )== (isToJson?selectedData[propertyName]:selectedData['value'])?Colors.white: Colors.grey
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                  ),
                ),
              ],
            ),
          ),
        ),
        onChanged: (s){},
        clearButtonSplashRadius: 20,
        selectedItem:"",
        onBeforeChange: (a, b) {
          return Future.value(true);
        },
      ),
    );
  }
  getValue(){
    return selectedData.join(",");
  }
  setValues(String value, String nameList){
    selectedData.value=value.split(",");
    selectedText.value=nameList.split(",");
    data!.forEach((element) {if(selectedData.contains(element[propertyId].toString())){element['checked']=true;}});
    dataNotifier.forEach((element) {if(selectedData.contains(element[propertyId].toString())){element['checked']=true;}});
    checked.value=!checked.value;
  }
  setDataArray(List dataList){
    dataList.forEach((element) {element['checked']=false;});
    data=dataList;
    dataNotifier.value=dataList;
    checked.value=!checked.value;
  }
  clearValues(){
    selectedData.clear();
    selectedText.clear();
    data!.forEach((element) {element['checked']=false;});
    checked.value=!checked.value;
  }
  String getDataName(){
    return this.dataName;
  }
  getType(){
    return 'searchDrp';
  }
  validate(){
    return getValue()!=null && getValue()!='';
  }
}

checkNullEmpty(dynamic value){
  return value==null || value=='';
}
EdgeInsets addNewPageMargin=EdgeInsets.only(left:20,right:20,top:20);



class SlideSearch extends StatelessWidget implements ExtensionCallback{
  String dataName;
  bool isToJson;
  String propertyName;
  String propertyId;
  String hinttext;
  Function(dynamic) selectedValueFunc;
  List<dynamic> data;
  bool hasInput;
  bool required;
  bool isEnable;
  SlideSearch({Key? key,required this.dataName,this.isToJson=true,this.propertyName="Text",this.propertyId="Id",
    required this.selectedValueFunc,required this.hinttext,required this.data,this.hasInput=true,this.required=true,
    this.isEnable=true
  }) : super(key: key){
    isEnabled.value=isEnable;
  }

  var isValid=true.obs;
  var isEnabled=true.obs;
  var orderBy=1.obs;
  var errorText="* ${Language.required}".obs;

  var dataNotifier=[].obs;
  var selectedData={}.obs;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() => GestureDetector(
          onTap:isEnabled.value? (){
            Navigator.push(context, _createRouteBillHistory());
          }:null,
          child:Container(
            margin: ColorUtil.formMargin,
            padding: ColorUtil.formMargin,
            height: ColorUtil.formContainerHeight,
            width: SizeConfig.screenWidth,
            decoration: isEnabled.value? ColorUtil.formContBoxDec:ColorUtil.formContDisableBoxDec,
            child: Row(
              children: [
                Obx(() => Text(selectedData.isEmpty?hinttext:isToJson?selectedData[propertyName]??hinttext:selectedData['value'],
                  style: ts20(selectedData.isEmpty?ColorUtil.text2:ColorUtil.themeBlack,fontfamily: selectedData.isEmpty?'ALO':'AM'),),),
                const Spacer(),
                Icon(Icons.keyboard_arrow_right_rounded,color: ColorUtil.red,),
              ],
            ),
          ),
        )),
        Obx(() => Visibility(visible:!isValid.value,child: ValidationErrorText()))
      ],
    );
  }

  @override
  void clearValues() {
    selectedData.value={};
  }

  @override
  String getDataName() {
    return dataName;
  }

  @override
  int getOrderBy() {
    return orderBy.value;
  }

  @override
  String getType() {
    return 'searchDrp2';
  }

  @override
  getValue() {
    return isToJson?selectedData[propertyId]:selectedData['value'];
  }

  @override
  setOrderBy(int oBy) {
    orderBy.value=oBy;
  }

  @override
  setValue(value) {
    // console("a ${value}");
    if(HE_IsMap(value)){
      if(value.containsKey("DropDownOptionList")){
        setDataArray(value['DropDownOptionList']);
      }
      if(value.containsKey("SelectedId") && value['SelectedId']!="" && value['SelectedId']!=null){
        setValues({propertyId:value['SelectedId']});
      }
    }
    else if(HE_IsList(value)){
      setDataArray(value);
    }
    else if(HE_IsInt(value)){
      setValues({propertyId:value});
    }
  }

  @override
  bool validate() {
    isValid.value=getValue()!=null && getValue()!='';
    return isValid.value;
  }


  setValues(Map value){
    selectedData.value=value;
    selectedValueFunc(value);
    reload();
  }
  setDataArray(List dataList){
    data=dataList;
    dataNotifier.value=dataList;
    reload();
  }

  getValueMap(){
    return selectedData.value;
  }

  void reload(){
    if(selectedData.isNotEmpty && dataNotifier.isNotEmpty){
      try{
        var tempVal=dataNotifier.firstWhere((element) => element[propertyId].toString()==selectedData[propertyId].toString());
        selectedData.value=tempVal;
      }catch(e){}
    }
  }

  void checkAndClearSearch(){
    if(dataNotifier.length!=data.length){
      dataNotifier.value=data;
    }
  }

  Route _createRouteBillHistory() {
    double dialogWidth=( SizeConfig.screenWidth!*0.7);
    return PageRouteBuilder(
      opaque: false,
      pageBuilder: (context, animation, secondaryAnimation) =>  SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            height: SizeConfig.screenHeight,
            width: SizeConfig.screenWidth,
            color: Colors.black26,
            alignment: Alignment.centerRight,
            child: Container(
              color: Colors.white,
              width:dialogWidth,
              child: Obx(() => Column(
                children: [
                  CustomAppBar(title: hinttext,prefix: Container(),suffix: CloseBtnV1(
                    onTap: (){checkAndClearSearch();Navigator.pop(context);},
                  ),width:dialogWidth-100,
                  ),
                  /* !showSearch?Container():*/Container(
                    height: 50,
                    width: dialogWidth,
                    margin: const EdgeInsets.all(15),
                    alignment: Alignment.centerLeft,
                    child: TextFormField(
                      //    style: textFormTs1,
                      //focusNode: f4,
                      //scrollPadding: EdgeInsets.only(bottom: 200),
                      decoration:  InputDecoration(
                          hintText: "Search",
                          // hintStyle: textFormHintTs1,
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: ColorUtil.greyBorder)
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: ColorUtil.primary)
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15,vertical: 0.0)
                      ),
                      cursorColor:  ColorUtil.primary,
                      onEditingComplete: (){
                        FocusScope.of(context).unfocus();
                      },
                      onChanged: (v){
                        dataNotifier.value=data.where((element) => element.toString().toLowerCase().contains(v.toLowerCase())).toList();
                      },
                    ),
                  ),
                  dataNotifier.isEmpty?Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: const Text("No Data Found",),
                  ):
                  Flexible(child: ListView.builder(
                    itemCount: dataNotifier.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemBuilder: (ctx,index){
                      return   GestureDetector(
                        onTap:(){
                          FocusScope.of(context).unfocus();
                          Navigator.pop(ctx);
                          if(isToJson) {
                            if(selectedData.value!=dataNotifier[index]){
                              selectedData.value=dataNotifier[index];
                              selectedValueFunc(dataNotifier[index]);
                            }
                          }
                          else {
                            if(selectedData.value!={"value":dataNotifier[index]}){
                              selectedData.value={"value":dataNotifier[index]};
                              selectedValueFunc(dataNotifier[index]);
                            }
                          }
                          checkAndClearSearch();
                        },
                        child: Container(
                          height: 45,
                          width:dialogWidth,
                          padding: const EdgeInsets.only(left: 20,),
                          margin: const EdgeInsets.only(left: 15,right: 15),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color:(isToJson?"${dataNotifier[index][propertyId].toString()}":"${dataNotifier[index].toString()}" )== (isToJson?selectedData[propertyId].toString():selectedData['value'])?ColorUtil.search2ActBg:ColorUtil.search2InActBg,
                          ),
                          child:  Text(isToJson?"${dataNotifier[index][propertyName]}":"${dataNotifier[index]}",
                            style: (isToJson?"${dataNotifier[index][propertyId].toString()}":"${dataNotifier[index].toString()}" )== (isToJson?selectedData[propertyId].toString():selectedData['value'].toString())?
                            ColorUtil.search2ActiveTS:ColorUtil.search2InActiveTS,
                          ),
                        ),
                      );
                    },
                  ))
                ],
              ),),
            ),
          ),
        ),
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
    );
  }

  @override
  void triggerChange() {
    selectedValueFunc(getValueMap());
  }
}
