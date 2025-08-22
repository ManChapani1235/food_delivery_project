class CategoryModel {
  final int id;
  final String name;
  final String image; // Can be URL or base64 string

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    String img = json['image'] ?? "";

    // If image is relative path or base64 without prefix, just leave as is.
    // Flutter's Image.network can handle "data:image/jpeg;base64,..." or URL
    if (img.isNotEmpty && !img.startsWith('http') && !img.startsWith('data:')) {
      img = img; // leave relative path, _getFullImageUrl() will handle it
    }

    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      image: img,
    );
  }
}
