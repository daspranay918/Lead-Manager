import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/lead_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LeadManagerApp());
}

class LeadManagerApp extends StatelessWidget {
  const LeadManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LeadProvider()..loadLeads()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Lead Manager',

            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              primarySwatch: Colors.blue,
            ),

            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
            ),

            themeMode: themeProvider.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
