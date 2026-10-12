import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:real_estate_app/features/agent/data/datasources/agent_remote_data_source.dart';
import 'package:real_estate_app/features/agent/data/repositories/agent_repository_impl.dart';
import 'package:real_estate_app/features/agent/domain/repositories/agent_repository.dart';
import 'package:real_estate_app/features/agent/presentation/cubit/agent_details_cubit.dart';
import 'package:real_estate_app/features/estate/data/datasources/estate_remote_data_source.dart';
import 'package:real_estate_app/features/estate/data/repositories/estate_repository_impl.dart';
import 'package:real_estate_app/features/estate/domain/repositories/estate_repository.dart';
import 'package:real_estate_app/features/estate_details/data/datasources/estate_details_remote_data_source.dart';
import 'package:real_estate_app/features/estate_details/data/repositories/estate_details_repository_impl.dart';
import 'package:real_estate_app/features/estate_details/domain/repositories/estate_details_repository.dart';
import 'package:real_estate_app/features/estate_details/presentation/cubit/estate_details_cubit.dart';
import 'package:real_estate_app/features/category/data/datasources/category_remote_data_source.dart';
import 'package:real_estate_app/features/category/data/repositories/category_repository_impl.dart';
import 'package:real_estate_app/features/category/domain/repositories/category_repository.dart';
import 'package:real_estate_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:real_estate_app/features/listing/presentation/cubit/listing_cubit.dart';
import 'package:real_estate_app/features/search/data/repositories/search_repository_impl.dart';
import 'package:real_estate_app/features/search/domain/repositories/search_repository.dart';
import 'package:real_estate_app/features/search/presentation/cubit/search_cubit.dart';
import 'package:real_estate_app/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:real_estate_app/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:real_estate_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:real_estate_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:real_estate_app/features/map/presentation/cubit/map_cubit.dart';

// Connectivity
import '../../core/cubits/connectivity/connectivity_cubit.dart';
import '../../core/services/connectivity_service.dart';

// ============================================================
// Core Services
// ============================================================

import '../../core/services/cloudinary_service.dart';

// ============================================================
// Auth
// ============================================================

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

// ============================================================
// Support
// ============================================================

import '../../features/support/presentation/cubit/support_cubit.dart';

// ============================================================
// Account Setup
// ============================================================

import '../../features/account_setup/data/datasources/account_setup_remote_data_source.dart';
import '../../features/account_setup/data/repositories/account_setup_repository_impl.dart';
import '../../features/account_setup/domain/repositories/account_setup_repository.dart';
import '../../features/account_setup/domain/usecases/save_account_setup_usecase.dart';
import '../../features/account_setup/presentation/cubit/account_setup_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // ============================================================
  // EXTERNAL
  // ============================================================

  // Firebase Authentication
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // Firebase Firestore
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Google Sign In
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);

  // Connectivity
  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityServiceImpl(),
  );

  // ============================================================
  // CLOUDINARY
  // ============================================================

  // Used for profile image upload.
  //
  // IMPORTANT:
  // The image itself is uploaded to Cloudinary.
  // Only the returned Cloudinary URL is stored in Firestore.
  sl.registerLazySingleton<CloudinaryService>(
    () => const CloudinaryServiceImpl(),
  );

  // ============================================================
  // AUTH DATA SOURCE
  // ============================================================

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), googleSignIn: sl()),
  );

  // ============================================================
  // AUTH REPOSITORY
  // ============================================================

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // ============================================================
  // AUTH USE CASES
  // ============================================================

  sl.registerLazySingleton(() => LoginUseCase(sl()));

  sl.registerLazySingleton(() => RegisterUseCase(sl()));

  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));

  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));

  sl.registerLazySingleton(() => ResendOtpUseCase(sl()));

  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));

  sl.registerLazySingleton(() => FacebookSignInUseCase(sl()));

  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // ============================================================
  // ACCOUNT SETUP DATA SOURCE
  // ============================================================

  sl.registerLazySingleton<AccountSetupRemoteDataSource>(
    () => AccountSetupRemoteDataSourceImpl(
      firestore: sl(),
      cloudinaryService: sl(),
    ),
  );

  // ============================================================
  // ACCOUNT SETUP REPOSITORY
  // ============================================================

  sl.registerLazySingleton<AccountSetupRepository>(
    () => AccountSetupRepositoryImpl(sl()),
  );

  // ============================================================
  // ACCOUNT SETUP USE CASE
  // ============================================================

  sl.registerLazySingleton(() => SaveAccountSetupUseCase(sl()));

  // ============================================================
  // CUBITS
  // ============================================================

  // Auth Cubit
  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl(),
      registerUseCase: sl(),
      forgotPasswordUseCase: sl(),
      verifyOtpUseCase: sl(),
      resendOtpUseCase: sl(),
      googleSignInUseCase: sl(),
      facebookSignInUseCase: sl(),
      getCurrentUserUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  // Account Setup Cubit
  //
  // Registered as Factory because every Account Setup flow
  // should get a fresh Cubit instance.
  //
  // The ShellRoute creates ONE instance and keeps it shared
  // across all Account Setup screens.
  sl.registerFactory(
    () => AccountSetupCubit(saveUseCase: sl(), firebaseAuth: sl()),
  );

  // Support Cubit
  sl.registerFactory(() => SupportCubit());
  sl.registerFactory(
    () => ConnectivityCubit(service: sl<ConnectivityService>()),
  );
  // ============================================================
  // ESTATE DATA SOURCE & REPOSITORY
  // ============================================================
  sl.registerLazySingleton<EstateRemoteDataSource>(
    () => EstateRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<EstateRepository>(() => EstateRepositoryImpl(sl()));
  sl.registerLazySingleton<SearchRepository>(() => SearchRepositoryImpl(sl()));

  // Chat data source and repository
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl()));

  // Agent Data Source & Repository
  sl.registerLazySingleton<AgentRemoteDataSource>(
    () => AgentRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AgentRepository>(() => AgentRepositoryImpl(sl()));

  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl()),
  );

  // Home Cubit
  sl.registerFactory(
    () => HomeCubit(
      estateRepository: sl(),
      agentRepository: sl(),
      categoryRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => ListingCubit(estateRepository: sl(), categoryRepository: sl()),
  );
  sl.registerFactory(
    () => SearchCubit(searchRepository: sl(), categoryRepository: sl()),
  );
  sl.registerFactory(() => ChatCubit(chatRepository: sl()));
  sl.registerFactory(() => MapCubit(estateRepository: sl()));
  // ============================================================
  // ESTATE DETAILS & REVIEWS
  // ============================================================
  sl.registerLazySingleton<EstateDetailsRemoteDataSource>(
    () => EstateDetailsRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<EstateDetailsRepository>(
    () => EstateDetailsRepositoryImpl(sl()),
  );

  sl.registerFactory(
    () => EstateDetailsCubit(
      estateRepository: sl(),
      agentRepository: sl(),
      estateDetailsRepository: sl(),
      firebaseAuth: sl(),
      chatRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => AgentDetailsCubit(
      agentRepository: sl(),
      estateRepository: sl(),
    ),
  );
}
