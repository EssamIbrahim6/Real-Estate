import '../../../../core/utils/typedefs.dart';
import '../entities/agent_entity.dart';

abstract class AgentRepository {
  ResultFuture<List<AgentEntity>> getTopAgents({int limit = 10});
  ResultFuture<AgentEntity> getAgentById(String id);
}
