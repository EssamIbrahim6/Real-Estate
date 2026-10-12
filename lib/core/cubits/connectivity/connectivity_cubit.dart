import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/connectivity_service.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class ConnectivityState extends Equatable {
  final bool isConnected;

  const ConnectivityState({this.isConnected = true});

  @override
  List<Object?> get props => [isConnected];
}

// ---------------------------------------------------------------------------
// Cubit
// ---------------------------------------------------------------------------

/// Listens to [ConnectivityService] and exposes online/offline state.
///
/// Usage: Provide high in the widget tree (e.g., in [app.dart]) and read
/// with [BlocBuilder] or [BlocListener] to show a banner or disable actions.
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
      final generation = _statusGeneration;
      _subscription = service.onStatusChange.listen(
        _onStatusChanged,
        onError: (Object error, StackTrace stackTrace) {
          _logConnectivityError('status stream', error, stackTrace);
        },
      );

      final connected = await service.checkConnectivity();
      if (!isClosed && generation == _statusGeneration) {
        _updateStatus(connected);
      }
    } catch (error, stackTrace) {
      _logConnectivityError('initial check', error, stackTrace);
    }
  }

  void _onStatusChanged(bool connected) {
    if (isClosed) return;
    ++_statusGeneration;
    _updateStatus(connected);
  }

  void _updateStatus(bool connected) {
    if (isClosed || state.isConnected == connected) return;
    emit(ConnectivityState(isConnected: connected));
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
