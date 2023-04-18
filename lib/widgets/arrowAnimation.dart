import 'package:flutter/material.dart';

import '../utils/colorUtil.dart';
class ArrowAnimation extends StatefulWidget {
  Function(bool) openCb;
  bool isclose;
  ArrowAnimation({required this.openCb,required this.isclose});

  final ArrowAnimationState arrowAnimationState=ArrowAnimationState();
  @override
  ArrowAnimationState createState() => arrowAnimationState;

}

class ArrowAnimationState extends State<ArrowAnimation> with TickerProviderStateMixin{
  late Animation arrowAnimation;
  late AnimationController arrowAnimationController;
  bool open=false;

  @override
  void initState() {
    arrowAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    arrowAnimation = Tween(begin: 0.0, end: 1.5).animate(arrowAnimationController);
    super.initState();
  }

  close(){
    arrowAnimationController.reverse();
  }

  @override
  void dispose(){
    arrowAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(widget.isclose){
      open=false;
      close();
    }
    else if(!open){
      arrowAnimationController.isCompleted
          ? arrowAnimationController.reverse()
          : arrowAnimationController.forward();
      open=true;
    }
    return  GestureDetector(
      onTap:null /*(){
        arrowAnimationController.isCompleted
            ? arrowAnimationController.reverse()
            : arrowAnimationController.forward();

        setState(() {
          open=!open;
        });
        widget.openCb(open);

      }*/,
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent
        ),
        child:  AnimatedBuilder(
          animation: arrowAnimationController,
          builder: (context, child) =>
              Transform.rotate(
                angle: arrowAnimation.value,
                child: Icon(
                  Icons.keyboard_arrow_right,
                  size: 30.0,
                  color: ColorUtil.red2,
                ),
              ),
        ),
      ),
    );
  }
}
