import 'package:flutter_contacts_service/flutter_contacts_service.dart'
    show ContactInfo;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/auth/utils/phone-number-converter.dart';
import 'package:troco/features/groups/presentation/friends_tab/widgets/contact-widget.dart';
import 'package:troco/features/groups/utils/contacts-loader.dart';
import 'package:troco/features/groups/utils/enums.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../../notifications/presentation/widgets/notification-menu-button.dart';
import '../../collections_page/widgets/empty-screen.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  late List<ContactInfo> contacts, allContacts;
  final TextEditingController controller = TextEditingController();
  late Widget searchBar;
  bool loadingContacts = true;
  ContactsFilter filter = ContactsFilter.Unregistered;

  @override
  void initState() {
    contacts = [];
    allContacts = [];
    searchBar = searchBarWidget();
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timestamp) {
      SystemChrome.setSystemUIOverlayStyle(
          ThemeManager.getWalletUiOverlayStyle());
      fetchContacts();
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) {
      return;
    }
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: SizedBox.square(
          dimension: double.maxFinite,
          child:
              contacts.isEmpty ? body() : SingleChildScrollView(child: body())),
    );
  }

  Widget body() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.large * 1.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          extraLargeSpacer(),
          back(),
          mediumSpacer(),
          title(),
          largeSpacer(),
          searchBar,
          mediumSpacer(),
          menuButtons(),
          contactsList(),
        ],
      ),
    );
  }

  Widget title() {
    return Text(
      "Your Contacts",
      textAlign: TextAlign.left,
      style: TextStyle(
          color: ColorManager.accentColor,
          fontFamily: 'lato',
          fontSize: FontSizeManager.large * 1.2,
          fontWeight: FontWeightManager.extrabold),
    );
  }

  Widget back() {
    return Align(
      alignment: Alignment.centerRight,
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
    );
  }

  //gnnfbf

  Widget menuButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...ContactsFilter.values.map((filter) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ToggleWidget(
                    selected: filter == this.filter,
                    onChecked: () {
                      setState(() {
                        this.filter = filter;
                      });
                      final filteredContacts = allContacts
                          .where((element) =>
                              this.filter == ContactsFilter.Unregistered
                                  ? !isRegistered(contact: element)
                                  : isRegistered(contact: element))
                          .toList();
                      setState(() => contacts = filteredContacts);
                    },
                    label: filter.name.toLowerCase()),
                regularSpacer(),
                smallSpacer(),
              ],
            );
          })
        ],
      ),
    );
  }

  Widget contactsList() {
    return contacts.isEmpty
        ? Flexible(
            child: EmptyScreen(
              expanded: false,
              lottie: AssetManager.lottieFile(
                  name: controller.text.trim().isNotEmpty
                      ? "no-search-results"
                      : "plane-cloud"),
              forward: controller.text.trim().isNotEmpty,
              xIndex: controller.text.trim().isEmpty ? 0 : 0.25,
              label: controller.text.trim().isNotEmpty
                  ? "No results for '${controller.text}'"
                  : loadingContacts
                      ? "Getting Contacts"
                      : "You do not have any contact",
            ),
          )
        : ListView.separated(
            key: const Key("contacts-list"),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => ContactWidget(
                key: ObjectKey(contacts[index]), contact: contacts[index]),
            separatorBuilder: (context, index) {
              if (index == contacts.length - 1) {
                return Gap(SizeManager.bottomBarHeight);
              } else {
                return Divider(
                  thickness: 0.8,
                  color: ColorManager.secondary.withOpacity(0.08),
                );
              }
            },
            itemCount: contacts.length);
  }

  Future<void> fetchContacts() async {
    final _fetchedContacts = await ContactsLoader.getContacts();
    final filteredContacts = _fetchedContacts
        .where((element) => this.filter == ContactsFilter.Unregistered
            ? !isRegistered(contact: element)
            : isRegistered(contact: element))
        .toList();

    setState(() {
      loadingContacts = false;
      this.contacts = filteredContacts;
      allContacts = _fetchedContacts;
    });
  }

  Widget searchBarWidget() {
    return TextFormField(
      controller: controller,
      maxLines: 1,
      onChanged: (text) {
        final _contacts = text.trim().isEmpty
            ? allContacts
            : allContacts
                .where((element) => (element.displayName ?? "")
                    .toString()
                    .toLowerCase()
                    .contains(text.trim().toLowerCase()))
                .toList();
        final filteredContacts = _contacts
            .where((element) => filter == ContactsFilter.Unregistered
                ? !isRegistered(contact: element)
                : isRegistered(contact: element))
            .toList();
        setState(() => contacts = filteredContacts);
      },
      cursorColor: ColorManager.themeColor,
      cursorRadius: const Radius.circular(SizeManager.medium),
      style: defaultStyle(),
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
              vertical: SizeManager.medium,
              horizontal: SizeManager.medium * 1.3),
          isDense: true,
          hintText: "Search Contacts",
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

  bool isRegistered({required final ContactInfo contact}) {
    final phoneNumbers = (contact.phones ?? [])
        .map(
          (e) => PhoneNumberConverter.convertToFull(
              (e.value?.replaceAll(" ", "") ?? "00000000000")),
        )
        .toList();
    final trocoUser = AppStorage.getAllUsersPhone().any((element) =>
        phoneNumbers
            .contains(PhoneNumberConverter.convertToFull(element.phoneNumber)));

    return trocoUser;
  }
}
