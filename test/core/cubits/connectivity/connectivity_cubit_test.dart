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
}

class _FakeConnectivityService implements ConnectivityService {
  final statuses = StreamController<bool>.broadcast(sync: true);
  final checkResult = Completer<bool>();

  @override
  bool get isConnected => true;

  @override
  Stream<bool> get onStatusChange => statuses.stream;

  @override
  Future<bool> checkConnectivity() => checkResult.future;

  Future<void> close() => statuses.close();
}
