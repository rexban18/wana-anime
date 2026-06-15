import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'utils/constants.dart';
import 'router/app_router.dart';
import 'providers/connectivity_provider.dart';
import 'screens/no_internet_screen.dart';

class WanaAnimeApp extends ConsumerWidget {
  const WanaAnimeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final connectivity = ref.watch(connectivityProvider);

    return MaterialApp.router(
      title: 'WanaAnime',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.primaryLight,
          error: AppColors.error,
          surface: AppColors.surface,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        fontFamily: 'Inter',
      ),
      routerConfig: router,
      builder: (context, child) {
        return connectivity.when(
          data: (isOnline) {
            if (!isOnline) {
              return NoInternetScreen(
                onRetry: () => ref.invalidate(connectivityProvider),
              );
            }
            return child ?? const SizedBox.shrink();
          },
          error: (_, __) => child ?? const SizedBox.shrink(),
          loading: () => child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
