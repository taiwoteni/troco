// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:troco/core/app/file-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/components/texts/inputs/currency_input_formatter.dart';
import 'package:troco/core/components/texts/inputs/dropdown-input-field.dart';
import 'package:troco/core/extensions/list-extension.dart';
import 'package:troco/core/extensions/string-extension.dart';
import 'package:troco/features/transactions/data/models/create-transaction-data-holder.dart';
import 'package:troco/features/transactions/domain/entities/service.dart';
import 'package:troco/features/transactions/presentation/create-transaction/providers/product-images-provider.dart';
import 'package:troco/features/transactions/utils/enums.dart';
import 'package:troco/features/transactions/utils/month-converter.dart';
import 'package:troco/features/transactions/utils/month-enum.dart';
import 'package:troco/features/transactions/utils/service-requirement-converter.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/cache/shared-preferences.dart';
import '../../../../../core/components/button/presentation/provider/button-provider.dart';
import '../../../../../core/components/button/presentation/widget/button.dart';
import '../../../../../core/components/others/drag-handle.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../../../core/components/texts/inputs/text-form-field.dart';
import '../../../../../core/components/texts/outputs/info-text.dart';
import '../../../../services/domain/entities/escrow-fee.dart';
import '../providers/pricings-notifier.dart';
import '../views/view-added-products-screen.dart';

class AddServiceSheet extends ConsumerStatefulWidget {
  final Service? service;
  const AddServiceSheet({super.key, this.service});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddServiceWidgetState();

  static Future<Service?> bottomSheet(
      {required BuildContext context, Service? service}) {
    return showModalBottomSheet<Service?>(
        isScrollControlled: true,
        enableDrag: true,
        useSafeArea: false,
        backgroundColor: ColorManager.background,
        context: context,
        builder: (context) {
          return AddServiceSheet(
            service: service,
          );
        });
  }
}

class _AddServiceWidgetState extends ConsumerState<AddServiceSheet> {
  late NumberFormat currencyFormatter;
  ServiceRequirement? selectedRequirement;
  Month? selectedMonth;
  int? selectedYear;
  int? selectedDay;
  int quantity = 1;
  String? timeError;
  bool productImageError = false;
  final buttonKey = UniqueKey();
  final secondKey = UniqueKey();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  String price = "";
  String name = "";
  String description = "";

  @override
  void setState(VoidCallback fn) {
    if (!mounted) {
      return;
    }
    super.setState(fn);
  }

  @override
  void initState() {
    currencyFormatter = NumberFormat.currency(
      locale: 'en_NG',
      decimalDigits: 0,
      symbol: "",
    );
    selectedDay = widget.service?.deadlineTime.day;
    selectedYear = widget.service?.deadlineTime.year;
    if (widget.service != null) {
      selectedMonth = Month.values[widget.service!.deadlineTime.month - 1];
      selectedRequirement = widget.service!.serviceRequirement;
    }

    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      if (widget.service != null) {
        ref.read(pricingsImagesProvider.notifier).state =
            widget.service!.images;
        return;
      }
      ref.read(pricingsImagesProvider.notifier).state.clear();
      setState(
        () {},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
      decoration: BoxDecoration(
        color: ColorManager.background,
      ),
      child: Form(
        key: formKey,
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
              serviceName(),
              mediumSpacer(),
              regularSpacer(),
              serviceRequirements(),
              mediumSpacer(),
              regularSpacer(),
              serviceDescription(),
              mediumSpacer(),
              regularSpacer(),
              servicePrice(),
              mediumSpacer(),
              regularSpacer(),
              deadlinePeriod(),
              regularSpacer(),
              if (timeError != null)
                InfoText(color: Colors.red, text: timeError!),
              regularSpacer(),
              regularSpacer(),
              uploadPicture(),
              largeSpacer(),
              button(),
            ],
          ),
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
            "Add Task",
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
              onPressed: () {
                if (loading) {
                  return;
                }
              },
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

  Widget serviceName() {
    return Column(
      children: [
        InfoText(
          text: "Task Name",
          color: ColorManager.primary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        InputFormField(
          initialValue: widget.service?.name,
          label: 'Name of the task',
          validator: (value) {
            if (value == null) {
              return "* enter a task name";
            }
            if (value.trim().isEmpty) {
              return "* enter a task name";
            }
            return null;
          },
          onSaved: (value) {
            setState(() => name = value?.toString() ?? "");
          },
          prefixIcon: null,
        ),
      ],
    );
  }

  Widget serviceDescription() {
    return Column(
      children: [
        InfoText(
          text: "Term of Task (description)",
          color: ColorManager.primary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        InputFormField(
          initialValue: widget.service?.description,
          label: 'i.e the terms and description of this task.',
          lines: 3,
          validator: (value) {
            if (value == null) {
              return "* enter task term";
            }
            if (value.trim().isEmpty) {
              return "* enter task term";
            }
            return null;
          },
          onSaved: (value) {
            setState(() => description = value?.toString() ?? "");
          },
          prefixIcon: null,
        ),
      ],
    );
  }

  Widget serviceRequirements() {
    return Column(
      children: [
        InfoText(
          text: "Task Requirement",
          color: ColorManager.primary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        DropdownInputFormField(
          items: ServiceRequirement.values.map((e) => e.name).toList(),
          value: selectedRequirement == null ? "" : selectedRequirement!.name,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedRequirement =
                    ServiceRequirementsConverter.convertToEnum(
                        requirement: value);
              });
            }
          },
          hint: 'e.g "Design"',
          onValidate: (value) {
            if (value == null) {
              return "* select task requirement";
            }
            if (value.trim().isEmpty) {
              return "* select task requirement";
            }
            return null;
          },
          prefixIcon: null,
        ),
      ],
    );
  }

