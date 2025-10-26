class Destination {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String location;
  final double latitude;
  final double longitude;
  final String category;
  final double rating;
  final List<String> tags;
  final double price;
  final String currency;
  final bool isFavorite;

  Destination({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.rating,
    required this.tags,
    required this.price,
    this.currency = 'USD',
    this.isFavorite = false,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      location: json['location'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      category: json['category'] ?? '',
      rating: json['rating']?.toDouble() ?? 0.0,
      tags: List<String>.from(json['tags'] ?? []),
      price: json['price']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'rating': rating,
      'tags': tags,
      'price': price,
      'currency': currency,
      'isFavorite': isFavorite,
    };
  }

  Destination copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? location,
    double? latitude,
    double? longitude,
    String? category,
    double? rating,
    List<String>? tags,
    double? price,
    String? currency,
    bool? isFavorite,
  }) {
    return Destination(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}