import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/basecomponents/others/spacer.dart';
import 'package:troco/core/basecomponents/texts/inputs/text-form-field.dart';
import 'package:troco/core/basecomponents/texts/outputs/info-text.dart';
import 'package:troco/features/transactions/data/models/create-transaction-data-holder.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/basecomponents/button/presentation/provider/button-provider.dart';
import '../../../../../core/basecomponents/button/presentation/widget/button.dart';
import '../../../utils/enums.dart';
import '../../create-transaction/providers/create-transaction-provider.dart';

class TransactionDescriptionPage extends ConsumerStatefulWidget {
  const TransactionDescriptionPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionDescriptionPageState();
}

class _TransactionDescriptionPageState
    extends ConsumerState<TransactionDescriptionPage> {
  final TextEditingController transactionNameController =
      TextEditingController(text: TransactionDataHolder.transactionName ?? "");
  final TextEditingController aboutProductController =
      TextEditingController(text: TransactionDataHolder.aboutProduct ?? "");
  final TextEditingController dayController = TextEditingController(
      text: TransactionDataHolder.day?.toString().padLeft(2, "0") ?? "");
  final TextEditingController monthController = TextEditingController(
      text: TransactionDataHolder.month?.toString().padLeft(2, "0") ?? "");
  final TextEditingController yearController =
      TextEditingController(text: TransactionDataHolder.year?.toString() ?? "");
  final formKey = GlobalKey<FormState>();
  bool inspectByDay = TransactionDataHolder.inspectionPeriod ?? true;
  int inspectionDay = TransactionDataHolder.inspectionDays ?? 1;

  final buttonKey = UniqueKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorManager.background,
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.only(
              left: SizeManager.large, right: SizeManager.large),
          child: SingleChildScrollView(
              child: Form(
            key: formKey,
            child: Column(children: [
              mediumSpacer(),
              title(),
              largeSpacer(),
              regularSpacer(),
              transactionName(),
              mediumSpacer(),
              regularSpacer(),
              aboutProducts(),
              mediumSpacer(),
              inspectionDays(),
              mediumSpacer(),
              regularSpacer(),
              inspectionPeriod(),
              mediumSpacer(),
              regularSpacer(),
              dateOfWork(),
              extraLargeSpacer(),
              button(),
              largeSpacer(),
            ]),
          )),
        ));
  }

  Widget title() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "Description",
        style: TextStyle(
            fontFamily: "Quicksand",
            fontSize: FontSizeManager.large,
            color: ColorManager.primary,
            fontWeight: FontWeightManager.bold),
      ),
    );
  }

  Widget transactionName() {
    return Column(
      children: [
        InfoText(
          text: " Transaction Name",
          color: ColorManager.secondary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        InputFormField(
          controller: transactionNameController,
          label: 'e.g "iPhone 13 purchase"',
          validator: (value) {
            if (value == null) {
              return "* enter a tranaction name";
            }
            if (value.trim().isEmpty) {
              return "* enter a tranaction name";
            }
            if (value.trim().length <= 8) {
              return "* should be at least 8 digits";
            }
            if (value.trim().length >= 25) {
              return "* less than 25 digits";
            }
            return null;
          },
          onSaved: (value) {
            TransactionDataHolder.transactionName = value;
          },
          prefixIcon: null,
        ),
      ],
    );
  }

  Widget aboutProducts() {
    final TransactionCategory category =
        TransactionDataHolder.transactionCategory ??
            TransactionCategory.Product;
    return Column(
      children: [
        InfoText(
          text:
              " About ${category.name}${category == TransactionCategory.Virtual ? "-Service" : ""}(s)",
          color: ColorManager.secondary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        InputFormField(
          controller: aboutProductController,
          label: "Write about your product(s)",
          lines: 4,
          validator: (value) {
            if (value == null) {
              return "* write about your product(s)";
            }
            if (value.trim().isEmpty) {
              return "* write about your product(s)";
            }
            return null;
          },
          onSaved: (value) {
            TransactionDataHolder.aboutProduct = value;
          },
          prefixIcon: null,
        ),
      ],
    );
  }

  Widget inspectionPeriod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => setState(() => inspectByDay = true),
                child: Container(
                    width: 150,
                    alignment: Alignment.center,
                    height: 50,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: ColorManager.secondary.withOpacity(0.15),
                            width: 1.5),
                        borderRadius:
                            BorderRadius.circular(SizeManager.regular)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          value: inspectByDay,
                          tristate: false,
                          checkColor: Colors.white,
                          activeColor: ColorManager.accentColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2),
                              side: BorderSide(
                                  color: ColorManager.accentColor, width: 1)),
                          onChanged: (value) => null,
                        ),
                        Text(
                          "By Day",
                          style: TextStyle(
                              color: ColorManager.primary,
                              fontFamily: "Lato",
                              fontSize: FontSizeManager.small,
                              fontWeight: FontWeightManager.medium),
                        )
                      ],
                    )),
              ),
              mediumSpacer(),
              InkWell(
                onTap: () => setState(() => inspectByDay = false),
                child: Container(
                    width: 150,
                    alignment: Alignment.center,
                    height: 50,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: ColorManager.secondary.withOpacity(0.15),
                            width: 1.5),
                        borderRadius:
                            BorderRadius.circular(SizeManager.regular)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          value: !inspectByDay,
                          tristate: false,
                          checkColor: Colors.white,
                          activeColor: ColorManager.accentColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2),
                              side: BorderSide(
                                  color: ColorManager.accentColor, width: 1)),
                          onChanged: (value) => null,
                        ),
                        Text(
                          "By Hour",
                          style: TextStyle(
                              color: ColorManager.primary,
                              fontFamily: "Lato",
                              fontSize: FontSizeManager.small,
                              fontWeight: FontWeightManager.medium),
                        )
                      ],
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget inspectionDays() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoText(
          text: " Inspection Period",
          color: ColorManager.secondary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        Container(
          width: 165,
          height: 45,
          decoration: BoxDecoration(
              border: Border.all(
                  color: ColorManager.secondary.withOpacity(0.15), width: 1.5),
              borderRadius: BorderRadius.circular(SizeManager.regular)),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (inspectionDay > 1) {
                      setState(() {
                        inspectionDay -= 1;
                      });
                    }
                  },
                  child: Center(
                    child: Icon(
                      CupertinoIcons.minus_circle_fill,
                      size: IconSizeManager.regular * 1.3,
                      color: ColorManager.accentColor,
                    ),
                  ),
                ),
              ),
              Container(
                height: double.maxFinite,
                width: 2,
                color: ColorManager.secondary.withOpacity(0.15),
              ),
              Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      inspectionDay.toString(),
                      style: TextStyle(
                          fontFamily: "Lato",
                          color: ColorManager.primary,
                          fontWeight: FontWeightManager.extrabold,
                          fontSize: FontSizeManager.medium),
                    ),
                  )),
              Container(
                height: double.maxFinite,
                width: 2,
                color: ColorManager.secondary.withOpacity(0.15),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (inspectionDay < 24) {
                      setState(() {
                        inspectionDay += 1;
                      });
                    }
                  },
                  child: Center(
                    child: Icon(
                      CupertinoIcons.plus_circle_fill,
                      size: IconSizeManager.regular * 1.3,
                      color: ColorManager.accentColor,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget dateOfWork() {
    return Column(
      children: [
        InfoText(
          text: "Sales Day",
          color: ColorManager.secondary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: InputFormField(
                controller: dayController,
                label: 'dd',
                inputType: TextInputType.datetime,
                validator: (value) {
                  if (value == null) {
                    return "* day";
                  }
                  if (value.trim().isEmpty) {
                    return "* day";
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value.trim()) ||
                      int.parse(value.trim()) > 31) {
                    return "* day";
                  }
                  return null;
                },
                onSaved: (value) {
                  TransactionDataHolder.day = int.parse(value!.trim());
                },
                prefixIcon: null,
              ),
            ),
            regularSpacer(),
            Expanded(
              child: InputFormField(
                label: 'MM',
                controller: monthController,
                inputType: TextInputType.datetime,
                validator: (value) {
                  if (value == null) {
                    return "* month";
                  }
                  if (value.trim().isEmpty) {
                    return "* month";
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value.trim()) ||
                      int.parse(value.trim()) > 12) {
                    return "* month";
                  }
                  return null;
                },
                onSaved: (value) {
                  TransactionDataHolder.month = int.parse(value!.trim());
                },
                prefixIcon: null,
              ),
            ),
            regularSpacer(),
            Expanded(
              child: InputFormField(
                label: 'yyyy',
                controller: yearController,
                inputType: TextInputType.datetime,
                validator: (value) {
                  if (value == null) {
                    return "* year";
                  }
                  if (value.trim().isEmpty) {
                    return "* year";
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value.trim()) ||
                      value.trim().length != 4) {
                    return "* year";
                  }
                  if (RegExp(r'^[0-9]+$').hasMatch(value.trim()) &&
                      int.parse(value.trim()) < DateTime.now().year) {
                    return "* year";
                  }
                  return null;
                },
                onSaved: (value) {
                  TransactionDataHolder.year = int.parse(value!.trim());
                },
                prefixIcon: null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget button() {
    return CustomButton.medium(
      label: "Continue",
      usesProvider: true,
      buttonKey: buttonKey,
      onPressed: () async {
        ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
        await Future.delayed(const Duration(seconds: 3));
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          TransactionDataHolder.inspectionPeriod = inspectByDay;
          TransactionDataHolder.inspectionDays = inspectionDay;
          ref.read(createTransactionPageController.notifier).state.nextPage(
              duration: const Duration(milliseconds: 450), curve: Curves.ease);
          ref.read(createTransactionProgressProvider.notifier).state = 2;
        }
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      },
    );
  }
}
