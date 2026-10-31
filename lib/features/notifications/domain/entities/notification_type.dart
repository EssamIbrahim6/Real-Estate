enum NotificationType {
  accountCreated,
  chatMessage,
  bookingReceived,
  bookingStatusChanged,
  listingStatusChanged,
  newMatchingProperty;

  String toJson() => name;

  static NotificationType fromJson(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationType.chatMessage,
    );
  }
}

