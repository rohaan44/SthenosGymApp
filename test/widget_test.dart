import 'package:flutter_test/flutter_test.dart';
import 'package:app/firebase_options_prod.dart' as prod;
import 'package:app/firebase_options_dev.dart' as dev;

void main() {
  group('Firebase Environment Configuration Tests', () {
    test('Production Firebase configuration contains the correct Project ID', () {
      expect(prod.DefaultFirebaseOptions.web.projectId, 'sthenos-gym-8de40');
    });

    test('Development Firebase configuration contains the correct Project ID', () {
      expect(dev.DefaultFirebaseOptions.web.projectId, 'sthenos-gym-ce563');
    });
  });
}
