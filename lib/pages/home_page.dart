// Built-in Libraries
import 'dart:async';
import 'package:flutter/material.dart';

// External Libraries
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_plan/provider/service_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// Classes
import 'package:edu_plan/pages/profile.dart';
import '../widget/lesson_card_widget.dart';

DateTime _calculateDateLesson(DateTime currentDate, String week, String day) {
  // Convert the target week to an integer
  final int targetWeek = int.parse(week.substring(week.indexOf(' ') + 1));

  // Find the first day of the month
  DateTime firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);

  // Find the day of the week for the first day of the month (0 = Monday, 1 = Tuesday, ..., 6 = Sunday)
  int firstDayOfWeek = firstDayOfMonth.weekday;

  // Adjust to the specified target week and day of the week
  DateTime dateLesson = firstDayOfMonth.subtract(Duration(days: firstDayOfWeek)); // Start from the beginning of the week

  // Adjust to the specified target week
  dateLesson = dateLesson.add(Duration(days: (targetWeek - 1) * 7));

  // Adjust to the specified day of the week
  dateLesson = dateLesson.add(Duration(days: _getDayOfWeekNumber(day)));

  return dateLesson;
}

// Retrieves day of the week for _calculateDateLesson function
int _getDayOfWeekNumber(String day) {
  switch (day.toLowerCase()) {
    case 'monday':
      return 1; // Adjusted to start from 1 (Monday)
    case 'tuesday':
      return 2;
    case 'wednesday':
      return 3;
    case 'thursday':
      return 4;
    case 'friday':
      return 5;
    case 'saturday':
      return 6;
    case 'sunday':
      return 7; // Adjusted to consider Sunday as the last day of the week
    default:
      return -1;
  }
}

