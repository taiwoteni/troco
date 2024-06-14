import 'package:flutter/material.dart';

class FadeInUp extends StatefulWidget {
  final Duration duration,delay;
  final double displacement;
  final Widget child;
  const FadeInUp({
    super.key, 
    required this.child, 
    this.displacement = 20.0,
    this.delay = const Duration(milliseconds: 2000),
    this.duration = const Duration(microseconds: 3000)});

  @override
  State<FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<FadeInUp> with SingleTickerProviderStateMixin {

  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.duration);
  
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) async{
      await Future.delayed(widget.delay);
      if(!mounted){
        return;
      }
      controller.forward();
    },);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller, 
      child: widget.child,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.only(bottom: widget.displacement * controller.value),
          child: child,
          );
      },);
  }
}