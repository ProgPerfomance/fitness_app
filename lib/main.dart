import 'package:analytics_package/analytics_package.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'data/local_storage_service.dart';
import 'viewmodels/home_view_model.dart';
import 'views/app_shell_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Analytics.init(AnalyticsSdkConfig(projectId: "698d4d0e1bf33e30aeb46813",));
  await Analytics.trackOpenApp();
  runApp(const HomeFitApp());
}

class HomeFitApp extends StatelessWidget {
  const HomeFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(LocalStorageService())..init(),
      child: MaterialApp(
        title: 'HomeFit',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        home: const AppShellScreen(),
      ),
    );
  }
}
