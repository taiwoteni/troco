import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/chat/domain/entities/chat.dart';

/// This is a provider that will be used for pendingChatLists, i.e Chats that are pending to be sent.
/// 
final pendingChatListProvider = StateProvider.family<List<Chat>, String>((ref, groupId) => AppStorage.getUnsentChats(groupId: groupId));