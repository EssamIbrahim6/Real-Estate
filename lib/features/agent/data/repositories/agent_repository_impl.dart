import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/agent_entity.dart';
import '../../domain/repositories/agent_repository.dart';
import '../datasources/agent_remote_data_source.dart';

class AgentRepositoryImpl implements AgentRepository {
  final AgentRemoteDataSource _remoteDataSource;

  const AgentRepositoryImpl(this._remoteDataSource);
  @override
  ResultFuture<AgentEntity> getAgentById(String id) async {
    try {
      final agent = await _remoteDataSource.getAgentById(id);
      return (failure: null, data: agent);
    } on ServerException catch (e) {
      return (failure: ServerFailure(message: e.message), data: null);
    } catch (e) {
      return (failure: ServerFailure(message: e.toString()), data: null);
    }
  }

  @override
  ResultFuture<List<AgentEntity>> getTopAgents({int limit = 10}) async {
    try {
      final agents = await _remoteDataSource.getTopAgents(limit: limit);
      return (failure: null, data: agents);
    } on ServerException catch (e) {
      return (failure: ServerFailure(message: e.message), data: null);
    } catch (e) {
      return (failure: ServerFailure(message: e.toString()), data: null);
    }
  }
}
