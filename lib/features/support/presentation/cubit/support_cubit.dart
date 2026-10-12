import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/faq_item.dart';

class SupportState extends Equatable {
  final List<FaqItem> allFaqs;
  final List<FaqItem> filteredFaqs;
  final FaqCategory selectedCategory;
  final String searchQuery;

  const SupportState({
    required this.allFaqs,
    required this.filteredFaqs,
    this.selectedCategory = FaqCategory.buyer,
    this.searchQuery = '',
  });

  SupportState copyWith({
    List<FaqItem>? allFaqs,
    List<FaqItem>? filteredFaqs,
    FaqCategory? selectedCategory,
    String? searchQuery,
  }) {
    return SupportState(
      allFaqs: allFaqs ?? this.allFaqs,
      filteredFaqs: filteredFaqs ?? this.filteredFaqs,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    allFaqs,
    filteredFaqs,
    selectedCategory,
    searchQuery,
  ];
}

class SupportCubit extends Cubit<SupportState> {
  SupportCubit()
    : super(
        const SupportState(
          allFaqs: _defaultFaqs,
          filteredFaqs: [],
          selectedCategory: FaqCategory.buyer,
        ),
      ) {
    _filter();
  }

  static const List<FaqItem> _defaultFaqs = [
    FaqItem(
      id: '1',
      question: 'What is the booking fee?',
      answer: 'The booking fee is an initial deposit required to secure your selected property while the final agreement is prepared.',
      category: FaqCategory.buyer,
    ),
    FaqItem(
      id: '2',
      question: 'How do I schedule a property viewing?',
      answer: 'Select any listing and tap "Schedule Visit" to pick an available date and time with the representative agent.',
      category: FaqCategory.buyer,
    ),
    FaqItem(
      id: '3',
      question: 'Can I cancel a reservation?',
      answer: 'Yes, reservations can be cancelled up to 48 hours in advance for a full refund through the My Bookings section.',
      category: FaqCategory.buyer,
    ),
    FaqItem(
      id: '4',
      question: 'How to list a new property?',
      answer: 'Navigate to your Agent Dashboard, tap "+ Add Property", upload photos, enter property specifications, and submit for verification.',
      category: FaqCategory.estateAgent,
    ),
    FaqItem(
      id: '5',
      question: 'What are the listing fees for agents?',
      answer: 'Basic listings are free. Premium highlighted placements are billed per 30-day listing cycle.',
      category: FaqCategory.estateAgent,
    ),
  ];

  void selectCategory(FaqCategory category) {
    emit(state.copyWith(selectedCategory: category));
    _filter();
  }

  void search(String query) {
    emit(state.copyWith(searchQuery: query));
    _filter();
  }

  void _filter() {
    final query = state.searchQuery.trim().toLowerCase();
    final results = state.allFaqs.where((faq) {
      final matchesCategory = faq.category == state.selectedCategory;
      final matchesQuery =
          query.isEmpty ||
          faq.question.toLowerCase().contains(query) ||
          faq.answer.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    emit(state.copyWith(filteredFaqs: results));
  }
}
