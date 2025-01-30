
class LogEntry {
  final String timestamp;
  final String action;
  final String status;
  final String details;
  final String userName;
  final String object;

  const LogEntry({
    required this.timestamp,
    required this.action,
    required this.status,
    required this.details,
    required this.userName,
    required this.object,
  });

  factory LogEntry.fromMap(Map<String, dynamic> map) {
    return LogEntry(
      timestamp: map['timestamp'],
      action: map['action'],
      status: map['status'],
      details: map['details'],
      userName: map['userName'],
      object: map['object'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'action': action,
      'status': status,
      'details': details,
      'userName': userName,
      'object': object,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LogEntry &&
        other.timestamp == timestamp &&
        other.action == action &&
        other.status == status &&
        other.details == details &&
        other.userName == userName &&
        other.object == object;
  }

  @override
  int get hashCode {
    return timestamp.hashCode ^
        action.hashCode ^
        status.hashCode ^
        details.hashCode ^
        userName.hashCode ^
        object.hashCode;
  }

  LogEntry copyWith({
    String? timestamp,
    String? action,
    String? status,
    String? details,
    String? userName,
    String? object,
  }) {
    return LogEntry(
      timestamp: timestamp ?? this.timestamp,
      action: action ?? this.action,
      status: status ?? this.status,
      details: details ?? this.details,
      userName: userName ?? this.userName,
      object: object ?? this.object,
    );
  }
}
