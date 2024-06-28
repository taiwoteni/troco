import 'dart:convert';
import 'dart:developer';

import 'package:troco/features/payments/domain/repo/bank-repository.dart';

import '../../domain/entity/bank.dart';

Future<List<Bank>> allAvailableBanks() async {
  final response = await BankRepository.getAllBanks();
  var banksJson = [];

  if (!response.error) {
    final _banksJson = (response.messageBody!["data"] as List);
    banksJson = _banksJson;

    final logoResponse = await BankRepository.getAllBanksWithLogo();
    if (logoResponse.error) {
      return banksJson.map((bank) => Bank.fromJson(json: bank)).toList();
    } else {
      // We now map and affect the logos of the banks grotten from flutterwave
      // To those gotten from this Second API.
      final banksWithLogoJson = (json.decode(logoResponse.body) as List);
      for(final json in banksWithLogoJson){
        /// If the logo is not a default or null logo
        if(json["logo"] != null && !json["logo"].toString().contains("default-image")){
          // If one of the banks from flutterwave has the same code as this bank
          if(banksJson.map((e) => e["code"],).contains(json["code"])){

            final bankJson = banksJson.firstWhere((element) => element["code"]==json["code"],);
            bankJson["logo"] = json["logo"];
            banksJson[banksJson.indexOf(bankJson)] = bankJson;
          }
        }
      }
      log(banksJson.toString());
      return banksJson.map((bank) => Bank.fromJson(json: bank)).toList();
    }
  }

  return [];
}
