import 'package:cloud_firestore/cloud_firestore.dart';

class PlanModel {
  String? docID;
  final String lessonName;
  final String description;
  final String category;
  final String dateLesson;
  final String timeLesson;
  final bool isDone;

  PlanModel({
    this.docID,
    required this.lessonName,
    required this.description,
    required this.category,
    required this.dateLesson,
    required this.timeLesson,
    required this.isDone,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic> {
      'lessonName': lessonName,
      'description': description,
      'category': category,
      'dateLesson': dateLesson,
      'timeLesson': timeLesson,
      'isDone': isDone,
    };
  }

  factory PlanModel.fromMap(Map<String, dynamic> map) {
    return PlanModel(
      docID: map['docID'] != null ? map['docID'] as String : null,
      lessonName: map['lessonName'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      dateLesson: map['dateLesson'] as String,
      timeLesson: map['timeLesson'] as String,
      isDone: map['isDone'] as bool,
    );
  }

  factory PlanModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc){
    return PlanModel(docID: doc.id, lessonName: doc['lessonName'] , description: doc['description'], category: doc['category'], dateLesson: doc['dateLesson'], timeLesson: doc['timeLesson'], isDone: doc['isDone']);
  }
}