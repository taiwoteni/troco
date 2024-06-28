import 'package:flutter/material.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/features/groups/presentation/groups_page/widgets/empty-screen.dart';
import 'package:troco/features/payments/data/sources/all-available-banks.dart';

import '../../../../../core/app/font-manager.dart';
import '../../../../../core/components/others/drag-handle.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../../core/app/asset-manager.dart';
import '../../../../core/components/images/svg.dart';
import '../../domain/entity/bank.dart';

class SearchBankSheet extends StatefulWidget {
  const SearchBankSheet({super.key});

  @override
  State<SearchBankSheet> createState() => _SearchBankSheetState();
}

class _SearchBankSheetState extends State<SearchBankSheet> {
  late TextEditingController searchController;
  late List<Bank> allBanks, searchedBanks;
  bool loading = false;

  @override
  void initState() {
    searchController = TextEditingController();
    allBanks = [];
    searchedBanks = [];
    getAvailableBanks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      decoration: BoxDecoration(
          color: ColorManager.background,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SizeManager.large))),
      child: Column(
        children: [
          extraLargeSpacer(),
          const DragHandle(),
          largeSpacer(),
          title(),
          searchBar(),
          Divider(
            thickness: 1,
            color: ColorManager.secondary.withOpacity(0.08),
          ),
          banksList()
        ],
      ),
    );
  }

  Future<void> getAvailableBanks() async {
    // This method is called in initState before the super.initState()
    // is called, so no need to use setState
    loading = true;

    final banks = await allAvailableBanks();
    setState(() {
      loading = false;
    });

    setState(() {
      allBanks = banks;
      searchedBanks = banks;
    });
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
            "Select Bank",
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
              onPressed: () => Navigator.pop(context),
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

  Widget banksList() {
    if (searchedBanks.isNotEmpty) {
      return Expanded(
        child: ListView.separated(
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) =>
                bankItem(bank: searchedBanks[index]),
            separatorBuilder: (context, index) => Divider(
                  color: ColorManager.secondary.withOpacity(0.08),
                ),
            itemCount: searchedBanks.length),
      );
    }

    return EmptyScreen(
        expanded: true,
        label: allBanks.isEmpty
            ? "Getting available banks"
            : "Couldn't find '${searchController.text}'");
  }

  Widget bankItem({required final Bank bank}) {
    return ListTile(
      onTap: () {
        Navigator.pop(context, bank);
      },
      dense: true,
      leading: Container(
        width: 43,
        height: 43,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorManager.accentColor.withOpacity(0.1)),
        child: SvgIcon(
          svgRes: AssetManager.svgFile(name: "bank"),
          fit: BoxFit.cover,
          color: ColorManager.themeColor,
          size: const Size.square(IconSizeManager.regular * 0.8),
        ),
      ),
      title: Text(bank.name),
      titleTextStyle: TextStyle(
          fontFamily: 'Lato',
          color: ColorManager.primary,
          fontSize: FontSizeManager.regular,
          fontWeight: FontWeightManager.medium),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: SizeManager.regular * 0.8),
      tileColor: Colors.transparent,
    );
  }

  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: SizeManager.medium),
      child: TextFormField(
        controller: searchController,
        maxLines: 1,
        onChanged: (value) {
          final _banks = allBanks
              .where((element) => element.name
                  .toLowerCase()
                  .trim()
                  .contains(value.toLowerCase().trim()))
              .toList();
          if (value.trim().isEmpty) {
            setState(() {
              searchedBanks = allBanks;
            });
          } else {
            setState(() {
              searchedBanks = _banks;
            });
          }
        },
        cursorColor: ColorManager.themeColor,
        cursorRadius: const Radius.circular(SizeManager.medium),
        style: defaultStyle(),
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
                vertical: SizeManager.medium, horizontal: SizeManager.medium),
            isDense: true,
            hintText: "Search Bank",
            floatingLabelBehavior: FloatingLabelBehavior.never,
            hintStyle: defaultStyle().copyWith(color: ColorManager.secondary),
            fillColor: ColorManager.tertiary,
            filled: true,
            border: defaultBorder(),
            enabledBorder: defaultBorder(),
            errorBorder: defaultBorder(),
            focusedBorder: defaultBorder(),
            disabledBorder: defaultBorder(),
            focusedErrorBorder: defaultBorder()),
      ),
    );
  }

  TextStyle defaultStyle() {
    return TextStyle(
        color: ColorManager.primary,
        fontSize: FontSizeManager.regular,
        fontWeight: FontWeightManager.medium,
        fontFamily: 'Lato');
  }

  InputBorder defaultBorder() {
    return OutlineInputBorder(
        borderSide:
            BorderSide(color: ColorManager.themeColor, style: BorderStyle.none),
        borderRadius: BorderRadius.circular(SizeManager.large));
  }
}
