import 'package:firebase_database/firebase_database.dart';
import '../models/ServiceModel.dart';

class BarberServicesService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  /// Obtener todos los servicios del barbero
  Future<List<ServiceModel>> getServices(String barberId) async {
    if (barberId.isEmpty) return [];

    final snapshot = await _db.child('services').get();
    if (!snapshot.exists) return [];

    final List<ServiceModel> list = [];

    for (final e in snapshot.children) {

      final data = Map<dynamic, dynamic>.from(e.value as Map);

      list.add(ServiceModel.fromMap(e.key!, data));
    }
    return list;
  }

  /// Crear servicio
  Future<void> addService(String barberId, ServiceModel service) async {
    if (barberId.isEmpty) {
      throw Exception('❌ barberId vacío al crear servicio');
    }

    await _db
        .child('services')
        .push()
        .set(service.toMap());
  }

  /// Eliminar servicio
  Future<void> deleteService(String barberId, String serviceId) async {
    if (barberId.isEmpty || serviceId.isEmpty) return;

    await _db
        .child('services/$barberId/$serviceId')
        .remove();
  }

  Future<void> updatePrice(String serviceId, int price) async {
    await _db.child('services/$serviceId').update({
      'price': price,
    });
  }

}
