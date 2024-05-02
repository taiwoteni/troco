import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/size-manager.dart';

import '../../../../../core/app/font-manager.dart';
import '../../../../../core/components/others/drag-handle.dart';
import '../../../../../core/components/others/spacer.dart';

class SearchPlaceScreen extends StatefulWidget {
  final List<String> places;
  final String mode;
  const SearchPlaceScreen(
      {super.key, required this.places, required this.mode});

  @override
  State<SearchPlaceScreen> createState() => _SearchPlaceScreenState();
}

class _SearchPlaceScreenState extends State<SearchPlaceScreen> {
  late TextEditingController searchController;
  List<String> places = [];

  @override
  void initState() {
    searchController = TextEditingController();
    places = widget.places;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      padding: const EdgeInsets.only(top: SizeManager.large),
      decoration: BoxDecoration(
        color: ColorManager.background,
        // borderRadius: const BorderRadius.vertical(
        //     top: Radius.circular(SizeManager.large))
      ),
      child: Column(
        children: [
          const DragHandle(),
          largeSpacer(),
          searchBar(),
          Divider(
            thickness: 1,
            color: ColorManager.secondary.withOpacity(0.08),
          ),
          Expanded(
            child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) =>
                    placeItem(place: places[index]),
                separatorBuilder: (context, index) => Divider(
                      color: ColorManager.secondary.withOpacity(0.08),
                    ),
                itemCount: places.length),
          )
        ],
      ),
    );
  }

  Widget placeItem({required final String place}) {
    return ListTile(
      onTap: () {
        Navigator.pop(context, place);
      },
      dense: true,
      leading: Container(
        width: 43,
        height: 43,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorManager.accentColor.withOpacity(0.1)),
        child: Icon(
          Icons.location_city_rounded,
          size: IconSizeManager.regular * 0.8,
          color: ColorManager.themeColor,
        ),
      ),
      title: Text(place),
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
          final _places = widget.places
              .where((element) => element
                  .toLowerCase()
                  .trim()
                  .contains(value.toLowerCase().trim()))
              .toList();
          if (value.trim().isEmpty) {
            setState(() {
              places = widget.places;
            });
          } else {
            setState(() {
              places = _places;
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
            hintText: "Search ${widget.mode}",
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
