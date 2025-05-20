import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts_service/flutter_contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:troco/core/cache/shared-preferences.dart';

import '../../auth/utils/phone-number-converter.dart';

class _ContactProcessingData {
  final List<ContactInfo> contacts;
  final String phoneNumber;

  _ContactProcessingData({required this.contacts, required this.phoneNumber});
}

class ContactsLoader {
  static Future<bool> requestPermissions() async {
    PermissionStatus status = await Permission.contacts.request();
    return status.isGranted;
  }

  // This will run in a separate isolate
  static List<ContactInfo> _processContacts(_ContactProcessingData data) {
    // filter out all the contact with empty phone numbers
    final notNullContacts = data.contacts.where((element) =>
        element.phones != null &&
        element.phones != [] &&
        element.phones!.any(
          (element) => element.value != null,
        ));

    // distinct all phone numbers (Not duplicate them)
    final distinctNumbers = notNullContacts
        .map((e) => PhoneNumberConverter.convertToFull(e.phones!.first.value!))
        .toSet()
        .toList();

    /// Add the contacts that contain any unique phone number back to an array
    final contacts = <ContactInfo>[];
    for (final number in distinctNumbers) {
      final contact =
          notNullContacts.firstWhereOrNull((element) => element.phones!.any(
                (element) =>
                    PhoneNumberConverter.convertToFull(element.value!) ==
                    number,
              ));
      if (contact != null) {
        contacts.add(contact);
      }
    }

    /// Remove any contact that contains this logged in user's number;
    final notUserContacts = contacts
        .toSet()
        .where(
          (element) => element.phones!.every(
            (element) =>
                PhoneNumberConverter.convertToFull(element.value!) !=
                data.phoneNumber,
          ),
        )
        .toSet();

    return notUserContacts.toList();
  }

  static Future<List<ContactInfo>> getContacts() async {
    if (await requestPermissions()) {
      // First, get all contacts on the main isolate
      final rawContacts =
          await FlutterContactsService.getContacts(withThumbnails: false);
      return compute(
          _processContacts,
          _ContactProcessingData(
              contacts: rawContacts,
              phoneNumber: AppStorage.getUser()!.phoneNumber));
    }
    return [];
  }
}
