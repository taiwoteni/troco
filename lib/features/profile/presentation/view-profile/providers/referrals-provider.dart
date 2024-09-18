import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/groups/domain/entities/group.dart';
import 'package:troco/features/wallet/domain/entities/referral.dart';

final referralsProfileProvider = StateProvider<List<Referral>>(
  (ref) => [],
);