// Compares 2 different weeks
int _compareWeeks(String week1, String week2) {
  // Extract the numeric part of the week strings
  int weekNumber1 = int.parse(week1.split(' ')[1]);
  int weekNumber2 = int.parse(week2.split(' ')[1]);

  // Compare the numeric parts
  return weekNumber1.compareTo(weekNumber2);
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final todoData = ref.watch(fetchStreamProvider);
    final selectedWeek = ref.watch(selectedWeekProvider);
    String currentWeek = ref.watch(currentWeekProvider);
    const List<String> weeklist = <String>['Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5'];
    String? photoURL = FirebaseAuth.instance.currentUser?.photoURL;

    Future<void> refresh() async {
      final Completer<void> completer = Completer<void>();

      // Fetch the documents from Firestore
      final List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
      await FirebaseFirestore.instance
          .collection(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((snapshot) => snapshot.docs);

      // Update the dateLesson field based on the current week and day
      final DateTime currentDate = DateTime.now();
      documents.forEach((doc) {
        final String week = doc['week'];
        final String day = doc['day'];
        final DateTime dateLesson = _calculateDateLesson(currentDate, week, day);

        // Update the dateLesson field in Firestore
        FirebaseFirestore.instance
            .collection(FirebaseAuth.instance.currentUser!.uid)
            .doc(doc.id)
            .update({'dateLesson': DateFormat('d/M/yyyy').format(dateLesson)});
      });

      // Wait for 1 second before completing the refresh
      Timer(const Duration(seconds: 1), () {
        completer.complete();
        Phoenix.rebirth(context);
      });

      return completer.future.then<void>((_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Refresh interrupted')));
      });
    }

    Future<void> runOnMonthChange() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String lastOpenedMonth = prefs.getString('lastOpenedMonth') ?? '';

      final String currentMonth = DateFormat('MMMM').format(DateTime.now());

      if (lastOpenedMonth != currentMonth) {
        if (currentWeek == 'Week 1'){ref.read(serviceProvider).copyTasksFromWeek5ToWeek1();}
        else if (currentWeek != 'Week 1'){ref.read(serviceProvider).deleteAll('Week 1');}
        ref.read(serviceProvider).deleteAll('Week 2');
        ref.read(serviceProvider).deleteAll('Week 3');
        ref.read(serviceProvider).deleteAll('Week 4');
        ref.read(serviceProvider).deleteAll('Week 5');
        refresh();

        // Update the last opened month in shared preferences
        prefs.setString('lastOpenedMonth', currentMonth);
      }
    }

    // Call the function when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      runOnMonthChange();
    });

    Future<void> runGoogleAppsScript() async {
      try {
        // Fetch the documents from Firestore
        final List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
        await FirebaseFirestore.instance
            .collection(FirebaseAuth.instance.currentUser!.uid)
            .where('week', isEqualTo: selectedWeek)
            .get()
            .then((snapshot) => snapshot.docs);

        // Check if all documents have isDone set to true
        bool allDone = documents.every((doc) => doc['isDone'] == true);

        if (allDone) {
          // Continue with the script execution
          String uid = FirebaseAuth.instance.currentUser!.uid;
          String scriptUrl = 'https://script.google.com/macros/s/AKfycbx-L_OiWnjJ6pPj7ovnYWGz70sOq73XkXjVH9X8hFniLftMGwOBczixym8ENxXJsy8XwA/exec?uid=$uid&selectedWeek=$selectedWeek';


          final response = await http.get(Uri.parse(scriptUrl));

          if (response.statusCode == 200) {
            print('Google Apps Script executed successfully');
            print('Response: ${response.body}');
          } else {
            print('Failed to execute Google Apps Script. Status code: ${response.statusCode}');
          }
        } else {
          return showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.grey.shade200,
                surfaceTintColor: Colors.transparent,
                title: Text('Some of the lesson plans are not yet finished'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } catch (error) {
        print('Error: $error');
      }
    }

    void downloadPDF(String selectedWeek) async {
      String pdfUrl;

      switch (selectedWeek) {
        case 'Week 1':
          pdfUrl =
          'https://docs.google.com/spreadsheets/d/e/2PACX-1vTUb-aKC_vVJIHlqsOgBxMWTHxKvhNmY_cJ9sYgw7rFeYwPlNzbmu6f7qUXlDLutn9eEGtGZdNjcrvw/pub?gid=632491458&single=true&output=pdf';
          break;
        case 'Week 2':
          pdfUrl =
          'https://docs.google.com/spreadsheets/d/e/2PACX-1vTUb-aKC_vVJIHlqsOgBxMWTHxKvhNmY_cJ9sYgw7rFeYwPlNzbmu6f7qUXlDLutn9eEGtGZdNjcrvw/pub?gid=87080661&single=true&output=pdf';
          break;
        case 'Week 3':
          pdfUrl =
          'https://docs.google.com/spreadsheets/d/e/2PACX-1vTUb-aKC_vVJIHlqsOgBxMWTHxKvhNmY_cJ9sYgw7rFeYwPlNzbmu6f7qUXlDLutn9eEGtGZdNjcrvw/pub?gid=1736553329&single=true&output=pdf';
          break;
        case 'Week 4':
          pdfUrl =
          'https://docs.google.com/spreadsheets/d/e/2PACX-1vTUb-aKC_vVJIHlqsOgBxMWTHxKvhNmY_cJ9sYgw7rFeYwPlNzbmu6f7qUXlDLutn9eEGtGZdNjcrvw/pub?gid=786249404&single=true&output=pdf';
          break;
        case 'Week 5':
          pdfUrl =
          'https://docs.google.com/spreadsheets/d/e/2PACX-1vTUb-aKC_vVJIHlqsOgBxMWTHxKvhNmY_cJ9sYgw7rFeYwPlNzbmu6f7qUXlDLutn9eEGtGZdNjcrvw/pub?gid=664070001&single=true&output=pdf';
          break;
        default:
        // Handle other cases if needed
          return;
      }

      try {
        await launchUrl(Uri.parse(pdfUrl));
      } catch (e) {
        print('Error launching URL: $e');
      }
    }

    Future<bool> checkIsUnlocked() async {
      try {
        var doc = await FirebaseFirestore.instance
            .collection('coordinator')
            .doc('unlock')
            .get();

        return doc.exists ? doc.get('isUnlocked') ?? false : false;
      } catch (e) {
        print('Error checking unlock status: $e');
        return false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black,
        title: ListTile(
          leading: GestureDetector(
            onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));},
            child:CircleAvatar(
              radius: 22,
              backgroundColor: Colors.transparent,
              foregroundImage: photoURL != null
                  ? NetworkImage(photoURL)
                  : AssetImage('assets/Profile.png') as ImageProvider,//insert image url here
              )
          ),
          title: Text(
            'Welcome back',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          subtitle: Text(
            FirebaseAuth.instance.currentUser!.displayName!,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child:
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    bool isUnlocked = await checkIsUnlocked();
                    if (isUnlocked) {
                      downloadPDF(selectedWeek);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text("The coordinator doesn't allow downloads of the lesson plan")));
                    }
                  },
                  icon: const Icon(Icons.download),
                ),
                IconButton(
                  onPressed: () async {await FirebaseAuth.instance.signOut(); await GoogleSignIn().signOut();},
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),

          )
        ],
      ),
      body:
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(children: [
            //Divider(height: 0.5, thickness: 0.5),
            const Gap(24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lesson Plans',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                    ),
                  Text(DateFormat('EEE, d MMMM').format(DateTime.now()), style: TextStyle(color: Colors.grey)),
                ],
              ),
              Container(
                height: 40,
                decoration: BoxDecoration(border: Border.all(width: 2), borderRadius: BorderRadius.circular(8)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    padding: EdgeInsets.only(left: 24, right: 10),
                    iconEnabledColor: Colors.black,
                    iconDisabledColor: Colors.black,
                    iconSize: 30,
                    value: selectedWeek,
                    items: weeklist.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        alignment: AlignmentDirectional.center,
                        value: value,
                        child: Text(value, style: TextStyle(color: Colors.black87)),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        ref.read(selectedWeekProvider.notifier).update((state) => newValue);
                      }
                    },
                  ),
                ),
              )
            ],),

            // Card list task
            const Gap(10),
            LiquidPullToRefresh(
              color: Colors.transparent,
              backgroundColor: Colors.black87,
              height: 70,
              showChildOpacityTransition: false,
              springAnimationDurationInMilliseconds: 400,
              animSpeedFactor: 5,
              onRefresh: refresh,
              child: ListView.builder(
                itemCount: todoData.value?.length ?? 0,
                shrinkWrap: true,
                itemBuilder: (context, index) {

                  return Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: LessonCards(getIndex: index),
                      ),
                      if (_compareWeeks(selectedWeek, currentWeek) < 0)
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.grey.shade200,
                                    surfaceTintColor: Colors.transparent,
                                    title: Text('Lesson plans are no longer editable because the week has passed'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                  );
                },
              )
            )
          ]),
        ),
      ),
      floatingActionButton: Container(
        width: 70,
        height: 70,
        child: FloatingActionButton(
            onPressed: () async {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: Colors.grey.shade200,
                      surfaceTintColor: Colors.transparent,
                      title: Text('Sending plans to Gsheets please wait..'),
                      content: Container(height: 50, width: 50, child: Center(child: CircularProgressIndicator(color: Colors.black87,))))
                    ;},
                  barrierDismissible: false);
              await runGoogleAppsScript(); Navigator.pop(context);},
            tooltip: 'Send lesson plans to GSheets',
            shape: CircleBorder(),
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            child: Icon(Icons.send, size: 30)),
      ),
    );
  }
}