  Widget deadlinePeriod() {
    return Column(
      children: [
        InfoText(
          text: "Task Deadline",
          color: ColorManager.primary,
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

  DateTime? taskDeadline() {
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

  /// [validDate] validates if the deadline doesn't exceed the transaction duration
  /// ... and it isn't before the deadline of the previous task.
  /// If these aren't met, it updates the [timeError] to the respective error
  bool validDate() {
    /// We're checking for 3 Things Here that makes it invalid.
    /// 1. If the deadline time exceeds the transaction duration
    /// 2. If the deadline time is before the current time
    /// 2. If the deadline time is before the deadline of the previous task.

    final transactionDeadlineTime =
        TransactionDataHolder.inspectionPeriodToDateTime()!;

    final taskDeadlineTime = taskDeadline();
    if (taskDeadlineTime == null) {
      setState(() => timeError = "* task Deadline not set");
      return false;
    }
    debugPrint(TransactionDataHolder.inspectionDays?.toString());
    debugPrint(TransactionDataHolder.inspectionPeriod?.name);
    debugPrint(taskDeadlineTime.toIso8601String());
    debugPrint(transactionDeadlineTime.toIso8601String());

    /// Check 1
    if (taskDeadlineTime.isAfter(transactionDeadlineTime)) {
      setState(
          () => timeError = "* set deadline exceeds the transaction duration");
      return false;
    }

    /// Check 2
    if (taskDeadlineTime
        .copyWith(hour: 23, minute: 59, second: 59)
        .isBefore(DateTime.now())) {
      // We are intentionally setting the taskDeadlineTime to 23 simply because
      // we don't wont it to be exact is the current time in terms of hours minutes and seconds
      setState(() => timeError = "* set deadline time is a past time");
      return false;
    }

    /// Check 3
    // If it isn't the first item to be added;
    if ((TransactionDataHolder.items ?? []).isNotEmpty) {
      final previousService = TransactionDataHolder.items!.last as Service;
      if (previousService.deadlineTime.isAfter(taskDeadlineTime)) {
        setState(() => timeError =
            "* set deadline is before the deadline of a previous task");
        return false;
      }
    }

    setState(() => timeError = null);
    return true;
  }

  Widget servicePrice() {
    return Column(
      children: [
        InfoText(
          text: " Cost of Task",
          color: ColorManager.primary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        InputFormField(
          initialValue: widget.service?.price.toInt().format(currencyFormatter),
          label: 'NGN',
          inputType: TextInputType.phone,
          inputFormatters: [CurrencyInputFormatter()],
          validator: (value) {
            if (value == null) {
              return "* enter price";
            }
            if (value.trim().isEmpty) {
              return "* enter price";
            }
            if (!RegExp(r'^\d+(\.\d+)?$')
                .hasMatch(value.replaceAll(RegExp(r','), "").trim())) {
              return "* enter valid price";
            }
            return null;
          },
          onSaved: (value) {
            setState(() => price = value?.toString().replaceAll(",", "") ?? "");
          },
          prefixIcon: null,
        ),
      ],
    );
  }

  Widget serviceQuantity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoText(
          text: " Quantity",
          color: ColorManager.primary,
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
                    if (quantity > 1) {
                      setState(() {
                        quantity -= 1;
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
                      quantity.toString(),
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
                    setState(() {
                      quantity += 1;
                    });
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

  Widget uploadPicture() {
    return Column(
      children: [
        InfoText(
          text: " Upload Picture",
          color: ColorManager.primary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        InfoText(
          text: " (Each image should be clear and have a max size of 2MB)",
          color: productImageError ? Colors.redAccent : ColorManager.secondary,
          fontSize: FontSizeManager.regular * 0.8,
          fontWeight: FontWeightManager.regular,
        ),
        largeSpacer(),
        SizedBox(
          width: double.maxFinite,
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (ref.watch(pricingsImagesProvider).isEmpty)
                pickServiceImage()
              else
                serviceImage(position: 0),
              if (ref.watch(pricingsImagesProvider).length < 2)
                pickServiceImage()
              else
                serviceImage(position: 1),
              if (ref.watch(pricingsImagesProvider).length < 3)
                pickServiceImage()
              else
                serviceImage(position: 2)
            ],
          ),
        ),
      ],
    );
  }

  Widget button() {
    final isEditing = widget.service?.isEditing() == true;
    return CustomButton.medium(
      label: widget.service != null ? "Edit Service" : "Add Service",
      usesProvider: true,
      buttonKey: buttonKey,
      color: ColorManager.themeColor,
      onPressed: () async {
        ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
        setState(() {
          loading = true;
        });
        await Future.delayed(const Duration(seconds: 2));
        // setState(() {
        //   productImageError = ref.read(productImagesProvider).isEmpty;
        // });
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();

          if (!validDate()) {
            setState(() {
              loading = false;
            });
            ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
            return;
          }
          const defaultCharge = EscrowCharge.fromJson(
              json: {"category": "service", "percentage": 10});
          final serviceCharge = AppStorage.getEscrowCharges().firstWhere(
            (charge) => charge.category == TransactionCategory.Service,
            orElse: () => defaultCharge,
          );
          final escrowCharge =
              (double.parse(price) * (serviceCharge.percentage));

          final productImages =
              List<String>.from(ref.read(pricingsImagesProvider))
                  .copy()
                  .toListString();
          final DateTime dateTime = DateTime(
              selectedYear!, selectedMonth!.toMonthOfYear(), selectedDay!);
          Map<dynamic, dynamic> serviceJson = {
            "serviceId": isEditing
                ? widget.service!.id
                : (ref.read(pricingsProvider).length + 1).toString(),
            "serviceName": name,
            "description": description,
            "servicePrice": double.parse(price),
            "serviceRequirement": selectedRequirement!.name,
            "deadlineTime": taskDeadline()!.toIso8601String(),
            "escrowPercentage": (serviceCharge.percentage * 100),
            "escrowCharges": escrowCharge,
            "finalPrice": double.parse(price) + escrowCharge,
            "quantity": quantity,
          };

          if (productImages.isNotEmpty) {
            serviceJson["pricingImage"] = productImages.copy().toListString();
          }
          if (mounted) {
            Navigator.pop(context, Service.fromJson(json: serviceJson));
          }
        } else {
          setState(() {
            loading = false;
          });
        }
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      },
    );
  }

  Widget pickServiceImage() {
    return InkWell(
      onTap: () async {
        final pickedFile =
            await FileManager.pickImage(imageSource: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            ref
                .read(pricingsImagesProvider.notifier)
                .state
                .add(pickedFile.path);
          });
        }
      },
      highlightColor: ColorManager.accentColor.withOpacity(0.3),
      customBorder: const CircleBorder(),
      child: Container(
        width: 70,
        height: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ColorManager.accentColor.withOpacity(0.2),
        ),
        child: Icon(
          CupertinoIcons.add,
          color: ColorManager.accentColor,
          size: IconSizeManager.medium,
        ),
      ),
    );
  }

  Widget serviceImage({required final int position}) {
    return OpenContainer(
      closedElevation: 0,
      tappable: !loading,
      transitionDuration: const Duration(milliseconds: 500),
      middleColor: ColorManager.background,
      onClosed: (data) {
        SystemChrome.setSystemUIOverlayStyle(
            ThemeManager.getTransactionScreenUiOverlayStyle());
        setState(
          () {},
        );
      },
      closedBuilder: (context, action) {
        final image =
            ref.watch(pricingsImagesProvider).elementAtOrNull(position);
        return image == null
            ? pickServiceImage()
            : Container(
                width: 70,
                height: 80,
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(SizeManager.regular * 1.3),
                    image: DecorationImage(
                        image: image.startsWith('http')
                            ? CachedNetworkImageProvider(image)
                            : FileImage(File(image)),
                        fit: BoxFit.cover)),
              );
      },
      openBuilder: (context, action) {
        return ViewAddedItemsScreen(
          currentPosition: position,
          itemId: widget.service?.id,
        );
      },
    );
  }
}
