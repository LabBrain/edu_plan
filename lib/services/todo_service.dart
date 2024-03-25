import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodoService{
  final todoCollection = FirebaseFirestore.instance.collection(FirebaseAuth.instance.currentUser!.uid);

  //UPDATE
  void updateTask(String? docID, bool? valueUpdate){
    todoCollection.doc(docID).update({
      'isDone': valueUpdate
    });
  }

  void changeDesc(String? docID, String? valueUpdate){
    todoCollection.doc(docID).update({
      'description': valueUpdate
    });
  }

  void changeCat(String? docID, String? valueUpdate){
    todoCollection.doc(docID).update({
      'category': valueUpdate
    });
  }

  Future<void> copyTasksFromWeek5ToWeek1() async {
    // Fetch documents for Week 5
    final week5Collection = await todoCollection
        .where('week', isEqualTo: 'Week 5')
        .get();

    // Loop through each document in Week 5 collection
    for (final doc5 in week5Collection.docs) {
      // Get the data from Week 5 document
      final Map<String, dynamic>? data5 = doc5.data() as Map<String, dynamic>?;

      if (data5 != null) {
        // Fetch documents for Week 1 with the same ID
        final week1Collection = await todoCollection
            .where('week', isEqualTo: 'Week 1')
            .get();

        // Update the corresponding document in Week 1 with the data from Week 5
        for (final doc1 in week1Collection.docs) {
          await todoCollection.doc(doc1.id).set({
            'category': data5['category'],
            'dateLesson': data5['dateLesson'],
            'day': data5['day'],
            'description': data5['description'],
            'isDone': false, // Set isDone to false
            'lessonName': data5['lessonName'],
            'timeLesson': data5['timeLesson'],
            'week': 'Week 1', // Ensure 'week' remains as 'Week 1'
          }, SetOptions(merge: true));
        }
      }
    }
  }

  //DELETE
  Future<void> deleteAll(String selectedWeek) async {
    // Fetch documents only for the selected week
    final collection = await todoCollection
        .where('week', isEqualTo: selectedWeek)
        .get();

    // Create a batch to perform the batch update
    final batch = FirebaseFirestore.instance.batch();

    // Loop through each document and set the specified field to null
    for (final doc in collection.docs) {
      batch.update(doc.reference, {'description': "", 'category' : "", 'isDone': false});
    }

    // Commit the batch operation
    return batch.commit();
  }
}