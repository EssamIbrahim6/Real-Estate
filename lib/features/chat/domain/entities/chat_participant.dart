import 'package:equatable/equatable.dart';

class ChatParticipant extends Equatable {
  const ChatParticipant({required this.name, this.photoUrl});

  final String name;
  final String? photoUrl;

  @override
  List<Object?> get props => [name, photoUrl];
}
