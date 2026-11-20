import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/features/estate/data/models/estate_model.dart';

void main() {
  test('location coordinates round-trip through the Firestore map shape', () {
    const location = EstateLocationModel(
      address: 'Zamalek, Cairo',
      city: 'Cairo',
      latitude: 30.0615,
      longitude: 31.2190,
    );

    final serialized = location.toMap();
    final restored = EstateLocationModel.fromMap(serialized);

    expect(serialized['latitude'], 30.0615);
    expect(serialized['longitude'], 31.2190);
    expect(restored.latitude, location.latitude);
    expect(restored.longitude, location.longitude);
    expect(restored.address, location.address);
    expect(restored.city, location.city);
  });
}
