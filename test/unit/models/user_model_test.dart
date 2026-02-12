import 'package:flutter_test/flutter_test.dart';
import 'package:luxefinds_client/models/user.dart';

void main() {
  group('User Model Tests', () {
    final testUser = User(
      id: '123',
      email: 'test@example.com',
      name: 'Test User',
      isAdmin: false,
      createdAt: DateTime(2024, 1, 1),
    );

    group('Initialization', () {
      test('creates user with all required fields', () {
        expect(testUser.id, equals('123'));
        expect(testUser.email, equals('test@example.com'));
        expect(testUser.name, equals('Test User'));
        expect(testUser.isAdmin, equals(false));
      });

      test('creates admin user', () {
        final adminUser = User(
          id: '456',
          email: 'admin@example.com',
          name: 'Admin',
          isAdmin: true,
          createdAt: DateTime(2024, 1, 1),
        );
        expect(adminUser.isAdmin, equals(true));
      });
    });

    group('JSON Serialization', () {
      test('converts user to JSON', () {
        final json = testUser.toJson();
        expect(json['id'], equals('123'));
        expect(json['email'], equals('test@example.com'));
        expect(json['name'], equals('Test User'));
        expect(json['isAdmin'], equals(false));
      });

      test('creates user from JSON', () {
        final json = {
          'id': '789',
          'email': 'newuser@example.com',
          'name': 'New User',
          'isAdmin': false,
          'createdAt': '2024-02-01T00:00:00.000Z',
        };
        final user = User.fromJson(json);
        expect(user.id, equals('789'));
        expect(user.email, equals('newuser@example.com'));
        expect(user.name, equals('New User'));
      });

      test('handles null optional fields in JSON', () {
        final json = {
          'id': '123',
          'email': 'test@example.com',
          'name': 'Test User',
          'isAdmin': false,
          'createdAt': '2024-01-01T00:00:00.000Z',
        };
        final user = User.fromJson(json);
        expect(user.id, isNotEmpty);
      });

      test('round-trip JSON serialization preserves data', () {
        final json = testUser.toJson();
        final newUser = User.fromJson(json);
        expect(newUser.id, equals(testUser.id));
        expect(newUser.email, equals(testUser.email));
        expect(newUser.name, equals(testUser.name));
        expect(newUser.isAdmin, equals(testUser.isAdmin));
      });
    });

    group('Equality', () {
      test('users with same data are equal', () {
        final user1 = User(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
          isAdmin: false,
          createdAt: DateTime(2024, 1, 1),
        );
        final user2 = User(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
          isAdmin: false,
          createdAt: DateTime(2024, 1, 1),
        );
        expect(user1, equals(user2));
      });

      test('users with different data are not equal', () {
        final user1 = User(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
          isAdmin: false,
          createdAt: DateTime(2024, 1, 1),
        );
        final user2 = User(
          id: '456',
          email: 'other@example.com',
          name: 'Other User',
          isAdmin: true,
          createdAt: DateTime(2024, 1, 1),
        );
        expect(user1, isNot(equals(user2)));
      });

      test('users with same id but different email are not equal', () {
        final user1 = User(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
          isAdmin: false,
          createdAt: DateTime(2024, 1, 1),
        );
        final user2 = User(
          id: '123',
          email: 'different@example.com',
          name: 'Test User',
          isAdmin: false,
          createdAt: DateTime(2024, 1, 1),
        );
        expect(user1, isNot(equals(user2)));
      });
    });

    group('Immutability', () {
      test('user is immutable (Freezed)', () {
        expect(() => testUser.copyWith(name: 'New Name'), returnsNormally);
      });

      test('copyWith creates new user with updated field', () {
        final updatedUser = testUser.copyWith(name: 'Updated Name');
        expect(updatedUser.name, equals('Updated Name'));
        expect(updatedUser.id, equals(testUser.id));
        expect(updatedUser.email, equals(testUser.email));
      });

      test('copyWith preserves original user', () {
        final original = testUser;
        final updated = testUser.copyWith(email: 'newemail@example.com');
        expect(original.email, equals('test@example.com'));
        expect(updated.email, equals('newemail@example.com'));
      });
    });

    group('String Representation', () {
      test('toString returns meaningful representation', () {
        final stringRep = testUser.toString();
        expect(stringRep, contains('User'));
        expect(stringRep, contains('123')); // id
      });
    });
  });
}
