import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/api_service.dart';
import '../../data/datasources/remote/account_remote_datasource.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../domain/repositories/account_repository.dart';

/// Provide ApiService
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

/// Provide AccountRemoteDataSource
final accountRemoteDataSourceProvider = Provider<AccountRemoteDataSource>(
      (ref) => AccountRemoteDataSourceImpl(ref.read(apiServiceProvider)),
);

/// Provide AccountRepository (implementation)
final accountRepositoryProvider = Provider<AccountRepository>(
      (ref) => AccountRepositoryImpl(ref.read(accountRemoteDataSourceProvider)),
);
