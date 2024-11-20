import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/extensions/navigator-extension.dart';
import 'package:troco/features/chat/presentation/widgets/leave-group-item.dart';

import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/button/presentation/widget/button.dart';
import '../../../../core/components/others/drag-handle.dart';
import '../../../../core/components/others/spacer.dart';
import '../../../groups/domain/entities/group.dart';

class LeaveGroupSheet extends ConsumerStatefulWidget {
  final Group group;
  const LeaveGroupSheet({super.key, required this.group});

  @override
  ConsumerState createState() => _LeaveGroupSheetState();

  static Future<bool?> bottomSheet(
      {required BuildContext context, required Group group}) {
    return showModalBottomSheet<bool?>(
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: ColorManager.background,
      context: context,
      builder: (context) => LeaveGroupSheet(group: group),
    );
  }
}

class _LeaveGroupSheetState extends ConsumerState<LeaveGroupSheet> {
  bool loading = false;
  final buttonKey = UniqueKey();
  bool removeBuyer = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
      decoration: BoxDecoration(
          color: ColorManager.background,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SizeManager.extralarge))),
      child: SingleChildScrollView(
        child: Column(
          children: [
            extraLargeSpacer(),
            const DragHandle(),
            largeSpacer(),
            title(),
            mediumSpacer(),
            Divider(
              thickness: 1,
              color: ColorManager.secondary.withOpacity(0.08),
            ),
            mediumSpacer(),
            LeaveGroupItem(
                selected: removeBuyer,
                onChecked: () => setState(() => removeBuyer = true),
                label: "Buyer",
                profile: widget.group.buyer!.profile,
                description: "Remove Buyer from this order"),
            mediumSpacer(),
            LeaveGroupItem(
                selected: !removeBuyer,
                onChecked: () => setState(() => removeBuyer = false),
                label: "Yourself",
                profile: widget.group.seller.profile,
                description: "Remove yourself while deleting the order."),
            extraLargeSpacer(),
            button(),
            extraLargeSpacer()
          ],
        ),
      ),
    );
  }

  Widget title() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(vertical: SizeManager.small),
          alignment: Alignment.center,
          child: Text(
            "Remove",
            style: TextStyle(
                color: ColorManager.primary,
                fontWeight: FontWeightManager.bold,
                fontFamily: "Lato",
                fontSize: FontSizeManager.large * 0.9),
          ),
        ),
        Positioned(
          width: SizeManager.extralarge * 1.1,
          height: SizeManager.extralarge * 1.1,
          right: SizeManager.regular,
          child: IconButton(
              onPressed: () => loading ? null : Navigator.pop(context),
              style: ButtonStyle(
                  shape: const MaterialStatePropertyAll(CircleBorder()),
                  backgroundColor: MaterialStatePropertyAll(
                      ColorManager.accentColor.withOpacity(0.2))),
              icon: Icon(
                Icons.close_rounded,
                color: ColorManager.accentColor,
                size: IconSizeManager.small,
              )),
        )
      ],
    );
  }

  Widget button() {
    return CustomButton(
        buttonKey: buttonKey,
        usesProvider: true,
        onPressed: () async {
          ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
          await Future.delayed(const Duration(seconds: 2));
          ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
          context.pop(result: removeBuyer);
        },
        label: "Select");
  }
}
