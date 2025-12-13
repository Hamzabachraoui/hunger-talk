import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/stock_provider.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/providers/recipe_provider.dart';
import 'core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser la configuration (charge l'URL depuis SharedPreferences)
  await AppConfig.initialize();
  
  runApp(const HungerTalkApp());
}

class HungerTalkApp extends StatelessWidget {
  const HungerTalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
      ],
      child: MaterialApp.router(
        title: 'Hunger-Talk',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}

