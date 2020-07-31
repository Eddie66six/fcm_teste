import 'package:flutter/material.dart';

class G2xToaster{
  static var navkey = GlobalKey<NavigatorState>();
  static void showOnTop(){
    var overlayEntry = OverlayEntry(builder: (BuildContext buildContext){
        return ToasterTop(
          millisecondsToDismiss: 10000,
          height: 100.0,
          paddingTop: MediaQuery.of(buildContext).padding.top,
          child: Center(
            child: Container(
              height: 100,
              width: MediaQuery.of(buildContext).size.width - 10,
              margin: EdgeInsets.only(left: 5),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10)
              ),
            ),
          )
        );
      });
      navkey.currentState.overlay.insert(overlayEntry);
  }
}

class ToasterTop extends StatefulWidget {
  final double height;
  final Widget child;
  final double paddingTop;
  final int millisecondsToDismiss;
  ToasterTop({this.height, this.child, this.paddingTop = 20.0, this.millisecondsToDismiss = 1000});
  @override
  _ToasterTopState createState() => _ToasterTopState();
}

class _ToasterTopState extends State<ToasterTop> with TickerProviderStateMixin {

  AnimationController _controller;
  Animation<double> _animation;
  AnimationController _controllerH;
  Animation<double> _animationH;
  double _paddingTop = -100;
  double _dragY = 0.0;
  bool horizontalDismiss = false;

  @override
  void initState(){
    super.initState();
    _controllerH = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animationH = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(
        parent: _controllerH,
        curve: Curves.elasticOut
      )
    );

    _animationH.addListener(() {
      if(_controllerH.status == AnimationStatus.completed){
        if(_dragY > 50)
          _dragY = MediaQuery.of(context).size.width;
        else
          _dragY = -MediaQuery.of(context).size.width;
      }
      else if(_controllerH.status != AnimationStatus.dismissed){
        _dragY = _animationH.value;
      }
      // else if(_controllerH.status == AnimationStatus.dismissed){
      //   _paddingTop = widget.height * -1;
      // }
      setState(() {});
    });

    _paddingTop = widget.height * -1;
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animation = Tween<double>(begin: _paddingTop, end: widget.paddingTop).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut
      )
    );

    _animation.addListener(() {
      if(_controller.status == AnimationStatus.completed){
        _paddingTop = widget.paddingTop;
        _dismiss();
      }
      else if(_controller.status != AnimationStatus.dismissed){
        _paddingTop = _animation.value;
      }
      else if(_controller.status == AnimationStatus.dismissed){
        _paddingTop = widget.height * -1;
      }
      setState(() {});
    });
    _controller.forward();
  }

  @override
  void dispose(){
    _controller.dispose();
    _controllerH.dispose();
    super.dispose();
  }

  _initHorizontalAnimation(){
    var width = MediaQuery.of(context).size.width + _dragY;
    _animationH = Tween<double>(begin: _dragY, end: _dragY < 0 ? -width : width).animate(
      CurvedAnimation(
        parent: _controllerH,
        curve: Curves.linear
      )
    );
    horizontalDismiss = true;
    _controllerH.forward();
  }

  _dismiss()async{
    await Future.delayed(Duration(milliseconds: widget.millisecondsToDismiss), (){});
    if(_controller.status == AnimationStatus.completed && horizontalDismiss == false){
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _paddingTop,
      left: _dragY,
      child: GestureDetector(
        onHorizontalDragUpdate: (DragUpdateDetails d){
          setState(() {
            _dragY += d.primaryDelta;
          });
        },
        onHorizontalDragEnd: (DragEndDetails d){
          if(_dragY <= -40 || _dragY >= 40){
            _initHorizontalAnimation();  
          }
          else{
            setState(() {
              _dragY = 0;
            });
          }
        },
        child: widget.child,
      )
    );
  }
}