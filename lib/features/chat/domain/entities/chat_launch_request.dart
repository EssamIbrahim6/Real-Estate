import 'dart:convert';

import 'package:equatable/equatable.dart';

class ChatLaunchRequest extends Equatable {
  const ChatLaunchRequest({
    required this.customerUid,
    required this.agentUserUid,
    required this.agentId,
    required this.estateId,
  });

  final String customerUid;
  final String agentUserUid;
  final String agentId;
  final String estateId;

  String get conversationId {
    final encodedPair = base64Url
        .encode(utf8.encode(jsonEncode([customerUid, agentUserUid])))
        .replaceAll('=', '');
    return 'conversation_$encodedPair';
  }

  @override
  List<Object?> get props => [customerUid, agentUserUid, agentId, estateId];
}
