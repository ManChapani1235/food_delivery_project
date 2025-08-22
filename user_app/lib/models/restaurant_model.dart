class RestaurantModel {
  final int? id;
  final String? name;
  final String? image; // Can be URL or base64 string
  final List<String>? categories;
  final double? rating;
  final String? deliveryTime;
  final String? priceRange;
  final int? priceForOne;

  RestaurantModel({
    this.id,
    this.name,
    this.image,
    this.categories,
    this.rating,
    this.deliveryTime,
    this.priceRange,
    this.priceForOne,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    String img = json['image'] ?? "";

    // Handle relative paths or base64 images
    if (img.isNotEmpty && !img.startsWith('http') && !img.startsWith('data:')) {
      img = img; // leave relative path, _getFullImageUrl() in HomeScreen will handle it
    }

    return RestaurantModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      name: json['name'] ?? "",
      image: img,
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : [],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      deliveryTime: json['deliveryTime'] ?? "",
      priceRange: json['priceRange'] ?? "",
      priceForOne: json['priceForOne'] ?? 0,
    );
  }
}
