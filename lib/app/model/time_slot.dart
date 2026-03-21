class TimeSlot {
  String start;
  String end;
  int capacity;

  TimeSlot({
    required this.start,
    required this.end,
    required this.capacity,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      start: json['start'],
      end: json['end'],
      capacity: json['capacity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "start": start,
      "end": end,
      "capacity": capacity,
    };
  }
}
