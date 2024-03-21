import 'package:nigerian_states_and_lga/nigerian_states_and_lga.dart';

class ValuesManager {
  static const String APP_NAME = "Troco";
  static const List<String> members = ["Teninlanimi Taiwo", "Micheal", "..."];
  static const String dummyDescription =
      "It is a long established fact with a\nreadable content of a page when\n looking at its layout.";
  static const double bottomBarHeight = 65.0;

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
