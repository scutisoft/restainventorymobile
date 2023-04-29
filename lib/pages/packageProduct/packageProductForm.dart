import 'package:flutter/material.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/mixins/extensionMixin.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:get/get.dart';
import '/api/apiUtils.dart';
import '/api/sp.dart';
import '/utils/constants.dart';
import '/utils/sizeLocal.dart';
import '/utils/utils.dart';
import '/widgets/alertDialog.dart';
import '/widgets/circle.dart';
import '/widgets/customAppBar.dart';
import '/utils/colorUtil.dart';
import '/utils/utilWidgets.dart';
class PackageProductForm extends StatefulWidget {
  bool isEdit;
  Function? closeCb;
  String dataJson;
  String packageName;
  PackageProductForm({Key? key,this.isEdit=false,this.closeCb,this.dataJson="",this.packageName=""}) : super(key: key);
  @override
  State<PackageProductForm> createState() => _PackageProductFormState();
}

class _PackageProductFormState extends State<PackageProductForm> with HappyExtension implements HappyExtensionHelperCallback {
  Map widgets={};
  String page="PackageProductMaster";
  TraditionalParam traditionalParam=TraditionalParam(
      getByIdSp: "IV_PackageProductMaster_GetPackageProductByIdDetail",
      insertSp: "",
      updateSp: "IV_PackageProductMaster_UpdatePackageProductDetail"
  );
  var isKeyboardVisible=false.obs;

  var unitName="Unit".obs;

  RxList<dynamic> recipeList=RxList<dynamic>();


  var isCartOpen=false.obs;



  List primaryProductList=[];
  RxList<dynamic> productList=RxList<dynamic>();
  RxList<dynamic> selectedProduct=RxList<dynamic>();

  @override
  void initState(){
    assignWidgets();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isKeyboardVisible.value = MediaQuery.of(context).viewInsets.bottom != 0;
    return PageBody(
      body: Stack(
        children: [
          SizedBox(
            height: SizeConfig.screenHeight,
            width: SizeConfig.screenWidth,
            child: Column(
              children: [
                CustomAppBar(
                  title: "${widget.isEdit?"Update":"Add"} Package",
                  width: SizeConfig.screenWidth!-100,
                  prefix: ArrowBack(
                    onTap: (){
                      Get.back();
                    },
                  ),
                ),
                inBtwHei(height: 5),
                Container(
                  height: 50,
                  margin: const EdgeInsets.only(left: 15,right: 15),
                  child: Row(
                   children: [
                     Expanded(
                       child: Text(widget.packageName,style: ts20M(ColorUtil.themeBlack,fontsize: 18),),
                     ),
                     Obx(() => CustomCircle(hei: 40, color: ColorUtil.red2,
                       widget: Text("${selectedProduct.length}",style: ts20M(ColorUtil.themeWhite,fontsize: 18,fontfamily: 'AH'),),
                     ))
                   ],
                  ),
                ),
                inBtwHei(height: 10),
                AddNewLabelTextField(
                  dataname: 'Search',
                  hasInput: true,
                  required: true,
                  labelText: "Search Product",
                  regExp: null,
                  onChange: (v){
                    if(v.isEmpty){
                      productList.value=primaryProductList;
                    }
                    else{
                      productList.value=primaryProductList.where((p0) => p0['Text'].toString().toLowerCase().contains(v.toLowerCase())).toList();
                    }
                  },
                  onEditComplete: (){
                    productList.value=primaryProductList;
                    FocusScope.of(context).unfocus();
                  },
                ),
                Expanded(
                  child: Obx(() => ListView.builder(
                    itemCount: productList.length,
                    shrinkWrap: true,
                    itemBuilder: (ctx,i){
                      return GestureDetector(
                        onTap: (){
                          if(selectedProduct.contains(productList[i]['Id'].toString())){
                            productList[i]['checked']=false;
                            selectedProduct.remove(productList[i]['Id'].toString());
                          }
                          else{
                            productList[i]['checked']=true;
                            selectedProduct.add(productList[i]['Id'].toString());
                          }
                          productList.refresh();
                        },
                        child: Container(
                          height: 50,
                          width:SizeConfig.screenWidth,
                          padding: EdgeInsets.only(left: 15,),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: Colors.transparent
                            //color:(isToJson?"${t[index][propertyName]}":"${t[index]}" )== (isToJson?selectedData[propertyName]:selectedData['value'])?AppTheme.restroTheme:Colors.white,
                          ),
                          child:  Row(
                            children: [
                              AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                                height:25,
                                width: 25,
                                margin: EdgeInsets.only(left: 0,right: 15),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: productList[i]['checked']? ColorUtil.primary:Colors.white,
                                    border: Border.all(color:productList[i]['checked']? Colors.transparent: Colors.grey,)
                                ),
                                child: Icon(Icons.done, color: productList[i]['checked']? Colors.white:Colors.grey, size: 15,),
                              ),
                              Flexible(
                                child: Text("${productList[i]['Text']}",
                                  style: TextStyle(fontFamily: 'RR',fontSize: 15, color: ColorUtil.text1,
                                    // color:(isToJson?"${t[index][propertyName]}":"${t[index]}" )== (isToJson?selectedData[propertyName]:selectedData['value'])?Colors.white: Colors.grey
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )),
                ),
                Obx(() => inBtwHei(height: isKeyboardVisible.value?0:80),)

              ],
            ),
          ),
          SaveCloseBtn(
            isEdit: widget.isEdit,
            isKeyboardVisible: isKeyboardVisible,
            onSave: () {
              sysSubmit(widgets,
                  isEdit: widget.isEdit,
                  needCustomValidation: true,
                  traditionalParam: traditionalParam,
                  loader: showLoader,
                  extraParam: MyConstants.extraParam,
                  onCustomValidation: () {
                    if (selectedProduct.isEmpty) {
                      CustomAlert()
                          .cupertinoAlert("Select Product to Update Package...");
                      return false;
                    }
                    foundWidgetByKey(widgets, "OutletProductId", needSetValue: true, value: selectedProduct.join(","));
                    return true;
                  },
                  successCallback: (e) {
                    console("sysSubmit $e");
                    if (widget.closeCb != null) {
                      widget.closeCb!(e);
                    }
                  });
            },
          ),

        ],
      ),
    );
  }

  @override
  void assignWidgets() async{
    selectedProduct.clear();
    widgets['PackageId']=HiddenController(dataname: "PackageId");
    widgets['OutletProductId']=HiddenController(dataname: "OutletProductId");


    fillTreeDrp(widgets, "OutletProductId",clearValues: false,page: page,refId: "",extraParam: MyConstants.extraParam,spName: Sp.masterSp,resCb: (e){
      //console("OutletProductId $e");
      primaryProductList=e;
      primaryProductList.forEach((element) {element['checked']=false;});
      productList.value=primaryProductList;
      setDat();
    });
    await parseJson(widgets, "",
        dataJson: widget.dataJson,
        traditionalParam: traditionalParam,
        extraParam: MyConstants.extraParam,
        loader: showLoader, resCb: (e) {
          try {

            if(e['Table'][0]['OutletProductId'].toString().isNotEmpty){
              selectedProduct.value=e['Table'][0]['OutletProductId'].toString().split(",");
            }

            console("parseJson ${selectedProduct.length} ${selectedProduct}");
            setDat();
          } catch (e, t) {
            assignWidgetErrorToastLocal(e, t);
          }
        });

  }

  void setDat(){
    primaryProductList.forEach((element) {element['checked']=selectedProduct.contains(element['Id']);});
  }

}
