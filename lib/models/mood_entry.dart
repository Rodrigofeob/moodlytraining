import 'package:intl/intl.dart';

class MoodEntry {
  final int? id;
  final DateTime date;
  final int moodRating; // 1-5 para representar o humor (1: muito triste, 5: muito feliz)
  final String description;
  final String? activities; // Atividades realizadas no dia (opcional)

  MoodEntry({
    this.id,
    required this.date,
    required this.moodRating,
    required this.description,
    this.activities,
  });

  // Converter de Map (vindo do banco de dados) para MoodEntry
  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      moodRating: map['moodRating'],
      description: map['description'],
      activities: map['activities'],
    );
  }

  // Converter de MoodEntry para Map (para salvar no banco de dados)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'moodRating': moodRating,
      'description': description,
      'activities': activities,
    };
  }

  // Criar uma cópia do objeto com algumas propriedades alteradas
  MoodEntry copyWith({
    int? id,
    DateTime? date,
    int? moodRating,
    String? description,
    String? activities,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      moodRating: moodRating ?? this.moodRating,
      description: description ?? this.description,
      activities: activities ?? this.activities,
    );
  }
} 