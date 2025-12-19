class ExamEntry {
  final int? id;
  final String date;
  final String day;
  final String time;
  final String course;
  final String batch;
  final String section;
  final String room;

  ExamEntry({
    this.id,
    required this.date,
    required this.day,
    required this.time,
    required this.course,
    required this.batch,
    required this.section,
    required this.room,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'day': day,
      'time': time,
      'course': course,
      'batch': batch,
      'section': section,
      'room': room,
    };
  }

  factory ExamEntry.fromMap(Map<String, dynamic> map) {
    return ExamEntry(
      id: map['id'] as int?,
      date: map['date'] as String,
      day: map['day'] as String,
      time: map['time'] as String,
      course: map['course'] as String,
      batch: map['batch'] as String,
      section: map['section'] as String,
      room: map['room'] as String,
    );
  }
}
