import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/agent_model.dart';

abstract class AgentRemoteDataSource {
  Future<List<AgentModel>> getTopAgents({int limit = 10});
  Future<AgentModel> getAgentById(String id);
}

class AgentRemoteDataSourceImpl implements AgentRemoteDataSource {
  final FirebaseFirestore _firestore;

  const AgentRemoteDataSourceImpl(this._firestore);
  // In abstract class AgentRemoteDataSource:

  // In AgentRemoteDataSourceImpl:
  @override
  Future<AgentModel> getAgentById(String id) async {
    try {
      final doc = await _firestore.collection('agents').doc(id).get();
      if (!doc.exists) {
        throw const ServerException(message: 'Agent details not found');
      }
      return await _getAgentWithUserProfile(doc);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to load agent');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<AgentModel>> getTopAgents({int limit = 10}) async {
    try {
      final snapshot = await _firestore.collection('agents').limit(limit).get();

      final agents = await Future.wait(
        snapshot.docs.map(_getAgentWithUserProfile),
      );

      // Order in memory by rating descending and verified status
      agents.sort((a, b) {
        final ratingComp = b.rating.compareTo(a.rating);
        if (ratingComp != 0) return ratingComp;
        return (b.isVerified ? 1 : 0).compareTo(a.isVerified ? 1 : 0);
      });

      return agents;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to load agents');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<AgentModel> _getAgentWithUserProfile(
    DocumentSnapshot<Map<String, dynamic>> agentDoc,
  ) async {
    final agent = AgentModel.fromFirestore(agentDoc);
    if (agent.name.trim().isNotEmpty && agent.primaryPhotoUrl.isNotEmpty) {
      return agent;
    }

    final userId = agent.userId.trim();
    if (userId.isEmpty) return agent;

    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return agent;

    return AgentModel.fromFirestore(agentDoc, userProfile: userDoc.data());
  }
}
