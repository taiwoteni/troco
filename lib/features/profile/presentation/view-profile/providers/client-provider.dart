import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';

import '../../../../auth/domain/entities/client.dart';

final userProfileProvider = StateProvider.autoDispose<Client?>(
  (ref) => ClientProvider.readOnlyClient,
);
