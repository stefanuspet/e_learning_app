class Session {
  final int id;
  final String title;
  final DateTime date;

  Session({
    required this.id,
    required this.title,
    required this.date,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      title: json['title'] ?? '-',
      date: json['date'] != null
          ? DateTime.tryParse(json['date']) ?? DateTime.now()
          : DateTime.now(),
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
    };
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime(2000);
    if (value is DateTime) return value;
    if (value is int) {
      // UNIX timestamp
      return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }
    return DateTime.tryParse(value.toString()) ?? DateTime(2000);
  }
}
