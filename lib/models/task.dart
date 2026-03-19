class Task {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final String category;
  final String time;
  final String? date;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.category,
    required this.time,
    this.date,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      isCompleted: json['is_completed'] ?? false,
      category: json['category'] ?? 'General',
      time: json['time'] ?? '8 A.M',
      date: json['date'],
    );
  }
}