import 'package:flutter/material.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:flutter_utils/utils/extensionHelper.dart';
import 'package:flutter_utils/utils/utils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restainventorymobile/api/sp.dart';
import 'package:restainventorymobile/notifier/configuration.dart';
import 'package:restainventorymobile/utils/constants.dart';
import 'package:restainventorymobile/utils/sizeLocal.dart';
import 'package:restainventorymobile/utils/utils.dart';
import 'package:restainventorymobile/widgets/customAppBar.dart';
import 'package:restainventorymobile/widgets/expectedDateContainer.dart';
import 'package:restainventorymobile/widgets/searchDropdown/search2.dart';

import '../../utils/colorUtil.dart';
import '../../utils/utilWidgets.dart';
import '../../widgets/customWidgetsForDynamicParser/searchDrp2.dart';
import '../../widgets/searchDropdown/dropdown_search.dart';
import '../../widgets/singleDatePicker.dart';
class IndentForm extends StatefulWidget {
  const IndentForm({Key? key}) : super(key: key);

  @override
  State<IndentForm> createState() => _IndentFormState();
}

class _IndentFormState extends State<IndentForm> with HappyExtension,TickerProviderStateMixin implements HappyExtensionHelperCallback{

  Map widgets={};
  String page="IndentOrder";

  Rxn<DateTime> donationDate=Rxn<DateTime>();

  late TabController tabController;

  @override
  void initState(){
    tabController=TabController(length: 2, vsync: this);
    assignWidgets();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageBody(
        body: Container(
          child: Column(
            children: [
              CustomAppBar(
                  title: "Add Indent Order",
                prefix: ArrowBack(
                  onTap: (){
                    Get.back();
                  },
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    LeftHeader(title: "To Store"),
                    widgets['ToStoreId'],
                    LeftHeader(title: "Delivery Type"),
                    widgets['DeliveryTypeId'],
                    LeftHeader(title: "Reason"),
                    widgets['Reason'],
                    LeftHeader(title: "Expected Date"),
                    GestureDetector(
                        onTap: () async{
                          final DateTime? picked = await showDatePicker2(
                              context: context,
                              initialDate:  donationDate.value==null?DateTime.now():donationDate.value!, // Refer step 1
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2050),
                              builder: (BuildContext context,Widget? child){
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: ColorUtil.primary, // header background color
                                      onPrimary: ColorUtil.themeWhite, // header text color
                                      onSurface: ColorUtil.themeBlack, // body text color
                                    ),
                                    // textTheme: TextTheme(bodySmall: TextStyle(fontFamily: 'AM',color: Colors.red))
                                  ),
                                  child: child!,
                                );
                              });
                          if (picked != null) {
                            donationDate.value=picked;
                          }
                        },
                        child: Obx(() =>  ExpectedDateContainer(
                          text: donationDate.value ==null?"Select Date": "${DateFormat.yMMMd().format(donationDate.value!)}",
                        ))
                    ),
                    TabBar(
                        controller: tabController,
                        tabs: [
                          Text("Raw Material"),
                          Text("Recipe"),
                        ]
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
    );
  }

  double scrollPadding=10;

  @override
  void assignWidgets() async{
    widgets.clear();
    widgets['ToStoreId']=SlideSearch(dataName: "ToStoreId", selectedValueFunc: (e){}, hinttext: "Select To Store",data: [],);
    widgets['DeliveryTypeId']=SearchDrp2(map:  {"dataName":"DeliveryTypeId","hintText":"Select Delivery Type","labelText":"Delivery Type","showSearch":false,"mode":Mode.DIALOG,"dialogMargin":const EdgeInsets.all(0.0)},);
    widgets['Reason']=AddNewLabelTextField(
      dataname: 'Reason',
      hasInput: true,
      required: true,
      labelText: "Reason",
      scrollPadding: scrollPadding,
      regExp: null,
      onChange: (v){},
      onEditComplete: (){
        FocusScope.of(context).unfocus();
      },
      maxlines: null,
    );

    fillTreeDrp(widgets, "ToStoreId",refId: await getSharedPrefStringUtil(SP_STOREID),page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "");
    fillTreeDrp(widgets, "DeliveryTypeId",refId: await getSharedPrefStringUtil(SP_STOREID),page: page,spName: Sp.masterSp, extraParam: MyConstants.extraParam,refType: "");
  }

  @override
  void dispose(){
    widgets.clear();
    super.dispose();
  }
}
