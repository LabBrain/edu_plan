// Built-in Libraries
import 'package:flutter/material.dart';

// External Libraries
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:settings_ui/settings_ui.dart';

// Classes
import 'package:edu_plan/common/forgetpass.dart';

class Profile extends StatefulWidget{
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isUnlock = false;

  Future<void> fetchIsUnlocked() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('coordinator')
          .doc('unlock')
          .get();

      if (doc.exists && doc.data()!.containsKey('isUnlocked')) {
        setState(() {
          isUnlock = doc.get('isUnlocked');
        });
      }
    } catch (e) {
      print('Error fetching unlock status: $e');
    }
  }

  void initState() {
    super.initState();
    fetchIsUnlocked();
  }

  Widget build(BuildContext context) {
    void forget(BuildContext context){
      Navigator.push(context,MaterialPageRoute(builder: (context) => ForgetPass()));
    };
    String? photoURL = FirebaseAuth.instance.currentUser?.photoURL;

    return Scaffold(
      appBar: AppBar(title: Text('Profile & App Settings'), backgroundColor: Colors.grey.shade50, elevation: 0),
      body:
      Container(
        child: SettingsList(
          lightTheme: SettingsThemeData(settingsListBackground: Colors.grey.shade50),
          sections: [
            CustomSettingsSection(child:
              Container(padding: const EdgeInsets.only(left: 24, right: 24, top:24, bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.transparent,
                          foregroundImage: photoURL != null
                              ? NetworkImage(photoURL)
                              : AssetImage('assets/Profile.png') as ImageProvider,//insert image url here
                        ),
                        Gap(12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text(
                            FirebaseAuth.instance.currentUser!.displayName!,
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          Text(FirebaseAuth.instance.currentUser!.email!, style: TextStyle(color: Colors.grey.shade500))
                        ],)
                      ],
                    ),
                  ]
                )
              )
            ),
            SettingsSection(
              title: Text('Settings', style: TextStyle(color: Colors.black87)),
              tiles:
              <SettingsTile>[
                SettingsTile.navigation(
                  onPressed: forget,
                  leading: Icon(Icons.lock),
                  title: Text('Reset password'),
                  value: Text('A link will be sent to your email'),
                ),
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    try {
                      var coordinatorDoc = await FirebaseFirestore.instance
                          .collection('coordinator')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .get();

                      if (coordinatorDoc.exists) {
                        var isCoordinator = coordinatorDoc.get('isCoordinator') ?? false;

                        if (isCoordinator) {
                          await FirebaseFirestore.instance
                              .collection('coordinator')
                              .doc('unlock')
                              .update({'isUnlocked': value});

                          setState(() {
                            isUnlock = value;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              backgroundColor: Colors.red,
                              content: Text("Only the coordinator can alter this setting")));
                        }
                      } else {
                        // Handle the case when the document doesn't exist
                        print('Coordinator document does not exist.');
                      }
                    } catch (e) {
                      print('Error updating unlock status: $e');
                    }
                  },
                  initialValue: isUnlock,
                  leading: Icon(Icons.admin_panel_settings),
                  title: Text('Allow plan download'),
                  description: Text('Only coordinators have access'),
                ),
              ],
            ),
            CustomSettingsSection(child:
              Container(
                padding: const EdgeInsets.only(left: 24, right: 24, top:30),
                child: SizedBox(width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {await FirebaseAuth.instance.signOut(); await GoogleSignIn().signOut();},
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.logout, color: Colors.white), Gap(10), Text('Sign Out', style: TextStyle(color: Colors.white),)]),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        fixedSize: Size(double.infinity, 48)
                    ),
                  )
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}