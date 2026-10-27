import 'package:equatable/equatable.dart';

class ConversationEntity extends Equatable {
  final String id;
  final List<String> participants;
  final String customerId;
  final String agentUserId;
  final String agentId;
  final String? estateId;
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
    createdAt,
    lastMessage,
    lastMessageAt,
    lastSenderId,
    lastReadAtByParticipant,
  ];
}
