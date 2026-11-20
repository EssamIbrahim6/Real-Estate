import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/cubits/connectivity/connectivity_cubit.dart';
import 'package:real_estate_app/core/services/connectivity_service.dart';

void main() {
  test(
    'tracks offline and recovery states and cancels its subscription',
    () async {
      final service = _FakeConnectivityService();
      final cubit = ConnectivityCubit(service: service);
      addTearDown(service.close);

      service.checkResult.complete(true);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.isConnected, isTrue);

      service.statuses.add(false);
      expect(cubit.state.isConnected, isFalse);

      service.statuses.add(true);
      expect(cubit.state.isConnected, isTrue);

      await cubit.close();
      expect(service.statuses.hasListener, isFalse);
    },
  );

  test('a newer stream event wins over an in-flight initial check', () async {
    final service = _FakeConnectivityService();
    final cubit = ConnectivityCubit(service: service);
    addTearDown(service.close);
    addTearDown(cubit.close);

    service.statuses.add(false);
    service.checkResult.complete(true);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.isConnected, isFalse);
  });

  test(
    'retry blocks while checking and unlocks when internet returns',
    () async {
      final service = _FakeConnectivityService()..checkResult.complete(false);
      final cubit = ConnectivityCubit(service: service);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.isConnected, isFalse);

      final reconnectResult = Completer<bool>();
      service.nextCheckResult = reconnectResult;
      final retry = cubit.retryConnectivity();
      expect(cubit.state.status, ConnectivityStatus.checking);
      reconnectResult.complete(true);
      await retry;
      expect(cubit.state.isConnected, isTrue);

      await cubit.close();
      await service.close();
    },
  );
}

class _FakeConnectivityService implements ConnectivityService {
  final statuses = StreamController<bool>.broadcast(sync: true);
  Completer<bool> checkResult = Completer<bool>();
  Completer<bool>? nextCheckResult;

  @override
  bool get isConnected => true;

  @override
  Stream<bool> get onStatusChange => statuses.stream;

  @override
  Future<bool> checkConnectivity() {
    final next = nextCheckResult;
    if (next != null) {
      nextCheckResult = null;
      return next.future;
    }
    return checkResult.future;
  }

  Future<void> close() => statuses.close();
}
