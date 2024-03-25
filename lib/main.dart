// Built-in Libraries
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// External Libraries
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

// Classes
import 'firebase_options.dart';
import 'package:edu_plan/common/auth_page.dart';

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
      Phoenix(child: ProviderScope(child: EduPlan()))
  );}

class EduPlan extends StatefulWidget {
  const EduPlan({super.key});

  @override
  State<EduPlan> createState() => _EduPlanState();
}

class _EduPlanState extends State<EduPlan> {
  /// to be replaced with firebase auth
  var isLogged = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: const AuthPage(),
    );
  }
}
