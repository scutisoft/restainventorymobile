
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '/utils/sizeLocal.dart';
import '/widgets/fittedText.dart';
import '/helper/language.dart';
import '/utils/colorUtil.dart';
import '/utils/constants.dart';
import 'accessWidget.dart';
import '/widgets/dateRangePicker.dart' as DateRagePicker;
import 'swipe2/core/cell.dart';

class CustomAppBar extends StatelessWidget {
  String title;
  Widget? prefix;
  Widget? suffix;
  VoidCallback? onTap;
  double? width;
  Decoration? decoration;
  CustomAppBar({required this.title,this.prefix,this.suffix,this.onTap,this.width,this.decoration});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: SizeConfig.screenWidth,
      decoration: decoration??BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          const SizedBox(width:20,),
          prefix==null?GestureDetector(
            onTap:onTap,
            child: Container(
                height:50,
                width:50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorUtil.bgColor,
                ),
                alignment: Alignment.center,
                child: SizedBox(
                  width: 30,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 1,
                    runSpacing: 1,
                    children: [
                      for(int i=1;i<=4;i++)
                      Container(
                        height: 11,width: 11,
                        decoration: BoxDecoration(
                          color: ColorUtil.red,
                          borderRadius:  BorderRadius.only(
                            topLeft: Radius.circular(i==1?0:3),
                              topRight: Radius.circular(i==2?0:3),
                              bottomLeft: Radius.circular(i==3?0:3),
                              bottomRight: Radius.circular(i==4?0:3)
                          )
                        ),
                      )
                    ],
                  ),
                ),
            ),
          ):prefix!,
          const SizedBox(width:20,),
          FittedText(
            height: 40,
            width:width?? (SizeConfig.screenWidth!-200),
            text: title,
            textStyle: ts20(ColorUtil.themeBlack,fontfamily: 'AR',fontsize: 18,fontWeight: FontWeight.w500),
          ),
          //Text(title,style:  ts18(ColorUtil.primaryTextColor2,fontfamily: Language.regularFF),),
          const Spacer(),
          suffix??Container(),
          const SizedBox(width:5,),
        ],
      ),
    );
  }
}

class CustomAppBar2 extends StatelessWidget {
  Rx<dynamic> count;
  String title;
  String subTitle;
  VoidCallback? addCb;
  bool hasAdd;
  bool needDatePicker;
  Function(dynamic)? onDateSel;
  bool needDbDateFormat;
  CustomAppBar2({Key? key,required this.count,required this.title,required this.subTitle,this.addCb ,this.hasAdd=true,this.needDatePicker=false,
    this.onDateSel,this.needDbDateFormat=true}) : super(key: key);

  RxList<DateTime> dateList=RxList();
  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  text: title,
                  textStyle: ts20(ColorUtil.themeBlack,fontfamily: 'AM'),
                ),
                const SizedBox(height: 5,),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() => Text("${count.value}",style: ts20(ColorUtil.red,fontfamily: 'AM',fontsize: 36),)),
                    const SizedBox(width: 10,),
                    FlexFittedText(
                      text: subTitle,
                      textStyle: ts20(ColorUtil.text2,fontfamily: 'AM'),
                    ),
                  ],
                )
              ],
            ),
          ),
          const Spacer(),
          Visibility(
            visible: needDatePicker,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: CustomTapIcon(
                onTap:() async{
                  final List<DateTime>?  picked1 = await DateRagePicker.showDatePicker(
                      context: context,
                      initialFirstDate:dateList.isEmpty? DateTime.now():dateList[0],
                      initialLastDate: dateList.isEmpty? DateTime.now():dateList[1],
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now()
                  );
                  if (picked1 != null && picked1.length == 2) {
                    dateList.clear();
                    dateList.add(picked1[0]);
                    dateList.add(picked1[1]);
                  }
                  else if(picked1!=null && picked1.length ==1){
                    dateList.clear();
                    dateList.add(picked1[0]);
                    dateList.add(picked1[0]);
                  }

                  if(onDateSel!=null){
                    if(needDbDateFormat){
                      onDateSel!({"FromDate":DateFormat(MyConstants.dbDateFormat).format(dateList[0]),
                        "ToDate":DateFormat(MyConstants.dbDateFormat).format(dateList[1])
                      });
                    }
                    else{
                      onDateSel!(dateList.value);
                    }

                  }
                },
                bg: Colors.white,
                widget: SvgPicture.asset("assets/icons/calendar.svg",height: 25,),
              ),
            ),
          ),
          Visibility(
            visible: hasAdd,
            child: GridAddIcon(
              onTap:addCb,
            ),
          ),

        ],
      ),
    );
  }
}


class ArrowBack extends StatelessWidget {

