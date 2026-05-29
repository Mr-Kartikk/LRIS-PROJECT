class FoundItem {
  final int id;
  final String title;
  final String description;
  final String locationName;
  final String currentLocation;
  final DateTime foundDate;
  final String? brand;
  final String? color;
  final String? image;
  final String status;
  final DateTime datePosted;
  final Map<String, dynamic>? user;
  final int? category;

  FoundItem({
    required this.id,
    required this.title,
    required this.description,
    required this.locationName,
    required this.currentLocation,
    required this.foundDate,
    this.brand,
    this.color,
    this.image,
    required this.status,
    required this.datePosted,
    this.user,
    this.category,
  });

  factory FoundItem.fromJson(Map<String, dynamic> json) {
    return FoundItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      locationName: json['location_name'],
      currentLocation: json['current_location'],
      foundDate: DateTime.parse(json['found_date']),
      brand: json['brand'],
      color: json['color'],
      image: json['image'],
      status: json['status'],
      datePosted: DateTime.parse(json['date_posted']),
      user: json['user'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location_name': locationName,
      'current_location': currentLocation,
      'found_date': foundDate.toIso8601String(),
      'brand': brand,
      'color': color,
      'image': image,
      'status': status,
      'date_posted': datePosted.toIso8601String(),
      'category': category,
    };
  }
}
