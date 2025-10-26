import 'destination.dart';

class Itinerary {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final List<ItineraryDay> days;
  final String imageUrl;
  final double totalBudget;
  final String currency;
  final bool isShared;
  final DateTime createdAt;
  final DateTime updatedAt;

  Itinerary({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.days,
    this.imageUrl = '',
    this.totalBudget = 0.0,
    this.currency = 'USD',
    this.isShared = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      days: (json['days'] as List<dynamic>?)
              ?.map((day) => ItineraryDay.fromJson(day))
              .toList() ??
          [],
      imageUrl: json['imageUrl'] ?? '',
      totalBudget: json['totalBudget']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      isShared: json['isShared'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'days': days.map((day) => day.toJson()).toList(),
      'imageUrl': imageUrl,
      'totalBudget': totalBudget,
      'currency': currency,
      'isShared': isShared,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  int get duration => endDate.difference(startDate).inDays + 1;
}

class ItineraryDay {
  final String id;
  final int dayNumber;
  final DateTime date;
  final List<ItineraryActivity> activities;
  final String notes;

  ItineraryDay({
    required this.id,
    required this.dayNumber,
    required this.date,
    required this.activities,
    this.notes = '',
  });

  factory ItineraryDay.fromJson(Map<String, dynamic> json) {
    return ItineraryDay(
      id: json['id'] ?? '',
      dayNumber: json['dayNumber'] ?? 1,
      date: DateTime.parse(json['date']),
      activities: (json['activities'] as List<dynamic>?)
              ?.map((activity) => ItineraryActivity.fromJson(activity))
              .toList() ??
          [],
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dayNumber': dayNumber,
      'date': date.toIso8601String(),
      'activities': activities.map((activity) => activity.toJson()).toList(),
      'notes': notes,
    };
  }
}

class ItineraryActivity {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final Destination? destination;
  final String type; // 'visit', 'meal', 'transport', 'accommodation', 'other'
  final double cost;
  final String currency;
  final bool isBooked;
  final String bookingReference;
  final String notes;

  ItineraryActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.destination,
    required this.type,
    this.cost = 0.0,
    this.currency = 'USD',
    this.isBooked = false,
    this.bookingReference = '',
    this.notes = '',
  });

  factory ItineraryActivity.fromJson(Map<String, dynamic> json) {
    return ItineraryActivity(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      destination: json['destination'] != null
          ? Destination.fromJson(json['destination'])
          : null,
      type: json['type'] ?? 'other',
      cost: json['cost']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      isBooked: json['isBooked'] ?? false,
      bookingReference: json['bookingReference'] ?? '',
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'destination': destination?.toJson(),
      'type': type,
      'cost': cost,
      'currency': currency,
      'isBooked': isBooked,
      'bookingReference': bookingReference,
      'notes': notes,
    };
  }

  Duration get duration => endTime.difference(startTime);
}