import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/services/notification_service.dart';
import '../../domain/entities/chat_launch_request.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<ConversationModel> getOrCreateConversation({
    required String customerUid,
    required String agentUserUid,
    required String agentId,
    required String estateId,
  });

  Future<ConversationModel?> getConversation(String conversationId);

  Stream<List<ConversationModel>> watchConversations(String currentUserUid);

  Stream<List<MessageModel>> watchMessages(String conversationId);

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
    ChatLaunchRequest? launchRequest,
  });

  Future<void> archiveConversation({
    required String conversationId,
    required String participantUid,
  });

  Future<void> deleteMessageForMe({
    required String conversationId,
    required String messageId,
    required String participantUid,
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
    );
    final reference = _conversations.doc(conversationId);
    final snapshot = await reference.get();
    if (snapshot.exists) return ConversationModel.fromFirestore(snapshot);

    return ConversationModel(
      id: conversationId,
      participants: [normalizedCustomerUid, normalizedAgentUid],
      customerId: normalizedCustomerUid,
      agentUserId: normalizedAgentUid,
      agentId: normalizedAgentId,
      estateId: normalizedEstateId,
      estateIds: [normalizedEstateId],
    );
  }

  @override
  Future<ConversationModel?> getConversation(String conversationId) async {
    final normalizedId = conversationId.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError('A conversation ID is required.');
    }

    final snapshot = await _conversations.doc(normalizedId).get();
    if (!snapshot.exists) {
      return null;
    }
    return ConversationModel.fromFirestore(snapshot);
  }

  @visibleForTesting
  static String conversationIdFor({
    required String customerUid,
    required String agentUserUid,
  }) =>
      _conversationIdFor(customerUid: customerUid, agentUserUid: agentUserUid);

  static String _conversationIdFor({
    required String customerUid,
    required String agentUserUid,
  }) => ChatLaunchRequest(
    customerUid: customerUid,
    agentUserUid: agentUserUid,
    agentId: '',
    estateId: '',
  ).conversationId;

  @override
  Stream<List<ConversationModel>> watchConversations(String currentUserUid) {
    return _conversations
        .where('participants', arrayContains: currentUserUid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ConversationModel.fromFirestore)
              .where(
                (conversation) =>
                    !conversation.archivedBy.contains(currentUserUid),
              )
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
    ChatLaunchRequest? launchRequest,
  }) async {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) {
      throw ArgumentError('Message text cannot be empty.');
    }

    final conversationReference = _conversations.doc(conversationId);
    final messageReference = conversationReference.collection('messages').doc();
    if (launchRequest != null) {
      if (launchRequest.conversationId != conversationId ||
          launchRequest.customerUid != senderId) {
        throw ArgumentError('The conversation request does not match sender.');
      }
      await _sendFirstMessage(
        conversationReference: conversationReference,
        messageReference: messageReference,
        launchRequest: launchRequest,
        text: normalizedText,
      );
      await _notifyRecipient(
        conversationReference: conversationReference,
        messageReference: messageReference,
        senderId: senderId,
        text: normalizedText,
        conversationId: conversationId,
      );
      return;
    }

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

    await _notifyRecipient(
      conversationReference: conversationReference,
      messageReference: messageReference,
      senderId: senderId,
      text: normalizedText,
      conversationId: conversationId,
    );
  }

  Future<void> _sendFirstMessage({
    required DocumentReference<Map<String, dynamic>> conversationReference,
    required DocumentReference<Map<String, dynamic>> messageReference,
    required ChatLaunchRequest launchRequest,
    required String text,
  }) async {
    final message = MessageModel(
      id: messageReference.id,
      senderId: launchRequest.customerUid,
      text: text,
    ).toFirestore();
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(conversationReference);
      if (snapshot.exists) {
        final existing = ConversationModel.fromFirestore(snapshot);
        final estateIds = <String>{
          ...existing.estateIds,
          launchRequest.estateId,
        }.toList(growable: false);
        transaction.update(conversationReference, {
          'estateIds': estateIds,
          'contextEstateId': launchRequest.estateId,
          'lastMessage': text,
          'lastMessageAt': FieldValue.serverTimestamp(),
          'lastSenderId': launchRequest.customerUid,
        });
      } else {
        transaction.set(conversationReference, {
          'participants': [
            launchRequest.customerUid,
            launchRequest.agentUserUid,
          ],
          'customerId': launchRequest.customerUid,
          'agentUserId': launchRequest.agentUserUid,
          'agentId': launchRequest.agentId,
          'estateId': launchRequest.estateId,
          'estateIds': [launchRequest.estateId],
          'contextEstateId': launchRequest.estateId,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': text,
          'lastMessageAt': FieldValue.serverTimestamp(),
          'lastSenderId': launchRequest.customerUid,
          'lastReadAtByParticipant': <String, dynamic>{},
          'archivedBy': <String>[],
          'firstMessageId': messageReference.id,
        });
      }
      transaction.set(messageReference, message);
    });
  }

  Future<void> _notifyRecipient({
    required DocumentReference<Map<String, dynamic>> conversationReference,
    required DocumentReference<Map<String, dynamic>> messageReference,
    required String senderId,
    required String text,
    required String conversationId,
  }) async {
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
        await _notificationService?.notifyChatMessage(
          messageId: messageReference.id,
          recipientId: recipientId,
          senderName: 'Chat',
          conversationId: conversationId,
          messagePreview: text,
        );
      }
    } catch (error, stackTrace) {
      debugPrint('Chat message notification failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Future<void> archiveConversation({
    required String conversationId,
    required String participantUid,
  }) => _conversations.doc(conversationId).update({
    'archivedBy': FieldValue.arrayUnion([participantUid]),
  });

  @override
  Future<void> deleteMessageForMe({
    required String conversationId,
    required String messageId,
    required String participantUid,
  }) => _conversations
      .doc(conversationId)
      .collection('messages')
      .doc(messageId)
      .update({
        'hiddenFor': FieldValue.arrayUnion([participantUid]),
      });

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
