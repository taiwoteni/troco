import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/auth/data/models/client.dart';

import '../../../../core/cache/shared-preferences.dart';

final _clientProvider = StateProvider<Client?>((ref) {
  return AppStorage.getUser();
});

class ClientProvider{
  static StateProvider<Client?> get userProvider =>_clientProvider;
  static void saveUserData({required final WidgetRef ref, required final Map<dynamic,dynamic> json}){
    AppStorage.saveClient(client: Client.fromJson(json: json));
    ref.watch(_clientProvider.notifier).state = AppStorage.getUser();
  }
}