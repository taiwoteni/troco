import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/theme-manager.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(ThemeManager.getSettingsUiOverlayStyle());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      appBar: appBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [

          ],
        ),
      ),


    );
  }

  PreferredSizeWidget appBar(){
    return AppBar(
      centerTitle: true,
      forceMaterialTransparency: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      systemOverlayStyle: ThemeManager.getSettingsUiOverlayStyle(),
      backgroundColor: ColorManager.background,
      title:const Text("Settings"),
      titleTextStyle: TextStyle(
        fontFamily: 'Lato',
        color: ColorManager.primary,
        fontWeight: FontWeightManager.semibold,
        fontSize: FontSizeManager.medium,
      ),
      
    );
  }
}