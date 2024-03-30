// ignore_for_file: constant_identifier_names

import 'package:nigerian_states_and_lga/nigerian_states_and_lga.dart';

class ValuesManager {
  static const String APP_NAME = "Troco";
  static const List<String> members = ["Teninlanimi Taiwo", "Micheal", "..."];
  static const welcomeString =
      "We are excited to be part of your\ndaily business transactions.\n\nIn our mission to keep\ntransactions safe and inclusive, we\nask you to adhere to our community\nrules and remember that we are always\nhere for you.";
  static const String dummyDescription =
      "It is a long established fact with a\nreadable content of a page when\n looking at its layout.";
  static const String USER_STORAGE_KEY = "userData";

  static Map<String, List<String>> allCitiesAndState() {
    Map<String, List<String>> nigerianStatesAndCities = {};

    for (String state in NigerianStatesAndLGA.allStates) {
      List<String> cities =
          NigerianStatesAndLGA.getStateLGAs(state).map((lga) => lga).toList();
      nigerianStatesAndCities[state] = cities;
    }

    return nigerianStatesAndCities;
  }
}
