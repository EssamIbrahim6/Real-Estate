import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// A thin wrapper around [InternetConnection] that provides a single
/// synchronous [isConnected] check and an event stream.
///
/// IMPORTANT: A `true` result means the device can reach an external host —
/// it does NOT guarantee that Firebase / Firestore is reachable. Treat this
/// as a best-effort offline indicator only.
abstract class ConnectivityService {
  /// Whether the device is currently online.
  bool get isConnected;

  /// Stream that emits `true` when a connection is restored and `false`
  /// when it is lost.
  Stream<bool> get onStatusChange;

  /// Performs a one-off connectivity check.
  Future<bool> checkConnectivity();
}

class ConnectivityServiceImpl implements ConnectivityService {
  final InternetConnection _checker;
  bool _isConnected = true; // optimistic default

  ConnectivityServiceImpl({InternetConnection? checker})
      : _checker = checker ?? InternetConnection();

  @override
  bool get isConnected => _isConnected;

  @override
  Stream<bool> get onStatusChange => _checker.onStatusChange.map((status) {
        _isConnected = status == InternetStatus.connected;
        return _isConnected;
      });

  @override
  Future<bool> checkConnectivity() async {
    _isConnected = await _checker.hasInternetAccess;
    return _isConnected;
  }
}

