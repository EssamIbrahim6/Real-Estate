import 'package:equatable/equatable.dart';

class ConversationEntity extends Equatable {
  final String id;
  final List<String> participants;
  final String customerId;
  final String agentUserId;
  final String agentId;
  final String? estateId;
  final List<String> estateIds;
  final List<String> archivedBy;
  final DateTime? createdAt;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastSenderId;
  final Map<String, DateTime> lastReadAtByParticipant;

  const ConversationEntity({
    required this.id,
    required this.participants,
    required this.customerId,
    required this.agentUserId,
    required this.agentId,
    this.estateId,
    this.estateIds = const [],
    this.archivedBy = const [],
    this.createdAt,
    this.lastMessage,
    this.lastMessageAt,
    this.lastSenderId,
    this.lastReadAtByParticipant = const {},
  });

  @override
  List<Object?> get props => [
    id,
    participants,
    customerId,
    agentUserId,
    agentId,
    estateId,
    estateIds,
    archivedBy,
    createdAt,
    lastMessage,
    lastMessageAt,
    lastSenderId,
    lastReadAtByParticipant,
  ];
}
