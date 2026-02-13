import 'package:get_it/get_it.dart';
import '../network/api_client.dart';

import '../../features/appliances/data/datasources/appliances_remote_ds.dart';
import '../../features/appliances/data/repositories/appliances_repo_impl.dart';
import '../../features/appliances/domain/repositories/appliances_repo.dart';
import '../../features/appliances/domain/usecases/get_appliances.dart';
import '../../features/appliances/domain/usecases/add_appliance.dart';
import '../../features/appliances/domain/usecases/update_appliance.dart';
import '../../features/appliances/domain/usecases/delete_appliance.dart';
import '../../features/appliances/presentation/bloc/appliances_bloc.dart';

import '../../features/preferences/data/datasources/preferences_remote_ds.dart';
import '../../features/preferences/data/repositories/preferences_repo_impl.dart';
import '../../features/preferences/domain/repositories/preferences_repo.dart';
import '../../features/preferences/domain/usecases/get_preferences.dart';
import '../../features/preferences/domain/usecases/update_preferences.dart';
import '../../features/preferences/presentation/bloc/preferences_bloc.dart';

import '../../features/optimization/data/datasources/optimization_remote_ds.dart';
import '../../features/optimization/data/repositories/optimization_repo_impl.dart';
import '../../features/optimization/domain/repositories/optimization_repo.dart';
import '../../features/optimization/domain/usecases/run_optimization.dart';
import '../../features/optimization/presentation/bloc/optimization_bloc.dart';

import '../../features/dashboard/data/datasources/dashboard_remote_ds.dart';
import '../../features/dashboard/data/repositories/dashboard_repo_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repo.dart';
import '../../features/dashboard/domain/usecases/get_dashboard.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';

import '../../features/analytics/data/datasources/analytics_remote_ds.dart';
import '../../features/analytics/data/repositories/analytics_repo_impl.dart';
import '../../features/analytics/domain/repositories/analytics_repo.dart';
import '../../features/analytics/domain/usecases/get_analytics.dart';
import '../../features/analytics/presentation/bloc/analytics_bloc.dart';

import '../../features/history/data/datasources/history_remote_ds.dart';
import '../../features/history/data/repositories/history_repo_impl.dart';
import '../../features/history/domain/repositories/history_repo.dart';
import '../../features/history/domain/usecases/get_history.dart';
import '../../features/history/presentation/bloc/history_bloc.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  // change to your machine IP for physical device
  sl.registerLazySingleton(() => ApiClient("http://127.0.0.1:8000"));

  // Appliances
  sl.registerLazySingleton<AppliancesRemoteDs>(() => AppliancesRemoteDs(sl()));
  sl.registerLazySingleton<AppliancesRepo>(() => AppliancesRepoImpl(sl()));
  sl.registerLazySingleton(() => GetAppliances(sl()));
  sl.registerLazySingleton(() => AddAppliance(sl()));
  sl.registerLazySingleton(() => UpdateAppliance(sl()));
  sl.registerLazySingleton(() => DeleteAppliance(sl()));
  sl.registerFactory(() => AppliancesBloc(
        getAppliances: sl(),
        addAppliance: sl(),
        updateAppliance: sl(),
        deleteAppliance: sl(),
      ));

  // Preferences
  sl.registerLazySingleton<PreferencesRemoteDs>(() => PreferencesRemoteDs(sl()));
  sl.registerLazySingleton<PreferencesRepo>(() => PreferencesRepoImpl(sl()));
  sl.registerLazySingleton(() => GetPreferences(sl()));
  sl.registerLazySingleton(() => UpdatePreferences(sl()));
  sl.registerFactory(() => PreferencesBloc(getPreferences: sl(), updatePreferences: sl()));

  // Optimization
  sl.registerLazySingleton<OptimizationRemoteDs>(() => OptimizationRemoteDs(sl()));
  sl.registerLazySingleton<OptimizationRepo>(() => OptimizationRepoImpl(sl()));
  sl.registerLazySingleton(() => RunOptimization(sl()));
  sl.registerFactory(() => OptimizationBloc(runOptimization: sl()));

  // Dashboard
  sl.registerLazySingleton<DashboardRemoteDs>(() => DashboardRemoteDs(sl()));
  sl.registerLazySingleton<DashboardRepo>(() => DashboardRepoImpl(sl()));
  sl.registerLazySingleton(() => GetDashboard(sl()));
  sl.registerFactory(() => DashboardBloc(getDashboard: sl()));

  // Analytics
  sl.registerLazySingleton<AnalyticsRemoteDs>(() => AnalyticsRemoteDs(sl()));
  sl.registerLazySingleton<AnalyticsRepo>(() => AnalyticsRepoImpl(sl()));
  sl.registerLazySingleton(() => GetAnalytics(sl()));
  sl.registerFactory(() => AnalyticsBloc(getAnalytics: sl()));

  // History
  sl.registerLazySingleton<HistoryRemoteDs>(() => HistoryRemoteDs(sl()));
  sl.registerLazySingleton<HistoryRepo>(() => HistoryRepoImpl(sl()));
  sl.registerLazySingleton(() => GetHistory(sl()));
  sl.registerFactory(() => HistoryBloc(getHistory: sl()));
}
