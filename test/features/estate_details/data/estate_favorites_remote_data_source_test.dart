import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/features/estate_details/data/datasources/estate_details_remote_data_source.dart';

void main() {
  test(
    'stores a favorite under the user/estate path with server timestamp',
    () async {
      final firestore = _FakeFirestore();
      final dataSource = EstateDetailsRemoteDataSourceImpl(firestore);

      await dataSource.addFavorite('user-123', 'estate-456');

      expect(firestore.lastWrittenPath, 'users/user-123/favorites/estate-456');
      expect(firestore.lastWrittenData, containsPair('estateId', 'estate-456'));
      expect(firestore.lastWrittenData?['addedAt'], isA<FieldValue>());
    },
  );

  test('deletes the same user-scoped favorite document', () async {
    final firestore = _FakeFirestore();
    final dataSource = EstateDetailsRemoteDataSourceImpl(firestore);

    await dataSource.removeFavorite('user-123', 'estate-456');

    expect(firestore.lastDeletedPath, 'users/user-123/favorites/estate-456');
  });
}

class _FakeFirestore implements FirebaseFirestore {
  String? lastWrittenPath;
  Map<String, dynamic>? lastWrittenData;
  String? lastDeletedPath;

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) =>
      _FakeCollectionReference(collectionPath, this);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: subtype_of_sealed_class
class _FakeCollectionReference
    implements CollectionReference<Map<String, dynamic>> {
  _FakeCollectionReference(this.path, this.firestore);

  @override
  final String path;
  @override
  final _FakeFirestore firestore;

  @override
  DocumentReference<Map<String, dynamic>> doc([String? documentPath]) =>
      _FakeDocumentReference(
        documentPath == null || documentPath.isEmpty
            ? path
            : '$path/$documentPath',
        firestore,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: subtype_of_sealed_class
class _FakeDocumentReference
    implements DocumentReference<Map<String, dynamic>> {
  _FakeDocumentReference(this.path, this.firestore);

  @override
  final String path;

  @override
  final _FakeFirestore firestore;

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) =>
      _FakeCollectionReference('$path/$collectionPath', firestore);

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    firestore.lastWrittenPath = path;
    firestore.lastWrittenData = data;
  }

  @override
  Future<void> delete() async {
    firestore.lastDeletedPath = path;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
