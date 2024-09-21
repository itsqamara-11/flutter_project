class Furniture {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final double price; // Ensure price is a double
  bool isSaved;

  Furniture({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.isSaved = false,
  }); 

  factory Furniture.fromJson(Map<String, dynamic> json) {
    return Furniture(
      id: json['id'],
      name: json['title'],
      description: json['description'],
      imageUrl: json['thumbnail'],
      price: json['price'].toDouble(), // Convert price to double
    );
  }
}
