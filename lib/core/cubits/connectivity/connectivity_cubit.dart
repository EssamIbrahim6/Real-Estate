import 'dart:async';

import 'package:equatable/equatable.dart';
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
/// Usage: Provide high in the widget tree (e.g., in [main.dart]) and read
/// with [BlocBuilder] or [BlocListener] to show a banner or disable actions.
class ConnectivityCubit extends Cubit<ConnectivityState> {
  final ConnectivityService _service;
  StreamSubscription<bool>? _subscription;

  ConnectivityCubit({required ConnectivityService service})
      : _service = service,
        super(const ConnectivityState()) {
    _init();
  }

  Future<void> _init() async {
    // Run an immediate check so the initial state reflects reality.
    final connected = await _service.checkConnectivity();
    if (!isClosed) emit(ConnectivityState(isConnected: connected));

    _subscription = _service.onStatusChange.listen((online) {
      if (!isClosed) emit(ConnectivityState(isConnected: online));
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}