  VoidCallback? onTap;
  double height;
  double? imageheight;
  Color? iconColor;
  ArrowBack({this.onTap,this.height=50,this.imageheight,this.iconColor});

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: onTap,
      child: Container(
          height: 50,
          width: 50 ,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: ColorUtil.bgColor,
          ),
          alignment: Alignment.center,
          child: Center(
            child: Icon(Icons.arrow_back_ios_outlined,color: iconColor??ColorUtil.red,size: 25,),
          )
      ),
    );
  }
}


class EyeIcon extends StatelessWidget {
  VoidCallback? onTap;
  EyeIcon({Key? key,this.onTap}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:onTap,
      child: Container(
        width: 30,
        height: 30,
        alignment:Alignment.center,
        decoration: BoxDecoration(
            color: Color(0xff8D54EF).withOpacity(0.3),
            borderRadius: BorderRadius.circular(5)
        ),
        child: SvgPicture.asset("assets/icons/view.svg",height: 20,),
        //child: Icon(Icons.remove_red_eye_outlined,color: Color(0xff8D54EF),size: 20,),
      ),
    );
  }
}

class FilterIcon extends StatelessWidget {
  VoidCallback? onTap;
  FilterIcon({Key? key,this.onTap}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:onTap,
      child: Container(
        width: 0,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ColorUtil.primary,
        ),
        child: Icon(Icons.filter_alt_outlined,color:ColorUtil.theme,),
      ),
    );
  }
}
class RefreshIcon extends StatelessWidget {
  VoidCallback? onTap;
  bool visible;
  Color bg;
  Color iconColor;
  BoxShape boxShape;
  RefreshIcon({Key? key,this.onTap,this.visible=true,this.bg= Colors.white,this.iconColor=const Color(0xff5A8418),
  this.boxShape= BoxShape.rectangle}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: GestureDetector(
        onTap:onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bg,
            shape: boxShape
          ),
          child: Icon(Icons.refresh,color:iconColor,),
        ),
      ),
    );
  }
}

class GridAddIcon extends StatelessWidget {
  VoidCallback? onTap;
  GridAddIcon({Key? key,this.onTap}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ColorUtil.themeWhite,
        ),
        child: Icon(Icons.add_rounded,color:ColorUtil.red,size: 35,),
      ),
    );
  }
}

EdgeInsets actionIconMargin=const EdgeInsets.only(left: 5);

class GridDeleteIcon extends StatelessWidget {
  VoidCallback? onTap;
  double height;
  bool hasAccess;
  EdgeInsets margin;
  GridDeleteIcon({Key? key,this.onTap,this.height=30,required this.hasAccess,this.margin=const EdgeInsets.only(left: 7)}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AccessWidget(
      onTap:onTap,
      hasAccess: hasAccess,
      needToHide: true,
      widget: Container(
        width: height,
        height: height,
        alignment:Alignment.center,
        margin: margin,
        decoration: BoxDecoration(
            color: ColorUtil.red2.withOpacity(0.3),
            borderRadius: BorderRadius.circular(5)
        ),
        child: SvgPicture.asset("assets/icons/delete.svg",height: 20,),
        //child: Icon(Icons.delete_outline,color: ColorUtil.red,size: 20,),
        //child:Text('View ',style: TextStyle(color: ColorUtil.primaryTextColor2,fontSize: 14,fontFamily: 'RR'),),
      ),
    );
  }
}
class GridEditIcon extends StatelessWidget {
  VoidCallback? onTap;
  double height;
  bool hasAccess;
  EdgeInsets margin;
  GridEditIcon({Key? key,this.onTap,this.height=30,required this.hasAccess,this.margin=const EdgeInsets.only(left: 7)}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AccessWidget(
      onTap:onTap,
      hasAccess: hasAccess,
      needToHide: true,
      widget: Container(
        width: height,
        height: height,
        alignment:Alignment.center,
        margin: margin,
        decoration: BoxDecoration(
            color: Color(0xFF5492EF).withOpacity(0.3),
            borderRadius: BorderRadius.circular(5)
        ),
        child: SvgPicture.asset("assets/icons/edit.svg",height: 20,),
        //child: Icon(Icons.edit,color: ColorUtil.themeBlack,size: 20,),
        //child:Text('View ',style: TextStyle(color: ColorUtil.primaryTextColor2,fontSize: 14,fontFamily: 'RR'),),
      ),
    );
  }
}


