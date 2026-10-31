import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _dataSource;

  NotificationRepositoryImpl(this._dataSource);

  @override
  ResultVoid createNotification(NotificationEntity notification) async {
    try {
      await _dataSource.createNotification(notification);
      return (failure: null, isSuccess: true);
    } on FirebaseException catch (e) {
      return (
        failure: ServerFailure(
          message: e.message ?? 'Failed to create notification.',
        ),
        isSuccess: false,
      );
    } catch (e) {
      return (failure: ServerFailure(message: e.toString()), isSuccess: false);
    }
  }

  @override
  Stream<List<NotificationEntity>> watchForUser(String uid) {
    return _dataSource.watchForUser(uid);
  }

  @override
  ResultVoid markAsRead(String notificationId) async {
    try {
      await _dataSource.markAsRead(notificationId);
      return (failure: null, isSuccess: true);
    } on FirebaseException catch (e) {
      return (
        failure: ServerFailure(message: e.message ?? 'Failed to mark as read.'),
        isSuccess: false,
      );
    } catch (e) {
      return (failure: ServerFailure(message: e.toString()), isSuccess: false);
    }
  }

  @override
  ResultVoid markAllAsRead(String uid) async {
    try {
      await _dataSource.markAllAsRead(uid);
      return (failure: null, isSuccess: true);
    } on FirebaseException catch (e) {
      return (
        failure: ServerFailure(
          message: e.message ?? 'Failed to mark all as read.',
        ),
        isSuccess: false,
      );
    } catch (e) {
      return (failure: ServerFailure(message: e.toString()), isSuccess: false);
    }
  }

  @override
  Future<int> getUnreadCount(String uid) async {
    try {
      return await _dataSource.getUnreadCount(uid);
    } catch (_) {
      return 0;
    }
  }
}

