
class LogEntry {
  final String id;
  final DateTime timestamp;
  final String action;
  final String status;
  final String details;
  final String userName;

  const LogEntry({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.status,
    required this.details,
    required this.userName,
  });

  factory LogEntry.fromMap(Map<String, dynamic> map) {
    return LogEntry(
      id: map['id'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      action: map['action'] ?? '',
      status: map['status'] ?? '',
      details: map['details'] ?? '',
      userName: map['username'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'action': action,
      'status': status,
      'details': details,
      'username': userName,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LogEntry &&
        other.timestamp == timestamp &&
        other.id == id &&
        other.action == action &&
        other.status == status &&
        other.details == details &&
        other.userName == userName;
  }

  @override
  int get hashCode {
    return timestamp.hashCode ^
        action.hashCode ^
        status.hashCode ^
        id.hashCode ^
        details.hashCode ^
        userName.hashCode ;
  }

  LogEntry copyWith({
    String? id,
    DateTime? timestamp,
    String? action,
    String? status,
    String? details,
    String? userName,
  }) {
    return LogEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      action: action ?? this.action,
      status: status ?? this.status,
      details: details ?? this.details,
      userName: userName ?? this.userName,
    );
  }
}
