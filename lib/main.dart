import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sober_steps/firebase_options.dart';
import 'package:sober_steps/modules/auth/verify_email.dart';
import 'package:sober_steps/modules/auth/welcome.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sober Stem',
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          primary: Colors.green[700],
          secondary: Colors.amber,
          background: Colors.grey[300],
          tertiary: Colors.grey[200],
          error: const Color(0xFFD6006B),
          inversePrimary: Colors.grey[400],
          ),

        useMaterial3: true,
      ),
      home:  Auth(),
    );
  }
}




class Auth extends StatelessWidget {
  Auth({super.key});

  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (user != null) {
            return  SoberityAuth();
          } else {
            return const WelcomePage();
          }
        },
      ),
    );
  }
}
