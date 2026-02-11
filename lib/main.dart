import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'data/local_storage_service.dart';
import 'viewmodels/home_view_model.dart';
import 'views/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        theme: AppTheme.light(),
        home: const DashboardScreen(),
      ),
    );
  }
}
