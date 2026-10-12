import '../../../../core/utils/typedefs.dart';
import '../../../estate/domain/entities/estate_entity.dart';
import '../entities/search_filter.dart';

abstract class SearchRepository {
  ResultFuture<List<EstateEntity>> search(SearchFilter filter);
}
