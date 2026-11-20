import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/connectivity_service.dart';



class ConnectivityState extends Equatable {
  final ConnectivityStatus status;

  const ConnectivityState({this.status = ConnectivityStatus.checking});

  bool get isConnected => status == ConnectivityStatus.connected;

  @override
  List<Object?> get props => [status];
}

enum ConnectivityStatus { checking, connected, disconnected }


class ConnectivityCubit extends Cubit<ConnectivityState> {
  final ConnectivityService service;
  StreamSubscription<bool>? _subscription;
  int _statusGeneration = 0;

  ConnectivityCubit({required this.service})
    : super(const ConnectivityState()) {
    unawaited(_init());
  }

  Future<void> _init() async {
    try {
      _subscription = service.onStatusChange.listen(
        _onStatusChanged,
        onError: (Object error, StackTrace stackTrace) {
          _logConnectivityError('status stream', error, stackTrace);
        },
      );
    } catch (error, stackTrace) {
      _logConnectivityError('status stream subscription', error, stackTrace);
    }
    await retryConnectivity(source: 'initial check');
  }

  Future<void> retryConnectivity({String source = 'retry'}) async {
    final generation = ++_statusGeneration;
    emit(const ConnectivityState(status: ConnectivityStatus.checking));
    try {
      final connected = await service.checkConnectivity().timeout(
        const Duration(seconds: 10),
      );
      if (!isClosed && generation == _statusGeneration) {
        _updateStatus(connected);
      }
    } catch (error, stackTrace) {
      _logConnectivityError(source, error, stackTrace);
      if (!isClosed && generation == _statusGeneration) {
        _updateStatus(false);
      }
    }
  }

  void _onStatusChanged(bool connected) {
    if (isClosed) return;
    ++_statusGeneration;
    _updateStatus(connected);
  }

  void _updateStatus(bool connected) {
    final status = connected
        ? ConnectivityStatus.connected
        : ConnectivityStatus.disconnected;
    if (isClosed || state.status == status) return;
    emit(ConnectivityState(status: status));
  }

  void _logConnectivityError(
    String source,
    Object error,
    StackTrace stackTrace,
  ) {
    if (!kDebugMode) return;
    debugPrint('Connectivity $source failed: $error');
    debugPrint('Stack trace:\n$stackTrace');
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
