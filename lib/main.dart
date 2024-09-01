import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:psw_journal_app/firebase_options.dart';
import 'package:psw_journal_app/pages/login/login.dart';
import 'package:psw_journal_app/pages/newjournal/newjournal.dart';
import 'package:psw_journal_app/pages/root.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: RootPage());
    // return MaterialApp(debugShowCheckedModeBanner: false, home: AddJournalEntryPage());
  }
}
