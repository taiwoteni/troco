import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/images/profile-icon.dart';

class ContactWidget extends StatefulWidget {
  final Contact contact;
  const ContactWidget({super.key, required this.contact});

  @override
  State<ContactWidget> createState() => _ContactWidgetState();
}

class _ContactWidgetState extends State<ContactWidget> {
  late Contact contact;
  @override
  void initState() {
    contact = widget.contact;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      tileColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      leading: contactImage(),
      horizontalTitleGap: SizeManager.medium * 0.8,
      title: Text(
        contact.displayName ?? "Unknown",
        overflow: TextOverflow.ellipsis,
      ),
      titleTextStyle: TextStyle(
          overflow: TextOverflow.ellipsis,
          color: ColorManager.primary,
          fontFamily: 'Lato',
          fontSize: FontSizeManager.medium * 1.1,
          fontWeight: FontWeightManager.semibold),
      subtitle: (contact.phones ?? []).isNotEmpty
          ? Text(contact.phones!.first.value!)
          : null,
      trailing: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: SizeManager.medium, vertical: SizeManager.regular),
        decoration: BoxDecoration(
            color: ColorManager.accentColor,
            borderRadius: BorderRadius.circular(SizeManager.regular)),
        child: const Text(
          "Add",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'lato',
              fontSize: FontSizeManager.regular * 0.9,
              fontWeight: FontWeightManager.semibold),
        ),
      ),
      subtitleTextStyle: TextStyle(
          overflow: TextOverflow.ellipsis,
          color: ColorManager.accentColor,
          fontFamily: 'Lato',
          fontSize: FontSizeManager.regular * 1.1,
          fontWeight: FontWeightManager.medium),
    );
  }

  Widget contactImage() {
    return FutureBuilder(
      future: ContactsService.getAvatar(contact),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            width: 53,
            height: 53,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.cover, image: MemoryImage(contact.avatar!))),
          );
        }
        return Transform.scale(
            scale: 1.25, child: const ProfileIcon(size: 53, url: null));
      },
    );
  }
}
