import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'features/accounts/providers/account_providers.dart';
import 'features/settings/providers/personalisation_provider.dart';
import 'features/settings/providers/settings_provider.dart';
import 'navigation/main_navigation_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive dark system UI overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: GrivnaApp(),
    ),
  );
}

class GrivnaApp extends ConsumerStatefulWidget {
  const GrivnaApp({super.key});

  @override
  ConsumerState<GrivnaApp> createState() => _GrivnaAppState();
}

class _GrivnaAppState extends ConsumerState<GrivnaApp> {
  @override
  void initState() {
    super.initState();
    // Background init: seed default demo data if first launch and sync live rates
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final repo = ref.read(accountRepositoryProvider);
        final accounts = await repo.getAllAccounts();
        if (accounts.isEmpty) {
          await repo.seedDemoData();
        }
        await ref.read(syncNotifierProvider.notifier).syncAll();
      } catch (e) {
        debugPrint('App startup init error: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final personalisation = ref.watch(personalisationProvider);

    return MaterialApp(
      title: 'grivna',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: personalisation.accentColor,
        colorScheme: ColorScheme.dark(
          primary: personalisation.accentColor,
          secondary: AppColors.textSecondary,
          surface: AppColors.surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.borderSubtle,
          thickness: 1,
        ),
      ),
      home: const MainNavigationShell(),
    );
  }
}
