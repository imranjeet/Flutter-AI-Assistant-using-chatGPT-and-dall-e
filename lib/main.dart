import 'package:flutter/material.dart';
import 'package:myassistant/services/custom_logger.dart';
import 'package:myassistant/services/db_services.dart';
import 'package:myassistant/views/home_screen.dart';
import 'package:myassistant/services/locator.dart';
import 'package:myassistant/my_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  CustomLogger.init();
  await locator<DBService>().open();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: MyColors.blackColor,
          appBarTheme: const AppBarTheme(backgroundColor: MyColors.blackColor)),
      home: const HomeScreen(),
    );
  }
}
