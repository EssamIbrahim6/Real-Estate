import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_data_source.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;

  const CategoryRepositoryImpl(this._remoteDataSource);

  @override
  ResultFuture<List<CategoryEntity>> getCategories() async {
    try {
      final categories = await _remoteDataSource.getCategories();
      return (failure: null, data: categories);
    } on ServerException catch (error) {
      return (failure: ServerFailure(message: error.message), data: null);
    } catch (error) {
      return (failure: ServerFailure(message: error.toString()), data: null);
    }
  }

  @override
  ResultFuture<CategoryEntity> getCategoryById(String id) async {
    try {
      final category = await _remoteDataSource.getCategoryById(id);
      return (failure: null, data: category);
    } on ServerException catch (error) {
      return (failure: ServerFailure(message: error.message), data: null);
    } catch (error) {
      return (failure: ServerFailure(message: error.toString()), data: null);
    }
  }
}
