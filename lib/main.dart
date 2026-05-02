import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'login_screen.dart';
import 'theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await EasyLocalization.ensureInitialized();

  runApp(
    // Uygulama ayağa kalkarken MultiProvider ile sarmalanarak
    // global State Management mimarisi kurulmuştur.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: EasyLocalization(
        supportedLocales: const [Locale('tr'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('tr'),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Tema durumunu canlı olarak dinliyoruz
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Piton Tracker',
      // Provider'dan gelen veriye göre
      // uygulamanın karanlık veya aydınlık modda başlaması sağlanır.
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(primary: Colors.blueGrey),
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const LoginScreen(),
    );
  }
}