class LanguageSwitch extends StatelessWidget {
  VoidCallback onChange;
  LanguageSwitch({required this.onChange});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(selectedLanguage.value==1){
          selectedLanguage.value=2;
        }
        else if(selectedLanguage.value==2){
          selectedLanguage.value=1;
        }
        Language.parseJson(selectedLanguage.value).then((value){
          onChange();
        });

      },
      child: Container(
        height: 50,
        width: 50,
        margin: const EdgeInsets.only(right: 10),
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Image.asset(selectedLanguage.value==1?"assets/icons/English.png":"assets/icons/Tamil.png",height: 30,),
      ),
    );
  }
}


class CloseBtnV1 extends StatelessWidget {
  VoidCallback? onTap;
  CloseBtnV1({Key? key,this.onTap}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ColorUtil.bgColor,
        ),
        child: Icon(Icons.clear,color:ColorUtil.red,),
      ),
    );
  }
}

class LeftHeader extends StatelessWidget {
  String title;
  double? width;
  LeftHeader({Key? key,required this.title,this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: width,
      alignment: Alignment.centerLeft,
      padding: MyConstants.LRPadding,
      margin: const EdgeInsets.only(top: 15),
      child: FittedBox(child: Text(title,style: ts20M(ColorUtil.themeBlack,fontsize: 18),)),
      //child: FlexFittedText(text: title,textStyle: ts20M(ColorUtil.themeBlack,fontsize: 18),),
    );
  }
}


class CustomTapIcon extends StatelessWidget {

  VoidCallback? onTap;
  double height;
  Widget widget;
  Alignment alignment;
  Color? bg;
  CustomTapIcon({this.onTap,this.height=50,required this.widget,this.alignment=Alignment.center,this.bg});

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: onTap,
      child: Container(
          height: height,
          width: height ,
          decoration:  BoxDecoration(
            shape: BoxShape.circle,
            color: bg??ColorUtil.bgColor,
          ),
          alignment: alignment,
          child: widget
      ),
    );
  }
}


SwipeAction swipeActionDelete(Function(Function(bool)) ontap,{bool hasAccess=true,bool needBG=false}){
  Color ic=needBG?ColorUtil.themeWhite:ColorUtil.red;
  return   SwipeAction(
    title: "",
    icon: Padding(
      padding:  const EdgeInsets.only(top: 0),
      child: Container(
        height: 50,
        width: 50,
        alignment: Alignment.center,
        //padding: const EdgeInsets.all(8),
          decoration: needBG?BoxDecoration(
            color: hasAccess?ColorUtil.red:ColorUtil.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(50)
          ):null,
          child: SvgPicture.asset("assets/icons/delete.svg",height: 30,color:  hasAccess?ic:ic.withOpacity(0.5),)
      ),
    ),
    onTap:ontap,
    color: ColorUtil.bgColor,
  );
}

SwipeAction swipeActionEdit(Function(Function(bool)) ontap,{bool needBG=false}){
  //125ac6
  Color ic=needBG?ColorUtil.themeWhite:Color(0xff125ac6);
  return   SwipeAction(
    title: "",
    icon: Padding(
      padding:const  EdgeInsets.only(top: 0),
      child: Container(
          // padding: const EdgeInsets.all(8),
          height: 50,
          width: 50,
          alignment: Alignment.center,
          decoration: needBG?BoxDecoration(
              color: Color(0xff125ac6),
              borderRadius: BorderRadius.circular(50)
          ):null,
          child: SvgPicture.asset("assets/icons/edit.svg",height: 30,color: ic,)
      ),
    ),
    onTap: ontap,
    color: ColorUtil.bgColor,
  );
}


class SaveCloseBtn extends StatelessWidget {
  bool isEdit;
  VoidCallback onSave;
  VoidCallback? onClose;
  RxBool isKeyboardVisible;
  String? saveBtnText;
  SaveCloseBtn({Key? key,required this.isEdit,required this.onSave,required this.isKeyboardVisible,this.onClose,this.saveBtnText}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Positioned(
      bottom: 0,
      child: Obx(() => Container(
        margin: const EdgeInsets.only(top: 0,bottom: 0),
        height: isKeyboardVisible.value?0:70,
        width: SizeConfig.screenWidth,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: (){
                Get.back();
                if(onClose!=null){
                  onClose!();
                }
              },
              child: Container(
                width: SizeConfig.screenWidth!*0.4,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: ColorUtil.primary),
                  color: ColorUtil.primary.withOpacity(0.3),
                ),
                child:Center(child: Text(Language.cancel,style: ts16(ColorUtil.primary,), )) ,
              ),
            ),
            GestureDetector(
              onTap: onSave,
              child: Container(
                width: SizeConfig.screenWidth!*0.4,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: ColorUtil.primary,
                ),
                child:Center(child: Text(isEdit?saveBtnText??Language.update:Language.save,style: ts16(ColorUtil.themeWhite,), )) ,
              ),
            ),
          ],
        ),
      )),
    );
  }
}
