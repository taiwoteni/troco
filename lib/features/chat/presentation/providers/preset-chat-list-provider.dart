import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/chat/data/model/chat-model.dart';

import '../../../auth/presentation/providers/client-provider.dart';

final presetChatNotifier = StateProvider<List<Chat>>((ref) => [
      const Chat.fromJson(json: {
        "id": "AlznchfU-jsa",
        "sender id": "AlzbchdUisdn0i9",
        "message": "Hey Teni, How're You? 🙃",
        "time": "2024-03-04T00:00:00.000",
        "read": true
      }),
      Chat.fromJson(json: {
        "id": "Alznccdsiut",
        "sender id": ref.read(ClientProvider.userProvider)!.userId,
        "message": "I'm Good You? 😎",
        "time": "2024-03-04T00:00:00.000",
        "read": true
      }),
      const Chat.fromJson(json: {
        "id": "AlznchfU-jsa",
        "sender id": "AlzbchdUisdn0i9",
        "message": "Yh. I'm Good. How's School?",
        "time": "2024-03-04T00:00:00.000",
        "read": true
      }),
      const Chat.fromJson(json: {
        "id": "AlznchfU-jsa",
        "sender id": "AlzbchdUisdn0i9",
        "message": "I heard that you aren't going to Babcock anymore",
        "time": "2024-03-04T00:00:00.000",
        "read": true
      }),
      const Chat.fromJson(json: {
        "id": "AlznchfU-jsa",
        "sender id": "AlzbchdUisdn0i9",
        "message": "So which Uni, are you currently going to?",
        "time": "2024-03-04T00:00:00.000",
        "read": true
      }),
      Chat.fromJson(json: {
        "id": "Alznccdsiutcd",
        "sender id": ref.read(ClientProvider.userProvider)!.userId,
        "message": "I'm Going to NIIT",
        "time": "2024-03-04T00:00:00.000",
        "read": true
      }),
      Chat.fromJson(json: {
        "id": "Alznccdsiutcd",
        "sender id": ref.read(ClientProvider.userProvider)!.userId,
        "message": "Meaning National Institute Of Innovative Technology",
        "time": "2024-03-04T00:00:00.000",
        "read": true
      }),
      const Chat.fromJson(json: {
        "id": "AlznchfU-jsa",
        "sender id": "AlzbchdUisdn0i9",
        "message": "Oh wow?",
        "time": "2024-03-04T00:00:00.000",
        "read": true
      }),
      Chat.fromJson(json: {
        "id": "Alznccdsiutcd",
        "sender id": ref.read(ClientProvider.userProvider)!.userId,
        "message":
            "It's an institution that teaches both older (working class) and younger age groups Tech related courses. Both standalone and Full courses. It's used to learn and acquire skills for jobs. But they also have a special programme for those learning Software Engineering. Those learning S.E are taught for 2 yrs but given their well known reputation, Universities also admit students who have finished the two years and enables them to join directly into yhe final year.",
        "time": "2024-03-04T00:00:00.000",
        "read": true
      }),
      const Chat.fromJson(json: {
        "id": "AlznchfU-jsa",
        "sender id": "AlzbchdUisdn0i9",
        // "attachment": ref.read(ClientProvider.userProvider)!.profile,
        "message": "Why use this as ur Dp 😂?",
        "time": "2024-03-04T00:00:00.000",
        "read": false
      }),
    ]);