import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:brain_boost/services/mock_api_service.dart';
import 'package:brain_boost/services/storage_service.dart';
import 'package:brain_boost/providers/auth_provider.dart';
import 'package:brain_boost/providers/game_provider.dart';
import 'package:brain_boost/providers/profile_provider.dart';
import 'package:brain_boost/theme/app_theme.dart';
import 'package:brain_boost/splash_screen.dart';

void main() {
  testWidgets('Brain Boost app renders splash screen', (WidgetTester tester) async {
    // Arrange: wire up the real services/providers (uses mock API, no network)
    final storage = StorageService();
    await storage.init();
    final api = MockApiService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider(api, storage)),
          ChangeNotifierProvider(create: (_) => GameProvider(api, storage)),
          ChangeNotifierProvider(create: (_) => ProfileProvider(api, storage)),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const SplashScreen(),
        ),
      ),
    );

    // Assert: splash screen is present (contains the Brain Boost logo text)
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
