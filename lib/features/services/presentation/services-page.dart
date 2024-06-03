import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
class ServicesPage extends ConsumerStatefulWidget {
  const ServicesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ServicesPageState();
}

class _ServicesPageState extends ConsumerState<ServicesPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            
          ],
        ),
      ),
    );
  }
}