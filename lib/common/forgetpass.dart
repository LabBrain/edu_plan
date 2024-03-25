// Built-in Libraries
import 'package:flutter/material.dart';

// External Libraries
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';

class ForgetPass extends StatefulWidget{
  const ForgetPass({Key? key});

  @override
  State<ForgetPass> createState() => _ForgetPassState();
}

class _ForgetPassState extends State<ForgetPass> {
  final TextEditingController _email = TextEditingController();

  void dispose(){
    _email.dispose();
    super.dispose();
  }

  Future passwordReset() async{
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email.text.trim());
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Reset link sent, please check your email')));

    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(context: context, builder: (context) {return AlertDialog(content: Text(e.message.toString()));});
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset your password'), backgroundColor: Colors.grey.shade50, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Your password reset link will be sent to your email address', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _email,
              validator: (text) => text != null && !EmailValidator.validate(text) ? 'Enter a valid email' : null,
              decoration: InputDecoration(prefixIcon: Icon(Icons.email), labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              autofillHints: [AutofillHints.email],
            ),
            const Gap(30),
            SizedBox(width: double.infinity, child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    fixedSize: Size(double.infinity, 48)
                ),
                onPressed: passwordReset,
                child: Center(child: Text('Send link'))),
            )
          ]),
      )
    );
  }
}