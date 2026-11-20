import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';


abstract class ConnectivityService {
 
  bool get isConnected;


  Stream<bool> get onStatusChange;


  Future<bool> checkConnectivity();
}

class ConnectivityServiceImpl implements ConnectivityService {
  final InternetConnection _checker;
  bool _isConnected = false;

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
