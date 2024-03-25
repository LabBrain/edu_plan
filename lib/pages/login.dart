// Built-in Libraries
import 'package:flutter/material.dart';

// External Libraries
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:gap/gap.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Classes
import 'package:edu_plan/common/forgetpass.dart';
import 'package:edu_plan/pages/signup.dart';
import '../common/onboarding.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  bool _isLoading = false;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  // Firebase Auth setup
  signInWithEmailAndPassword() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: _email.text, password: _password.text);
      setState(() {
        _isLoading = false;
      });
      Phoenix.rebirth(context);
    } on FirebaseAuthException {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Invalid email or password')));
    }
  }

  Future<void> signInwithGoogle() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCred = await FirebaseAuth.instance.signInWithCredential(credential);
        setState(() {
          _isLoading = false;
        });

        if (userCred.additionalUserInfo!.isNewUser){Navigator.push(context, MaterialPageRoute(builder: (context) => Onboarding()));}
        else {Phoenix.rebirth(context);}
      } else{
        setState(() {
          _isLoading = false;
        });
      }

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Something went wrong')));
    }
  }


  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 80, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                    height: 150,
                    image: AssetImage('assets/EduPlan_icon.png')),
                  Gap(10),
                  const Text('Welcome to EduPlan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  Text('The ultimate lesson planner app', style: TextStyle(color: Colors.grey),)
                ],
              ),

              /// Form
              Form(
                key: _formKey,
                child: Padding(padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      /// Email
                      TextFormField(
                        controller: _email,
                        validator: (text) => text != null && !EmailValidator.validate(text) ? 'Enter a valid email' : null,
                        decoration: InputDecoration(prefixIcon: Icon(Icons.email), labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: [AutofillHints.email],
                      ),
                      Gap(10),
                      /// Pass
                      TextFormField(
                        controller: _password,
                        validator: (text) {
                          if (text == null || text.isEmpty) {return 'Password is empty';}
                          return null;
                        },
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.password), labelText: 'Password',
                            suffixIcon: IconButton(icon: Icon(_isObscure ?  Icons.visibility: Icons.visibility_off), onPressed: () => setState(() {_isObscure = !_isObscure;}))),
                        autofillHints: [AutofillHints.password],
                      ),
                      /// Remember me & forget pass
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          /// Remember me
                          TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgetPass())), child: const Text('Forget Password?', style: TextStyle(color: const Color(0xFF1DA1F2)),))
                        ],
                      ),

                      const Gap(10),

                      /// Sign-in button
                      SizedBox(width: double.infinity, child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              fixedSize: Size(double.infinity, 48)
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              signInWithEmailAndPassword();
                            }},
                          child: _isLoading ? Center(child: Container(width: 25, height:25, child: CircularProgressIndicator(color: Colors.white))) : const Text('Sign-in'))),

                      Gap(10),
                      /// Create account
                      SizedBox(width: double.infinity, child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              fixedSize: Size(double.infinity, 48)
                          ),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen())), child: const Text('Create account'))),

                      const Gap(10),
                    ],
                  )
                ),
              ),

              /// Divider
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(child: Divider(color: Colors.grey, thickness: 1, indent: 60, endIndent: 5)),
                  Text('Or Sign in With', style: TextStyle(color: Colors.grey)),
                  Flexible(child: Divider(color: Colors.grey, thickness: 1, indent: 5, endIndent: 60)),
                ],
              ),

              Gap(30),

              SizedBox(width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {signInwithGoogle();},
                    child: _isLoading ? Center(child: Container(width: 25, height: 25, child: CircularProgressIndicator(color: Colors.black54))) : const Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [Image(width: 20, image: AssetImage('assets/Google_icon.png'), color: Colors.black54), Gap(10), Text('Sign in with bchati.sch.id', style: TextStyle(color: Colors.black54),)]),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        fixedSize: Size(double.infinity, 48)
                    ),
                  )
              ),
            ],
          ),
        ),
      )
    );
  }
}