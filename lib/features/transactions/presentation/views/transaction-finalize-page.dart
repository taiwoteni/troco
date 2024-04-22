import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/basecomponents/images/profile-icon.dart';
import 'package:troco/core/basecomponents/others/spacer.dart';

import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../groups/domain/entities/group.dart';

class TransactionFinalizePage extends ConsumerStatefulWidget {
  const TransactionFinalizePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionPreviewPageState();
}

class _TransactionPreviewPageState extends ConsumerState<TransactionFinalizePage> {

  final textStyle = TextStyle(
      color: ColorManager.primary,
      fontFamily: 'quicksand',
      fontSize: FontSizeManager.medium * 1.1,
      fontWeight: FontWeightManager.medium);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.only(
            left: SizeManager.large, right: SizeManager.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            groupProfileIcon(),
            regularSpacer(),
            groupName(),

            
          ],
        ),
      ),
    );
  }

  Widget groupProfileIcon() {
    return const GroupProfileIcon(size: IconSizeManager.extralarge * 1.1,);
  }

  Widget groupName(){
    final group = (ModalRoute.of(context)!.settings.arguments! as Group);
    return Text(
      group.groupName,
      style: textStyle,
    );
  }
}
