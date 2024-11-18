import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/core/components/texts/inputs/currency_input_formatter.dart';
import 'package:troco/core/components/texts/inputs/text-form-field.dart';
import 'package:troco/core/components/texts/outputs/info-text.dart';
import 'package:troco/core/extensions/string-extension.dart';
import 'package:troco/features/transactions/data/models/create-transaction-data-holder.dart';
import 'package:troco/features/transactions/presentation/create-transaction/providers/transaction-controller-provider.dart';
import 'package:troco/features/transactions/utils/date-input-formatter.dart';
import 'package:troco/features/transactions/utils/date-verification-validation.dart';
import 'package:troco/features/transactions/utils/month-converter.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/button/presentation/provider/button-provider.dart';
import '../../../../../core/components/button/presentation/widget/button.dart';
import '../../../../../core/components/texts/inputs/dropdown-input-field.dart';
import '../../../utils/enums.dart';
import '../../../utils/month-enum.dart';
import '../../create-transaction/providers/create-transaction-provider.dart';

class TransactionDescriptionPage extends ConsumerStatefulWidget {
  const TransactionDescriptionPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionDescriptionPageState();
}

class _TransactionDescriptionPageState
    extends ConsumerState<TransactionDescriptionPage> {
  late NumberFormat currencyFormatter;
  Month? selectedMonth;
  int? selectedYear;
  int? selectedDay;
  bool timeError = false;
  final formKey = GlobalKey<FormState>();
  InspectionPeriod? selectedInspectionPeriod;
  int inspectionDay = TransactionDataHolder.inspectionDays ?? 1;
  final buttonKey = UniqueKey();

  @override
  void initState() {
    currencyFormatter = NumberFormat.currency(
      locale: 'en_NG',
      decimalDigits: 0,
      symbol: "",
    );
    inspectionDay = TransactionDataHolder.inspectionDays ?? 0;
    selectedInspectionPeriod = TransactionDataHolder.inspectionPeriod;

    final transactionHolderDate = TransactionDataHolder.date;
    if (transactionHolderDate != null) {
      final date = DateFormat('dd/MM/yyyy').parse(transactionHolderDate);
      selectedDay = date.day;
      selectedMonth = Month.values[date.month - 1];
      selectedYear = date.year;
    }
    super.initState();
  }

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
              inspectionTime(),
              mediumSpacer(),
              regularSpacer(),
              if (TransactionDataHolder.transactionCategory ==
                  TransactionCategory.Service) ...[largeSpacer(), totalCost()],
              if (TransactionDataHolder.transactionCategory !=
                  TransactionCategory.Service) ...[
                largeSpacer(),
                dateOfWork(),
                regularSpacer(),
                if (timeError)
                  const InfoText(
                      color: Colors.red,
                      text: " * Time must be on or after today"),
              ],
              regularSpacer(),
              largeSpacer(),
              transactionLocation(),
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
    final isService = TransactionDataHolder.transactionCategory ==
        TransactionCategory.Service;
    final isVirtual = TransactionDataHolder.transactionCategory ==
        TransactionCategory.Virtual;
    return Column(
      children: [
        InfoText(
          text:
              " The name of the ${isService ? "Project" : "${TransactionDataHolder.transactionCategory!.name} transaction"}",
          color: ColorManager.secondary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        InputFormField(
          initialValue: TransactionDataHolder.transactionName,
          label: isService
              ? "The name of the project/service"
              : isVirtual
                  ? 'e.g Wordpress website sale'
                  : 'e.g "iPhone 13 purchase"',
          validator: (value) {
            if (value == null) {
              return "* enter a tranaction name";
            }
            if (value.trim().isEmpty) {
              return "* enter a tranaction name";
            }
            if (value.trim().length >= 30) {
              return "* less than 30 digits";
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
    final isService = TransactionDataHolder.transactionCategory ==
        TransactionCategory.Service;
    final isVirtual = TransactionDataHolder.transactionCategory ==
        TransactionCategory.Virtual;

    final TransactionCategory category =
        TransactionDataHolder.transactionCategory ??
            TransactionCategory.Product;
    return Column(
      children: [
        InfoText(
          text: isService
              ? " Provide the terms and conditions"
              : " Description of the ${category.name}${category == TransactionCategory.Virtual ? "-Product" : ""}(s)",
          color: ColorManager.secondary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        InputFormField(
          initialValue: TransactionDataHolder.aboutProduct,
          label: isService
              ? "Enter terms of Service (e.g We agreed that I will receive service completed on the 5th day.....)"
              : 'Write about your ${category.name.toLowerCase()}${category == TransactionCategory.Virtual ? "-product" : ""}(s). Try to keep it brief and informative as much as possible.',
          lines: 4,
          validator: (value) {
            if (value == null) {
              return isService
                  ? "* write the terms and conditions"
                  : "* write about your product(s)";
            }
            if (value.trim().isEmpty) {
              return "* write the terms and conditions";
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

  Widget inspectionTime() {
    final isService = TransactionDataHolder.transactionCategory ==
        TransactionCategory.Service;

    return Column(
      children: [
        InfoText(
          text: isService ? " Transaction Duration" : " Inspection Period",
          color: ColorManager.secondary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        Row(
          children: [inspectionDays(), inspectionPeriod()],
        )
      ],
    );
  }

  Widget inspectionPeriod() {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SizeManager.regular),
        child: DropdownInputFormField(
          items: InspectionPeriod.values.map((e) => e.name).toList(),
          value: selectedInspectionPeriod?.name ?? "",
          onChanged: (value) {
            if (value != null) {
              final index = InspectionPeriod.values
                  .map(
                    (e) => e.name.toLowerCase(),
                  )
                  .toList()
                  .indexOf(value.toLowerCase());
              setState(() {
                selectedInspectionPeriod = InspectionPeriod.values[index];
              });
            }
          },
          hint: 'period',
          onValidate: (value) {
            if (value == null) {
              return "* period";
            }
            if (value.trim().isEmpty) {
              return "* period";
            }
            return null;
          },
          prefixIcon: null,
        ),
      ),
    );
  }

  Widget inspectionDays() {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SizeManager.regular),
        child: InputFormField(
          initialValue: selectedDay?.toString(),
          label: 'No. of ${selectedInspectionPeriod?.name ?? "Days"}',
          inputType: TextInputType.number,
          validator: (value) {
            if (value == null) {
              return "* day";
            }
            if (value.trim().isEmpty) {
              return "* day";
            }
            if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
              return "* valid vay";
            }
            return null;
          },
          onSaved: (value) {
            setState(() => inspectionDay = int.parse(value?.trim() ?? "0"));
          },
          prefixIcon: null,
        ),
      ),
    );
  }

  Widget transactionLocation() {
    return Column(
      children: [
        InfoText(
          text: " Location",
          color: ColorManager.secondary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        InputFormField(
          initialValue: TransactionDataHolder.location,
          label: 'Location',
          validator: (value) {
            if (value == null) {
              return "* enter a location";
            }
            if (value.trim().isEmpty) {
              return "* enter a location";
            }
            return null;
          },
          onSaved: (value) {
            TransactionDataHolder.location = value;
          },
          prefixIcon: null,
        ),
      ],
    );
  }

  Widget dayInput() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SizeManager.regular),
        child: InputFormField(
          initialValue: selectedDay?.toString(),
          label: 'day',
          inputType: TextInputType.phone,
          validator: (value) {
            if (value == null) {
              return "* day";
            }
            if (value.trim().isEmpty) {
              return "* day";
            }
            if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
              return "* day";
            }
            if (!validDay(value)) {
              return "* valid day";
            }
            return null;
          },
          onSaved: (value) {
            setState(() => selectedDay = int.parse(value?.trim() ?? "0"));
          },
          prefixIcon: null,
        ),
      ),
    );
  }

  Widget yearInput() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SizeManager.regular),
        child: DropdownInputFormField(
          items: [
            DateTime.now().year.toString(),
            (DateTime.now().year + 1).toString()
          ],
          value: selectedYear?.toString() ?? "",
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedYear = int.parse(value);
              });
            }
          },
          hint: 'year',
          onValidate: (value) {
            if (value == null) {
              return "* year";
            }
            if (value.trim().isEmpty) {
              return "* year";
            }
            return null;
          },
          prefixIcon: null,
        ),
      ),
    );
  }

  Widget monthDropdown() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SizeManager.regular),
        child: DropdownInputFormField(
          items: Month.values.map((e) => e.name).toList(),
          value: selectedMonth?.name ?? "",
          onChanged: (value) {
            if (value != null) {
              final index = Month.values
                  .map(
                    (e) => e.name.toLowerCase(),
                  )
                  .toList()
                  .indexOf(value.toLowerCase());
              setState(() {
                selectedMonth = Month.values[index];
              });
            }
          },
          hint: 'month',
          onValidate: (value) {
            if (value == null) {
              return "* month";
            }
            if (value.trim().isEmpty) {
              return "* month";
            }
            return null;
          },
          prefixIcon: null,
        ),
      ),
    );
  }

  bool validDay(String value) {
    final selectedDay = int.parse(value);
    if (selectedDay == 0 || selectedDay > 31) {
      return false;
    }
    final monthsWith30Days = <Month>[
      Month.Sep,
      Month.Apr,
      Month.Jun,
      Month.Nov
    ];

    bool februaryValid = selectedYear != null &&
        (selectedMonth == Month.Feb
            ? (selectedYear! % 4 == 0
                ? (selectedDay ?? 0) <= 29
                : (selectedDay ?? 0) <= 28)
            : true);

    return selectedMonth != null &&
        februaryValid &&
        (selectedDay == 31 ? !monthsWith30Days.contains(selectedMonth!) : true);
  }

  bool validMonth(Month value) {
    final now = DateTime.now();
    final isThisYear = now.year == selectedYear;
    final isMonthOk = value.toMonthOfYear() <= now.month;

    return isThisYear ? isMonthOk : true;
  }

  bool validDate() {
    if (selectedYear == null || selectedDay == null || selectedYear == null) {
      return false;
    }

    final dateString =
        "$selectedDay/${selectedMonth!.toMonthOfYear()}/$selectedYear";

    final parsedTime = DateFormat("dd/MM/yyyy").parse(dateString);

    final difference = parsedTime.difference(DateTime.now());

    final isValidDate = !difference.isNegative || difference.inDays > -1;

    setState(() => timeError = !isValidDate);
    return isValidDate;
  }

  DateTime? estimatedEnd() {
    if (selectedDay == null) {
      return null;
    }
    if (selectedMonth == null) {
      return null;
    }
    if (selectedYear == null) {
      return null;
    }
    final now = DateTime.now();
    final time = now.copyWith(
        day: selectedDay,
        year: selectedYear,
        month: selectedMonth?.toMonthOfYear());

    return time;
  }

  Widget totalCost() {
    return Column(
      children: [
        InfoText(
          text: " Exact Cost of Project",
          color: ColorManager.secondary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        InputFormField(
          initialValue: TransactionDataHolder.totalCost
              ?.toInt()
              .format(currencyFormatter),
          label: 'The Total Cost of the Project',
          inputType: TextInputType.phone,
          inputFormatters: [CurrencyInputFormatter()],
          validator: (value) {
            if (value == null) {
              return "* enter cost";
            }
            if (value.trim().isEmpty) {
              return "* enter cost";
            }
            if (!RegExp(r'^\d+(\.\d+)?$')
                .hasMatch(value.replaceAll(RegExp(r','), "").trim())) {
              return "* enter valid cost";
            }
            return null;
          },
          onSaved: (value) => TransactionDataHolder.totalCost =
              double.parse(value!.replaceAll(",", "").trim()),
          prefixIcon: null,
        ),
      ],
    );
  }

  Widget dateOfWork() {
    return Column(
      children: [
        InfoText(
          text: "Estimated end",
          color: ColorManager.secondary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        Row(
          children: [
            dayInput(),
            monthDropdown(),
            yearInput(),
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
          if (!validDate() &&
              TransactionDataHolder.transactionCategory !=
                  TransactionCategory.Service) {
            ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
            return;
          }
          TransactionDataHolder.inspectionPeriod = selectedInspectionPeriod;
          TransactionDataHolder.inspectionDays = inspectionDay;
          if (TransactionDataHolder.transactionCategory !=
              TransactionCategory.Service) {
            TransactionDataHolder.date =
                "$selectedDay/${selectedMonth!.toMonthOfYear()}/$selectedYear";
          }

          ref
              .read(transactionPageController.notifier)
              .moveNext(nextPageIndex: 2);
        }
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      },
    );
  }
}
