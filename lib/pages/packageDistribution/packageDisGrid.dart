import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_utils/mixins/extensionMixin.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:flutter_utils/utils/extensionUtils.dart';
import 'package:get/get.dart';
import 'package:restainventorymobile/widgets/searchDropdown/search2.dart';
import '../../utils/utilWidgets.dart';
import '../commonView.dart';
import '/utils/constants.dart';
import '/utils/utils.dart';
import '/api/apiUtils.dart';
import '/utils/colorUtil.dart';
import '/widgets/listView/HE_ListView.dart';
import '/widgets/loader.dart';
import '/utils/sizeLocal.dart';
import '/widgets/customAppBar.dart';
import 'packageDisForm.dart';


class PackageDistribution extends StatefulWidget {
  VoidCallback navCallback;
  PackageDistribution({Key? key, required this.navCallback}) : super(key: key);

  @override
  State<PackageDistribution> createState() => _PackageDistributionState();
}

class _PackageDistributionState extends State<PackageDistribution> with HappyExtension implements HappyExtensionHelperCallback {
  Map widgets = {};
  var totalCount = 0.obs;
  late HE_ListViewBody he_listViewBody;

  RxBool loader=RxBool(false);

  @override
  void initState() {
    he_listViewBody = HE_ListViewBody(
      data: [],
      getWidget: (e) {
        return HE_PkgDisContent(
          data: e,
          onDelete: (dataJson) {
            gridDelete(() {
              sysDeleteHE_ListView(he_listViewBody, "PackageDistributionId",dataJson: dataJson,loader: showLoader,
                  traditionalParam: TraditionalParam(executableSp: "IV_PackageDistribution_DeletePackageDistributionDetail"),isCustomDialog: true,successCallback: deleteCallback);
            });
          },
          onEdit: (updatedMap) {
            he_listViewBody.updateArrById("PackageDistributionId", updatedMap);
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
            title: "Package Distribution",
            onTap: widget.navCallback,
          ),
          CustomAppBar2(
            title: "Total Package Distribution",
            subTitle: "Available",
            count: totalCount,
            addCb: () {
              fadeRoute(PackageDisForm(
                closeCb: (e) {
                  he_listViewBody.addData(e['Table'][0]);
                  totalCount.value = he_listViewBody.data.length;
                },
              ));
            },
          ),
          Flexible(child: he_listViewBody),
          Obx(() => NoData(show: he_listViewBody.widgetList.isEmpty,)),
        ],
      ),
    );
  }

  @override
  void assignWidgets() {
    var dj = {"PackageDistributionId": null};
    parseJson(widgets, "",
        traditionalParam:
            TraditionalParam(getByIdSp: "IV_PackageDistribution_GetPackageDistributionDetail"),
        needToSetValue: false, resCb: (res) {
      console(res);
      try {
        totalCount.value = res['Table'].length;
        he_listViewBody.assignWidget(res['Table']);
      } catch (e) {}
    },
        loader: loader,
        dataJson: jsonEncode(dj),
        extraParam: MyConstants.extraParam);
  }

  @override
  void dispose() {
    he_listViewBody.clearData();
    clearOnDispose();
    super.dispose();
  }
}

class HE_PkgDisContent extends StatelessWidget implements HE_ListViewContentExtension {
  Map data;
  Function(Map)? onEdit;
  Function(String)? onDelete;
  GlobalKey globalKey;
  HE_PkgDisContent({Key? key, required this.data, this.onEdit, this.onDelete, required this.globalKey}) : super(key: key) {
    dataListener.value = data;
  }

  var dataListener = {}.obs;
  //var separatorHeight = 50.0.obs;

  @override
  Widget build(BuildContext context) {
    /*WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      separatorHeight.value=parseDouble(globalKey.currentContext!.size!.height)-30;
    });*/
    return Obx(() => Container(
          key: globalKey,
          margin: const EdgeInsets.only(bottom: 10, left: 15, right: 10),
          padding: const EdgeInsets.all(10),
          width: SizeConfig.screenWidth! * 1,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0XFFffffff),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${dataListener['PackageName']}",
                      style:
                          ts20M(ColorUtil.red, fontfamily: 'AH', fontsize: 18),
                    ),
                    inBtwHei(),
                    Text(
                      "${dataListener['PackageDistributionQuantity'] ?? ""}",
                      style: ts20M(ColorUtil.themeBlack,
                          fontfamily: 'AH', fontsize: 18),
                    ),
                    inBtwHei(),
                    Text(
                      "${dataListener['OutletName'] ?? ""}",
                      style: ts20M(ColorUtil.themeBlack,
                          fontfamily: 'AH', fontsize: 18),
                    ),
                  ],
                ),
              ),
              EyeIcon(
                onTap: (){
                  fadeRoute(PkgDisItemList(
                      items:checkNullEmpty(dataListener['LinkedItemCount'])? []:dataListener['LinkedItemCount'].toString().split(","),
                      title: dataListener['PackageName'])
                  );
                },
              )
            ],
          ),
        ));
  }

  @override
  updateDataListener(Map data) {
    data.forEach((key, value) {
      if (dataListener.containsKey(key)) {
        dataListener[key] = value;
      }
    });
  }
}


class PkgDisItemList extends StatelessWidget {
  List items;
  String title;
  PkgDisItemList({Key? key,required this.items,required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageBody(
      body: Column(
        children: [
          CustomAppBar(
            title: title,
            prefix: ArrowBack(
              onTap: (){
                Get.back();
              },
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (ctx,i){
              return Container(
                margin: const EdgeInsets.only(left: 10,right: 10,top: 10),
                padding: const EdgeInsets.all(10),
                decoration: ColorUtil.formContBoxDec,
                child: Text("${items[i]}",style: ts20M(ColorUtil.themeBlack,fontsize: 16),),
              );
            },
          )
        ],
      ),
    );
  }
}
