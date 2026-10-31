import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/services/notification_service.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<ConversationModel> getOrCreateConversation({
    required String customerUid,
    required String agentUserUid,
    required String agentId,
    required String estateId,
  });

  Stream<List<ConversationModel>> watchConversations(String currentUserUid);

  Stream<List<MessageModel>> watchMessages(String conversationId);

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  });

  Future<void> markConversationAsRead({
    required String conversationId,
    required String participantUid,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore _firestore;
  final NotificationService? _notificationService;

  const ChatRemoteDataSourceImpl(this._firestore, [this._notificationService]);

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _firestore.collection('conversations');

  @override
  Future<ConversationModel> getOrCreateConversation({
    required String customerUid,
    required String agentUserUid,
    required String agentId,
    required String estateId,
  }) async {
    final normalizedCustomerUid = customerUid.trim();
    final normalizedAgentUid = agentUserUid.trim();
    final normalizedAgentId = agentId.trim();
    final normalizedEstateId = estateId.trim();
    if (normalizedCustomerUid.isEmpty ||
        normalizedAgentUid.isEmpty ||
        normalizedAgentId.isEmpty ||
        normalizedEstateId.isEmpty) {
      throw ArgumentError(
        'Conversation participant and estate IDs are required.',
      );
    }
    if (normalizedCustomerUid == normalizedAgentUid) {
      throw ArgumentError(
        'A user cannot start a conversation with themselves.',
      );
    }

    final conversationId = _conversationIdFor(
      customerUid: normalizedCustomerUid,
      agentUserUid: normalizedAgentUid,
      estateId: normalizedEstateId,
    );
    final reference = _conversations.doc(conversationId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      if (snapshot.exists) {
        return ConversationModel.fromFirestore(snapshot);
      }

      final model = ConversationModel(
        id: conversationId,
        participants: [normalizedCustomerUid, normalizedAgentUid],
        customerId: normalizedCustomerUid,
        agentUserId: normalizedAgentUid,
        agentId: normalizedAgentId,
        estateId: normalizedEstateId,
      );
      transaction.set(reference, model.toFirestore());
      return model;
    });
  }

  @visibleForTesting
  static String conversationIdFor({
    required String customerUid,
    required String agentUserUid,
    required String estateId,
  }) => _conversationIdFor(
    customerUid: customerUid,
    agentUserUid: agentUserUid,
    estateId: estateId,
  );

  static String _conversationIdFor({
    required String customerUid,
    required String agentUserUid,
    required String estateId,
  }) {
    final encodedTuple = base64Url
        .encode(utf8.encode(jsonEncode([customerUid, agentUserUid, estateId])))
        .replaceAll('=', '');
    return 'conversation_$encodedTuple';
  }

  @override
  Stream<List<ConversationModel>> watchConversations(String currentUserUid) {
    return _conversations
        .where('participants', arrayContains: currentUserUid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ConversationModel.fromFirestore)
              .toList(growable: false),
        );
  }

  @override
  Stream<List<MessageModel>> watchMessages(String conversationId) {
    return _conversations
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(MessageModel.fromFirestore)
              .toList(growable: false),
        );
  }

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) {
      throw ArgumentError('Message text cannot be empty.');
    }

    final conversationReference = _conversations.doc(conversationId);
    final messageReference = conversationReference.collection('messages').doc();
    final batch = _firestore.batch();
    batch.set(
      messageReference,
      MessageModel(
        id: messageReference.id,
        senderId: senderId,
        text: normalizedText,
      ).toFirestore(),
    );
    batch.update(conversationReference, {
      'lastMessage': normalizedText,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastSenderId': senderId,
    });
    await batch.commit();

    try {
      final convDoc = await conversationReference.get();
      final participants =
          (convDoc.data()?['participants'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList();
      final recipientId = participants.firstWhere(
        (p) => p != senderId,
        orElse: () => '',
      );
      if (recipientId.isNotEmpty) {
        _notificationService?.notifyChatMessage(
          messageId: messageReference.id,
          recipientId: recipientId,
          senderName: 'Chat',
          conversationId: conversationId,
          messagePreview: normalizedText,
        );
      }
    } catch (_) {
      // Fire-and-forget notification
    }
  }

  @override
  Future<void> markConversationAsRead({
    required String conversationId,
    required String participantUid,
  }) {
    return _conversations.doc(conversationId).update({
      FieldPath(['lastReadAtByParticipant', participantUid]):
          FieldValue.serverTimestamp(),
    });
  }
}
