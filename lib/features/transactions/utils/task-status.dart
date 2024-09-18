enum TaskStatus {
  Pending,
  Submitted,
  Accepted,
  Rejected,
}

class TaskStatusConverter {
  static TaskStatus toTaskStatus({required final String status}) {
    switch (status.toLowerCase().trim()) {
      case "accepted":
        return TaskStatus.Accepted;
      case "rejected":
        return TaskStatus.Rejected;
      case "submitted":
        return TaskStatus.Submitted;
      default:
        return TaskStatus.Pending;
    }
  }
}
