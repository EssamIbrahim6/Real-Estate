import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/core/errors/failures.dart';
import 'package:real_estate_app/core/utils/typedefs.dart';
import 'package:real_estate_app/features/chat/domain/entities/conversation_entity.dart';
import 'package:real_estate_app/features/chat/domain/entities/chat_launch_request.dart';
import 'package:real_estate_app/features/chat/domain/entities/message_entity.dart';
import 'package:real_estate_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:real_estate_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:real_estate_app/features/chat/presentation/cubit/chat_state.dart';
import 'package:real_estate_app/features/estate/domain/entities/estate_entity.dart';
import 'package:real_estate_app/features/estate/domain/repositories/estate_repository.dart';

void main() {
  test(
    'permission-denied stream errors are not reported as auth failures',
    () async {
      final repository = _FakeChatRepository();
      final cubit = ChatCubit(chatRepository: repository);
      await cubit.watchConversations('customer-uid');

      repository.conversationController.addError(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      );
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.conversationsFailure, isA<ServerFailure>());
      expect(cubit.state.conversationsFailure, isNot(isA<AuthFailure>()));
      expect(
        cubit.state.conversationsFailure?.message,
        'You do not have permission to access this chat.',
      );

      await cubit.close();
      await repository.conversationController.close();
      await repository.messageController.close();
    },
  );

  test('empty user IDs are rejected before subscribing', () async {
    final repository = _FakeChatRepository();
    final cubit = ChatCubit(chatRepository: repository);

    await cubit.watchConversations('  ');

    expect(cubit.state.conversationsFailure, isA<ValidationFailure>());
    expect(repository.conversationWatchCount, 0);
    await cubit.close();
    await repository.conversationController.close();
    await repository.messageController.close();
  });

  test(
    'deduplicates subscriptions, retries stream errors, and cancels on close',
    () async {
      final repository = _FakeChatRepository();
      final cubit = ChatCubit(chatRepository: repository);

      await cubit.watchConversations('customer-uid');
      await cubit.watchConversations('customer-uid');
      await cubit.watchMessages('conversation-id');
      await cubit.watchMessages('conversation-id');

      expect(repository.conversationWatchCount, 1);
      expect(repository.messageWatchCount, 1);
      expect(repository.conversationController.hasListener, isTrue);
      expect(repository.messageController.hasListener, isTrue);

      repository.conversationController.addError(StateError('stream failed'));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.conversationsStatus, ChatLoadStatus.failure);

      await cubit.watchConversations('customer-uid');
      expect(repository.conversationWatchCount, 2);

      await cubit.close();
      expect(repository.conversationController.hasListener, isFalse);
      expect(repository.messageController.hasListener, isFalse);

      await repository.conversationController.close();
      await repository.messageController.close();
    },
  );

  test('discards a late conversation preview after the user changes', () async {
    final repository = _FakeChatRepository();
    final estates = _DelayedEstateRepository();
    final cubit = ChatCubit(
      chatRepository: repository,
      estateRepository: estates,
    );

    await cubit.watchConversations('first-user');
    repository.conversationController.add([
      const ConversationEntity(
        id: 'shared-conversation',
        participants: ['first-user', 'agent-user'],
        customerId: 'first-user',
        agentUserId: 'agent-user',
        agentId: 'agent-document',
        estateId: 'estate-id',
      ),
    ]);
    await Future<void>.delayed(Duration.zero);

    await cubit.watchConversations('second-user');
    estates.complete(_estate());
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.estatePreviews, isEmpty);

    await cubit.close();
    await repository.conversationController.close();
    await repository.messageController.close();
  });
}

class _FakeChatRepository implements ChatRepository {
  final conversationController =
      StreamController<List<ConversationEntity>>.broadcast();
  final messageController = StreamController<List<MessageEntity>>.broadcast();
  int conversationWatchCount = 0;
  int messageWatchCount = 0;

  @override
  ResultFuture<ConversationEntity> getOrCreateConversation({
    required String customerUid,
    required String agentUserUid,
    required String agentId,
    required String estateId,
  }) async => (
    failure: null,
    data: ConversationEntity(
      id: 'conversation-id',
      participants: [customerUid, agentUserUid],
      customerId: customerUid,
      agentUserId: agentUserUid,
      agentId: agentId,
      estateId: estateId,
    ),
  );

  @override
  ResultFuture<ConversationEntity?> getConversation(
    String conversationId,
  ) async => (
    failure: null,
    data: const ConversationEntity(
      id: 'conversation-id',
      participants: ['customer-uid', 'agent-uid'],
      customerId: 'customer-uid',
      agentUserId: 'agent-uid',
      agentId: 'agent-document-id',
      estateId: 'estate-id',
    ),
  );

  @override
  Stream<List<ConversationEntity>> watchConversations(String currentUserUid) {
    conversationWatchCount++;
    return conversationController.stream;
  }

  @override
  Stream<List<MessageEntity>> watchMessages(String conversationId) {
    messageWatchCount++;
    return messageController.stream;
  }

  @override
  ResultVoid sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
    ChatLaunchRequest? launchRequest,
  }) async => (failure: null, isSuccess: true);

  @override
  ResultVoid archiveConversation({
    required String conversationId,
    required String participantUid,
  }) async => (failure: null, isSuccess: true);

  @override
  ResultVoid deleteMessageForMe({
    required String conversationId,
    required String messageId,
    required String participantUid,
  }) async => (failure: null, isSuccess: true);

  @override
  ResultVoid markConversationAsRead({
    required String conversationId,
    required String participantUid,
  }) async => (failure: null, isSuccess: true);
}

class _DelayedEstateRepository implements EstateRepository {
  final Completer<({Failure? failure, EstateEntity? data})> _estateResult =
      Completer();

  void complete(EstateEntity estate) {
    _estateResult.complete((failure: null, data: estate));
  }

  @override
  ResultFuture<EstateEntity> getEstateById(String id) => _estateResult.future;

  @override
  ResultFuture<List<EstateEntity>> getEstates({
    String? categoryId,
    String? city,
    int? limit,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    int? bathrooms,
    bool? isFurnished,
    String? listingType,
    bool? isAvailable,
  }) async => (failure: null, data: const <EstateEntity>[]);

  @override
  ResultFuture<List<EstateEntity>> getEstatesByAgentId(String agentId) async =>
      (failure: null, data: const <EstateEntity>[]);

  @override
  ResultFuture<List<EstateEntity>> getFeaturedEstates() async =>
      (failure: null, data: const <EstateEntity>[]);

  @override
  ResultFuture<String> createEstate(EstateEntity estate) async =>
      (failure: null, data: estate.id);

  @override
  ResultFuture<List<EstateEntity>> getEstatesByOwnerId(String ownerId) async =>
      (failure: null, data: const <EstateEntity>[]);

  @override
  ResultVoid deleteEstate({
    required String estateId,
    required String currentUid,
  }) async => (failure: null, isSuccess: true);
}

EstateEntity _estate() => const EstateEntity(
  id: 'estate-id',
  title: 'Estate',
  description: '',
  price: 100,
  listingType: 'sale',
  categoryId: 'category',
  agentId: 'agent-document',
  location: EstateLocationEntity(
    address: '',
    city: '',
    latitude: 0,
    longitude: 0,
  ),
  coverImage: '',
  images: [],
  bedrooms: 0,
  bathrooms: 0,
  area: 0,
  isFurnished: false,
  amenities: [],
  rating: 0,
  reviewCount: 0,
  isFeatured: false,
  isAvailable: true,
  status: 'active',
);
