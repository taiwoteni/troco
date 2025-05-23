import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/auth/domain/entities/client.dart';

import '../../../../core/cache/shared-preferences.dart';

final clientProvider = StateProvider<Client?>((ref) {
  return AppStorage.getUser();
});



class ClientProvider{
  static StateProvider<Client?> get userProvider =>clientProvider;
  static void saveUserData({required final WidgetRef ref, required final Map<dynamic,dynamic> json}){
    AppStorage.saveClient(client: Client.fromJson(json: json));
    ref.watch(clientProvider.notifier).state = AppStorage.getUser();
  }
  static Client? get readOnlyClient => AppStorage.getUser();
}