import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../services/notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await NotificationService().initNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TodoProvider(),
      child: MaterialApp(
        title: 'Todo App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            primary: Colors.deepOrange,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

