import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_utils/mixins/extensionMixin.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:flutter_utils/utils/extensionUtils.dart';
import 'package:get/get.dart';
import '../commonView.dart';
import '/utils/constants.dart';
import '/utils/utils.dart';
import '/api/apiUtils.dart';
import '/utils/colorUtil.dart';
import '/widgets/listView/HE_ListView.dart';
import '/widgets/loader.dart';
import '/utils/sizeLocal.dart';
import '/widgets/customAppBar.dart';
import 'receipeForm.dart';

class RecipeMasterGrid extends StatefulWidget {
  VoidCallback navCallback;
  RecipeMasterGrid({Key? key, required this.navCallback}) : super(key: key);

  @override
  State<RecipeMasterGrid> createState() => _RecipeMasterGridState();
}

class _RecipeMasterGridState extends State<RecipeMasterGrid>
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
        return HE_DepDisContent(
          data: e,
          onDelete: (dataJson) {},
          onEdit: (updatedMap) {
            he_listViewBody.updateArrById("ReceipeId", updatedMap);
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
            title: "Recipe Master",
            onTap: widget.navCallback,
          ),
          CustomAppBar2(
            title: "Total Recipe",
            subTitle: "Available",
            count: totalCount,
            addCb: () {
              fadeRoute(ReceipeForm(
                closeCb: (e) {
                  he_listViewBody.addData(e['Table'][0]);
                  totalCount.value = he_listViewBody.data.length;
                },
              ));
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
    var dj = {"RecipeId": null};
    parseJson(widgets, "",
        traditionalParam:
            TraditionalParam(getByIdSp: "IV_Recipe_GetRecipeDetail"),
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

class HE_DepDisContent extends StatelessWidget
    implements HE_ListViewContentExtension {
  Map data;
  Function(Map)? onEdit;
  Function(String)? onDelete;
  GlobalKey globalKey;
  HE_DepDisContent(
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
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${dataListener['RecipeName']}",
                      style:
                          ts20M(ColorUtil.red, fontfamily: 'AH', fontsize: 18),
                    ),
                    inBtwHei(),
                    Text(
                      "${dataListener['RecipeTypeName'] ?? ""}",
                      style: ts20M(ColorUtil.themeBlack,
                          fontfamily: 'AH', fontsize: 18),
                    ),
                    inBtwHei(),
                    Text(
                      "${dataListener['RecipeCategoryName'] ?? ""}",
                      style: ts20M(ColorUtil.themeBlack,
                          fontfamily: 'AH', fontsize: 18),
                    ),
                    inBtwHei(),
                    Text(
                      "${dataListener['CuisineName'] ?? ""}",
                      style: ts20M(ColorUtil.themeBlack,
                          fontfamily: 'AH', fontsize: 18),
                    ),
                    inBtwHei(),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${dataListener['YieldQuantity']}",
                      style:
                          ts20M(ColorUtil.red, fontfamily: 'AH', fontsize: 18),
                    ),
                    inBtwHei(),
                    Text(
                      "${dataListener['TotalCost']}",
                      style:
                          ts20M(ColorUtil.red, fontfamily: 'AH', fontsize: 18),
                    ),
                    inBtwHei(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        EyeIcon(
                          onTap: () {
                            fadeRoute(CommomView(
                              pageTitle: "Recipe Master",
                              spName:
                                  "IV_DepartmentDistribution_ViewDepartmentDistributionDetail",
                              page: "Recipe",
                              dataJson: getDataJsonForGrid({
                                "RecipeId": dataListener['RecipeId'],
                              }),
                            ));
                          },
                        ),
                        GridEditIcon(
                          hasAccess: true,
                          onTap: () {
                            // fadeRoute(DepartmentDistributionForm(
                            //   isEdit: true,
                            //   dataJson: getDataJsonForGrid({
                            //     "DepartmentDistributionId":
                            //         dataListener['DepartmentDistributionId']
                            //   }),
                            //   closeCb: (e) {
                            //     updateDataListener(e['Table'][0]);
                            //     onEdit!(e['Table'][0]);
                            //   },
                            // ));
                          },
                        ),
                        GridDeleteIcon(
                          hasAccess: true,
                          onTap: () {
                            onDelete!(getDataJsonForGrid(
                                {"RecipeId": dataListener['RecipeId']}));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
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
