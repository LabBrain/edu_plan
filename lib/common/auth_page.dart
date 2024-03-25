// Built-in Libraries
import 'package:edu_plan/common/onboarding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// External Libraries
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';


// Classes
import '../pages/home_page.dart';
import '../pages/login.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CircularProgressIndicator());
          } else {
            if (snapshot.hasData) {
              return FutureBuilder<int>(
                future: checkCollectionSize(),
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: const CircularProgressIndicator());
                  } else {
                    if (snapshot.data != null && snapshot.data! > 0) {
                      // Collection exists and has documents, navigate to HomePage
                      return const HomePage();
                    } else {
                      // Collection doesn't exist or is empty, show SnackBar and navigate to LoginScreen
                      WidgetsBinding.instance!.addPostFrameCallback((_) {
                        if (FirebaseAuth.instance.currentUser?.metadata.creationTime == FirebaseAuth.instance.currentUser?.metadata.lastSignInTime) {
                          FirebaseAuth.instance.signOut(); GoogleSignIn().signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const Onboarding()),
                          );
                        }
                        else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.red,
                              content: Text('Wait for coordinator to setup your account'),
                            ),
                          );
                          FirebaseAuth.instance.signOut(); GoogleSignIn().signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        }
                      });
                      return Container(); // Return an empty container for now
                    }
                  }
                },
              );
            } else {
              return const LoginScreen();
            }
          }
        },
      ),
    );
  }

  Future<int> checkCollectionSize() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(FirebaseAuth.instance.currentUser!.uid)
        .limit(1)
        .get();
    return querySnapshot.size;
  }
}
