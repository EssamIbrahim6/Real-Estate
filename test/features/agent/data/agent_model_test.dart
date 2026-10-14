import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/features/agent/data/models/agent_model.dart';

void main() {
  group('AgentModel.fromMap', () {
    test('maps the Firestore agent name and photoUrl fields', () {
      final agent = AgentModel.fromMap({
        'name': 'Nour Hassan',
        'agencyName': 'Cairo Homes',
        'photoUrl': 'https://example.com/nour.jpg',
      }, 'agent-document-id');

      expect(agent.id, 'agent-document-id');
      expect(agent.name, 'Nour Hassan');
      expect(agent.displayName, 'Nour Hassan');
      expect(agent.primaryPhotoUrl, 'https://example.com/nour.jpg');
    });

    test('accepts profile fields used by existing profile documents', () {
      final agent = AgentModel.fromMap({
        'displayName': 'Mina Adel',
        'profileImageUrl': 'https://example.com/mina.jpg',
      }, 'agent-document-id');

      expect(agent.displayName, 'Mina Adel');
      expect(agent.primaryPhotoUrl, 'https://example.com/mina.jpg');
    });

    test('supports an explicitly stored primaryPhotoUrl field', () {
      final agent = AgentModel.fromMap({
        'name': 'Salma Ali',
        'primaryPhotoUrl': 'https://example.com/salma.jpg',
      }, 'agent-document-id');

      expect(agent.primaryPhotoUrl, 'https://example.com/salma.jpg');
    });

    test(
      'falls through blank canonical fields to populated profile fields',
      () {
        final agent = AgentModel.fromMap({
          'name': ' ',
          'displayName': 'Hana Mostafa',
          'photoUrl': '',
          'profileImageUrl': 'https://example.com/hana.jpg',
        }, 'agent-document-id');

        expect(agent.displayName, 'Hana Mostafa');
        expect(agent.primaryPhotoUrl, 'https://example.com/hana.jpg');
      },
    );

    test('uses the linked users document for missing profile fields', () {
      final agent = AgentModel.fromMap(
        {'userId': 'auth-user-id', 'agencyName': 'Cairo Homes'},
        'agent-document-id',
        userProfile: {
          'name': 'Mariam Samir',
          'profileImageUrl': 'https://example.com/mariam.jpg',
        },
      );

      expect(agent.displayName, 'Mariam Samir');
      expect(agent.primaryPhotoUrl, 'https://example.com/mariam.jpg');
    });
  });
}
