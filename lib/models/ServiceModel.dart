class ServiceModel {
  final String id;
  final String name;
  final int price;
  final int duration;
  final String description;
  final bool isSpecial;

  ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.description,
    required this.isSpecial
  });

  factory ServiceModel.fromMap(String id, Map<dynamic, dynamic> data) {
    return ServiceModel(
      id: id,
      name: data['name'] as String,
      price: data['price'] as int,
      duration: data['duration'] as int,
      description: data['description'] as String,
      isSpecial: data['isSpecial'] as bool
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'duration': duration,
      'description': description,
      'isSpecial': isSpecial
    };
  }
}
