import 'package:troco/features/notifications/utils/enums.dart';

class NotificationTypeConverter {
  static NotificationType convertToType(
      {required final String notificationType}) {
    switch (notificationType.toLowerCase().trim()) {
      case "verify transaction":
      return NotificationType.VerifyTransaction;
      case "await transaction approval":
      return NotificationType.CreateNotification;
      default:
        return NotificationType.Unknown;
    }
  }
}
