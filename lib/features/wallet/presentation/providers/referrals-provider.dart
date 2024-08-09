// This is a state Provider, responsible for returning and refreshing
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/wallet/domain/entities/referral.dart';
import 'package:troco/features/wallet/domain/repository/wallet-repository.dart';

import '../../../../core/cache/shared-preferences.dart';

/// the Wallet Repo class. Inorder reload to be on the safer side when looking for changes.
final walletProvider =
    StateProvider<WalletRepository>((ref) => WalletRepository());

/// The Future provider that helps us to perform
/// The Future task of getting Referrals.
final referralsFutureProvider =
    FutureProvider<List<Map<dynamic, dynamic>>>((ref) async {
  final walletRepo = ref.watch(walletProvider);
  final data = await walletRepo.getReferrals();
  return data.map((e) => e.toJson()).toList();
});

/// The StreamProvider that constantly sends updates
/// Of the Referrals  only when there is a change
/// Cos we don't want constant rebuilding in the consumer widgets.
final referralsStreamProvider = StreamProvider<List<Referral>>(
  (ref) {
    final streamController = StreamController<List<Referral>>();

    final periodic = Timer.periodic(const Duration(seconds: 3), (_) {
      ref.watch(referralsFutureProvider).when(
          data: (referralsJson) {
            /// First of all we have to compare and contrast between the
            /// values gotten from the APIs and saved on the Device Cache.
            ///
            /// We compare and contrast the referrals itself.
            ///
            /// We extract the Lists. Lists starting with underscores ('_') are from the Cache.
            /// While the others are from the [transactionsJson];

            /// We get the transactionsList from the Cache
            final _referralsList =
                AppStorage.getReferrals().map((e) => e.toJson()).toList();

            /// Then We contrast.
            final bool referralsDifferent =
                json.encode(_referralsList) != json.encode(referralsJson);

            final valuesAreDifferent = referralsDifferent;

            List<Referral> referralsList =
                referralsJson.map((e) => Referral.fromJson(json: e)).toList();

            if (valuesAreDifferent) {
              AppStorage.saveReferrals(referrals: referralsList);
              streamController.sink.add(referralsList);
            }
            ref.watch(walletProvider.notifier).state = WalletRepository();
          },
          error: (error, stackTrace) =>
              log("Error occured when getting transactions from api $error"),
          loading: () => null);
    });

    ref.onDispose(() {
      streamController.close();
      periodic.cancel();
    });
    return streamController.stream;
  },
);
