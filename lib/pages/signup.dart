// Built-in Libraries
import 'package:flutter/material.dart';

// External Libraries
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:gap/gap.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Classes
import '../constants/app_style.dart';
import 'package:edu_plan/common/onboarding.dart';

class SignupScreen extends StatefulWidget{
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  bool _isLoading = false;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _name = TextEditingController();
  @override

  // Firebase Auth setup
  createUserWithEmailAndPassword() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email.text, password: _password.text);
      await credential.user?.updateDisplayName(_name.text);
      await credential.user?.updatePhotoURL('https://i.imgur.com/VKSizY2.jpeg');

      Phoenix.rebirth(context);
      setState(() {
        _isLoading = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Password provided is too weak')));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Account already exist for that email')));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
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
        // final snapShot = await FirebaseFirestore.instance.collection(FirebaseAuth.instance.currentUser!.uid).limit(1).get();
        //
        // if(snapShot.size == 0) {await FirebaseFirestore.instance.collection(FirebaseAuth.instance.currentUser!.uid).add({'titleTask': 'Welcome to EduPlan!', 'description': 'Swipe to delete and click New Task', 'category': 'Learn', 'dateTask': 'dd/mm/yyyy', 'timeTask': 'mm:hh', 'isDone': false});}
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(forceMaterialTransparency: true, elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              Text('Sign up to EduPlan', style: AppStyle.headingOne),

              /// Form
              Form(key: _formKey, child: Column(
                children: [
                  /// Name
                  TextFormField(
                    controller: _name,
                    validator: (text) {
                      if (text == null || text.isEmpty) {return 'Name is empty';}
                      return null;
                    },
                    decoration: InputDecoration(prefixIcon: Icon(Icons.person), labelText: 'Name'),
                  ),

                  /// Email
                  TextFormField(
                    controller: _email,
                    validator: (text) => text != null && !EmailValidator.validate(text) ? 'Enter a valid email' : null,
                    decoration: InputDecoration(prefixIcon: Icon(Icons.email), labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: [AutofillHints.email],
                  ),

                  /// Password
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

                  const Gap(20),
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
                          createUserWithEmailAndPassword();
                        }},
                      child: _isLoading ? Center(child: Container(width: 25, height: 25, child: CircularProgressIndicator(color: Colors.white))) : const Text('Create Account'))),
                  TextButton(onPressed: () => Navigator.pop(context), child: Text('Already have an account?', style: TextStyle(color: const Color(0xFF1DA1F2))))
                ],
              )),

              const Gap(20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(child: Divider(color: Colors.grey, thickness: 1, indent: 60, endIndent: 5)),
                  Text('Or Sign up With', style: TextStyle(color: Colors.grey)),
                  Flexible(child: Divider(color: Colors.grey, thickness: 1, indent: 5, endIndent: 60)),
                ],
              ),

              const Gap(30),

              SizedBox(width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {signInwithGoogle();},
                    child: _isLoading ? Center(child: Container(width:25, height: 25, child: CircularProgressIndicator(color: Colors.black54))) : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Image(width: 20, image: AssetImage('assets/Google_icon.png'), color: Colors.black54), Gap(10), Text('Sign in with bchati.sch.id', style: TextStyle(color: Colors.black54),)]),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        fixedSize: Size(double.infinity, 48)
                    ),
                  )
              ),
            ],
          )
        ),
      ),
    );
  }
}