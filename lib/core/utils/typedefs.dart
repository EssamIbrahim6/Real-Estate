import '../errors/failures.dart';

typedef ResultFuture<T> = Future<({Failure? failure, T? data})>;
typedef ResultVoid = Future<({Failure? failure, bool isSuccess})>;
