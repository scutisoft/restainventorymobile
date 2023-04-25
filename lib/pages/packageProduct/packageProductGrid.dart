import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_utils/mixins/extensionMixin.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:flutter_utils/utils/extensionUtils.dart';
import 'package:get/get.dart';
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


class PackageProductGrid extends StatefulWidget {
  VoidCallback navCallback;
  PackageProductGrid({Key? key, required this.navCallback}) : super(key: key);

  @override
  State<PackageProductGrid> createState() => _PackageProductGridState();
}

class _PackageProductGridState extends State<PackageProductGrid>
    with HappyExtension
    implements HappyExtensionHelperCallback {
  Map widgets = {};
  var totalCount = 0.obs;
  late HE_ListViewBody he_listViewBody;

  @override
  void initState() {
    he_listViewBody = HE_ListViewBody(
      data: [],
      getWidget: (e) {
        return HE_PackageProductContent(
          data: e,
          onDelete: (dataJson) {

          },
          onEdit: (updatedMap) {
            he_listViewBody.updateArrById("PackageId", updatedMap);
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
            title: "Package Product",
            onTap: widget.navCallback,
          ),
          CustomAppBar2(
            title: "Total Package Product",
            subTitle: "Available",
            count: totalCount,
            addCb: () {
             /* fadeRoute(ReceipeForm(
                closeCb: (e) {
                  he_listViewBody.addData(e['Table'][0]);
                  totalCount.value = he_listViewBody.data.length;
                },
              ));*/
            },
          ),
          Flexible(child: he_listViewBody),
          Obx(() => NoData(
            show: he_listViewBody.widgetList.isEmpty,
          )),
        ],
      ),
    );
  }

  @override
  void assignWidgets() {
    var dj = {"PackageId": null};
    parseJson(widgets, "",
        traditionalParam:
        TraditionalParam(getByIdSp: "IV_PackageProductMaster_GetPackageProductDetail"),
        needToSetValue: false, resCb: (res) {
          console(res);
          try {
            totalCount.value = res['Table'].length;
            he_listViewBody.assignWidget(res['Table']);
          } catch (e) {}
        },
        loader: showLoader,
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

class HE_PackageProductContent extends StatelessWidget
    implements HE_ListViewContentExtension {
  Map data;
  Function(Map)? onEdit;
  Function(String)? onDelete;
  GlobalKey globalKey;
  HE_PackageProductContent(
      {Key? key,
        required this.data,
        this.onEdit,
        this.onDelete,
        required this.globalKey})
      : super(key: key) {
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${dataListener['PackageName']}",
                  style:
                  ts20M(ColorUtil.themeBlack, fontfamily: 'AH', fontsize: 18),
                ),
                inBtwHei(),
                Text(
                  "${dataListener['OutletProductName']}",
                  style:
                  ts20M(ColorUtil.themeBlack, fontfamily: 'AR', fontsize: 15),
                  maxLines: 5,overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GridEditIcon(
            hasAccess: true,
            onTap: () {
              /* fadeRoute(ReceipeForm(
                          isEdit: true,
                          dataJson: getDataJsonForGrid({
                            "RecipeId": dataListener['RecipeId']
                          }),
                          closeCb: (e) {
                            updateDataListener(e['Table'][0]);
                            onEdit!(e['Table'][0]);
                          },
                        ));*/
            },
          ),
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
