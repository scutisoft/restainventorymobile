import 'package:flutter/material.dart';
import 'package:restainventorymobile/utils/constants.dart';

import '../../utils/colorUtil.dart';
import '../../utils/sizeLocal.dart';
import '../../widgets/customAppBar.dart';
import 'report.dart';
class ReportSelection extends StatefulWidget {
  VoidCallback navCallback;
  ReportSelection({Key? key,required this.navCallback}) : super(key: key);
  @override
  State<ReportSelection> createState() => _ReportSelectionState();
}

class _ReportSelectionState extends State<ReportSelection> {

  List<dynamic> reportList=[
    {"Title":"Stock Report","ReportName":"StockReport","Url":"/api/ReportApi/GetStockReport"}
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeConfig.screenHeight,
      width: SizeConfig.screenWidth,
      child: Column(
        children: [
          CustomAppBar(
            title: "Report",
            onTap: widget.navCallback,
          ),
          const Spacer(),
          Wrap(
            children: [
              for(int i=0;i<reportList.length;i++)
                GestureDetector(
                  onTap: (){
                    fadeRoute(Report(reportDetail: reportList[i],));
                  },
                  child: Container(
                    height: 125,
                    width: 125,
                    padding: const EdgeInsets.only(left: 5,right: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ColorUtil.greyBorder)
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${reportList[i]['Title']}",style: ts20M(ColorUtil.themeBlack),),
                      ],
                    ),
                  ),
                )
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
