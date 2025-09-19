class NavigationCategory {
  String id;
  String name;
  String image; // Google Cloud Storage URL for the category icon
  String? route; // Optional route for navigation

  NavigationCategory({
    required this.id,
    required this.name,
    required this.image,
    this.route,
  });

  NavigationCategory.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        name = json['name'] as String,
        image = json['image'] as String,
        route = json['route'] as String?;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'route': route,
    };
  }
}
