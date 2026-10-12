import '../../../../core/utils/typedefs.dart';
import '../entities/category_entity.dart';

abstract class CategoryRepository {
  ResultFuture<List<CategoryEntity>> getCategories();

  ResultFuture<CategoryEntity> getCategoryById(String id);
}
