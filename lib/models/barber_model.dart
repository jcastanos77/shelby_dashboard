class BarberModel {
  final String id;
  final String name;
  final String phone;
  final bool active;
  final String role;

  BarberModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.active,
    required this.role
  });

  factory BarberModel.fromMap(String id, Map<dynamic, dynamic> data) {
    return BarberModel(
      id: id,
      name: data['name'],
      phone: data['phone'],
      active: data['active'] ?? true,
      role: data['role']
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'phone': phone,
    'active': active,
    'role': role
  };
}
