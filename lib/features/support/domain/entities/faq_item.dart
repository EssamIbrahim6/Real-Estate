import 'package:equatable/equatable.dart';

enum FaqCategory { buyer, estateAgent }

class FaqItem extends Equatable {
  final String id;
  final String question;
  final String answer;
  final FaqCategory category;

  const FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
  });

  @override
  List<Object?> get props => [id, question, answer, category];
}
