
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:restainventorymobile/utils/constants.dart';
import '../api/apiUtils.dart';
import '../helper/language.dart';
import '../utils/colorUtil.dart';
import '../utils/sizeLocal.dart';
import 'shimmer.dart';

class Loader extends StatelessWidget {
  bool? value;
  Loader({this.value});
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: value??false,
      //ignoring:value!?false: true,
      child: Container(
          height: SizeConfig.screenHeight,
          width: SizeConfig.screenWidth,
          color:Colors.black26,
          child: Center(
            child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                 child: Image.asset("assets/loader.gif",filterQuality: FilterQuality.high,gaplessPlayback: true,isAntiAlias: true,)
                //child: CircularProgressIndicator(color: ColorUtil.secondary,)
            ),
          )
      ),
    );
  }
}

class Blur extends StatelessWidget {
  bool? value;
  Blur({this.value});
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring:value!?false: true,
      child: AnimatedOpacity(
        duration: MyConstants.animeDuration,
        curve: MyConstants.animeCurve,
        opacity: value!?1:0,
        // opacity: 1,
        child: Container(
            height: SizeConfig.screenHeight,
            width: SizeConfig.screenWidth,
            color:Colors.black54,
        ),
      ),
    );
  }
}

class NoData extends StatelessWidget {
  bool show;
  double topPadding;
  String text;
  NoData({this.show=true,this.topPadding=20,this.text="No Data Available"});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: show,
      child: Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(top: topPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset("assets/icons/nodata.svg",height: 150,),
              const SizedBox(height: 20,),
              Text(text,
                style: TextStyle(fontFamily: 'AH',fontSize: 18,color: ColorUtil.red2),
              ),
            ],
          )
      ),
    );
  }
}


//Shimmmer Loaders
class BannerPlaceholder extends StatelessWidget {
  const BannerPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200.0,
       margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.white,
      ),
    );
  }
}

class TitlePlaceholder extends StatelessWidget {
  final double width;

  const TitlePlaceholder({
    Key? key,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width,
            height: 12.0,
            color: Colors.white,
          ),
          SizedBox(height: 8.0),
          Container(
            width: width,
            height: 12.0,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

enum ContentLineType {
  twoLines,
  threeLines,
}

class ContentPlaceholder extends StatelessWidget {
  final ContentLineType lineType;

  const ContentPlaceholder({
    Key? key,
    required this.lineType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 96.0,
            height: 72.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 10.0,
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 8.0),
                ),
                if (lineType == ContentLineType.threeLines)
                  Container(
                    width: double.infinity,
                    height: 10.0,
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 8.0),
                  ),
                Container(
                  width: 100.0,
                  height: 10.0,
                  color: Colors.white,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}


class ShimmerLoader extends StatelessWidget {
  RxBool loader;
  double topMargin;
  ShimmerLoader({Key? key,required this.loader,this.topMargin=0.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      ()=> Visibility(
        visible: loader.value,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          margin:  EdgeInsets.only(top: topMargin),
          //height: SizeConfig.screenHeight,
          width: SizeConfig.screenWidth,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              enabled: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BannerPlaceholder(),
                  const TitlePlaceholder(width: double.infinity),
                  const SizedBox(height: 16.0),
                  const ContentPlaceholder(
                    lineType: ContentLineType.threeLines,
                  ),
                  const SizedBox(height: 16.0),
                  const TitlePlaceholder(width: 200.0),
                  const SizedBox(height: 16.0),
                  const ContentPlaceholder(
                    lineType: ContentLineType.twoLines,
                  ),
                  const SizedBox(height: 16.0),
                  const TitlePlaceholder(width: 200.0),
                  const SizedBox(height: 16.0),
                  const ContentPlaceholder(
                    lineType: ContentLineType.twoLines,
                  ),
                ],
              )
          ),
        ),
      ),
    );
  }
}
