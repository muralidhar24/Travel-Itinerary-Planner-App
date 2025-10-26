class Booking {
  final String id;
  final String userId;
  final String destinationId;
  final String destinationName;
  final String destinationImage;
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfPeople;
  final double totalPrice;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final String bookingType; // 'hotel', 'flight', 'package', 'activity'
  final Map<String, dynamic>? additionalDetails;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.userId,
    required this.destinationId,
    required this.destinationName,
    required this.destinationImage,
    required this.startDate,
    required this.endDate,
    required this.numberOfPeople,
    required this.totalPrice,
    required this.status,
    required this.bookingType,
    this.additionalDetails,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      destinationId: json['destinationId'] ?? '',
      destinationName: json['destinationName'] ?? '',
      destinationImage: json['destinationImage'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      numberOfPeople: json['numberOfPeople'] ?? 1,
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      bookingType: json['bookingType'] ?? 'package',
      additionalDetails: json['additionalDetails'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'destinationId': destinationId,
      'destinationName': destinationName,
      'destinationImage': destinationImage,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'numberOfPeople': numberOfPeople,
      'totalPrice': totalPrice,
      'status': status,
      'bookingType': bookingType,
      'additionalDetails': additionalDetails,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Booking copyWith({
    String? id,
    String? userId,
    String? destinationId,
    String? destinationName,
    String? destinationImage,
    DateTime? startDate,
    DateTime? endDate,
    int? numberOfPeople,
    double? totalPrice,
    String? status,
    String? bookingType,
    Map<String, dynamic>? additionalDetails,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      destinationId: destinationId ?? this.destinationId,
      destinationName: destinationName ?? this.destinationName,
      destinationImage: destinationImage ?? this.destinationImage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      bookingType: bookingType ?? this.bookingType,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get durationInDays => endDate.difference(startDate).inDays;

  bool get isUpcoming => startDate.isAfter(DateTime.now()) && status == 'confirmed';
  bool get isActive => DateTime.now().isAfter(startDate) && 
                       DateTime.now().isBefore(endDate) && 
                       status == 'confirmed';
  bool get isCompleted => status == 'completed' || 
                          (DateTime.now().isAfter(endDate) && status == 'confirmed');
  bool get isCancelled => status == 'cancelled';
}