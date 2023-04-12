import 'package:flutter/material.dart';
import '/utils/sizeLocal.dart';
import '/widgets/customAppBar.dart';
class Dashboard extends StatefulWidget {
  VoidCallback navCallback;
  Dashboard({Key? key,required this.navCallback}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeConfig.screenHeight,
      width: SizeConfig.screenWidth,
      child: Column(
        children: [
          CustomAppBar(
            title: "Dashboard",
            onTap: widget.navCallback,
          ),
        ],
      ),
    );
  }
}
