// Built-in Libraries
import 'package:flutter/material.dart';

// External Libraries
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Classes
import 'package:edu_plan/model/plan_model.dart';
import 'package:edu_plan/services/todo_service.dart';


final serviceProvider = StateProvider<TodoService>((ref){
  return TodoService();
});

final currentWeekProvider = StateProvider<String>((ref) {
  // Current date and time of system
  String date = DateTime.now().toString();

// This will generate the time and date for first day of month
  String firstDay = date.substring(0, 8) + '01' + date.substring(10);

// week day for the first day of the month
  int weekDay = DateTime.parse(firstDay).weekday;

  DateTime testDate = DateTime.now();

  int weekOfMonth;

//  If your calender starts from Monday
  weekDay--;
  weekOfMonth = ((testDate.day + weekDay) / 7).ceil();

  final currentWeek = "Week $weekOfMonth";
  return currentWeek;
});

final selectedWeekProvider = StateProvider<String>((ref) {
  // Current date and time of system
  String date = DateTime.now().toString();

// This will generate the time and date for first day of month
  String firstDay = date.substring(0, 8) + '01' + date.substring(10);

// week day for the first day of the month
  int weekDay = DateTime.parse(firstDay).weekday;

  DateTime testDate = DateTime.now();

  int weekOfMonth;

//  If your calender starts from Monday
  weekDay--;
  weekOfMonth = ((testDate.day + weekDay) / 7).ceil();

  final currentWeek = "Week $weekOfMonth";
  return currentWeek;
});


// StreamProvider for fetching and sorting data based on the selected week
final fetchStreamProvider = StreamProvider<List<PlanModel>>((ref) async* {
  final selectedWeek = ref.watch(selectedWeekProvider);

  final getData = FirebaseFirestore.instance.collection(FirebaseAuth.instance.currentUser!.uid)
      .where('week', isEqualTo: selectedWeek)
      .orderBy('lessonName')
      .snapshots()
      .map((event) {
        final List<PlanModel> todoList = event.docs
            .map((snapshot) => PlanModel.fromSnapshot(snapshot))
            .toList();

        // Custom sorting function for lessonName, dateLesson, and timeLesson
        todoList.sort((a, b) {
          // Compare by lessonName
          final lessonNameComparison = a.lessonName.compareTo(b.lessonName);
          if (lessonNameComparison != 0) {
            return lessonNameComparison;
          }

          // If lessonName is the same, compare by dateLesson
          final dateA = _parseDate(a.dateLesson);
          final dateB = _parseDate(b.dateLesson);
          final dateComparison = dateA.compareTo(dateB);
          if (dateComparison != 0) {
            return dateComparison;
          }

          // If dateLesson is the same, compare by timeLesson
          final timeA = _parseTime(a.timeLesson);
          final timeB = _parseTime(b.timeLesson);
          return _compareTimeOfDay(timeA, timeB);
        });

        return todoList;
      });
  yield* getData;
});

DateTime _parseDate(String date) {
  final parts = date.split('/');
  final day = int.parse(parts[0]);
  final month = int.parse(parts[1]);
  final year = int.parse(parts[2]);
  return DateTime(year, month, day);
}

TimeOfDay _parseTime(String time) {
  final parts = time.split(':');
  final hour = int.parse(parts[0]);
  final minute = int.parse(parts[1].split(' ')[0]);
  return TimeOfDay(hour: hour, minute: minute);
}

int _compareTimeOfDay(TimeOfDay a, TimeOfDay b) {
  if (a.hour != b.hour) {
    return a.hour - b.hour;
  }
  return a.minute - b.minute;
}