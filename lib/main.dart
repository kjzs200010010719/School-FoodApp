import 'package:flutter/material.dart';
import 'package:my_app/screens/home_screen.dart';
import 'package:my_app/services/user_activity_service.dart';
import 'package:my_app/services/user_profile_service.dart';
import 'package:my_app/widgets/catalog_gate.dart';
import 'package:my_app/widgets/activity_messages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserProfileService.instance.initialize();
  await UserActivityService.instance.initialize();
  runApp(const MyApp());
}

//
// StatelessWidget(無狀態元件），本身不需要管理任何動態資料
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _messengerKey,
      builder: (context, child) =>
          ActivityMessages(messengerKey: _messengerKey, child: child!),
      debugShowCheckedModeBanner: false,
      title: '膳解人意',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4E8D57)),
        scaffoldBackgroundColor: const Color(0xFFF7F9F4),
      ),
      home: CatalogGate(
        onLoaded: UserActivityService.instance.initialize,
        child: const HomeScreen(),
      ),
    );
  }
}
