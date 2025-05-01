import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/app/theme-manager.dart';

class ViewReceiptScreen extends ConsumerStatefulWidget {
  final String receiptPath;
  const ViewReceiptScreen({super.key, required this.receiptPath});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ViewReceiptScreenState();
}

class _ViewReceiptScreenState extends ConsumerState<ViewReceiptScreen> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: ThemeManager.getSystemUiOverlayStyle(),
      child: Scaffold(
        backgroundColor: ColorManager.background,
        body: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
          child: Column(
            children: [],
          ),
        ),
      ),
    );
  }
}
