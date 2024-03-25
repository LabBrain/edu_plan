// Built-in Libraries
import 'package:flutter/material.dart';

// External Libraries
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';

// Classes
import '../common/show_model.dart';
import 'package:edu_plan/provider/service_provider.dart';

class LessonCards extends ConsumerWidget {
  const LessonCards({
    super.key,
    required this.getIndex,
  });

  final int getIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoData = ref.watch(fetchStreamProvider);

    return todoData.when(data: (todoData) {

      final TextEditingController descController = TextEditingController(text: todoData[getIndex].description);

      Color categoryColor = Colors.grey;

      final getCategory = todoData[getIndex].category;

      switch(getCategory){
        case 'Lecture' :
          categoryColor = Colors.green;
          break;
        case 'Assignment' :
          categoryColor = Colors.blue;
          break;
        case 'Assessment' :
          categoryColor = Colors.amber.shade700;
          break;

      }
        return Slidable(
            endActionPane: ActionPane(
              motion: ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (BuildContext context) => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return SingleChildScrollView(
                            child: Container(
                              child: EditPlanModel(todoModel: ref.read(fetchStreamProvider).value![getIndex],),
                            ));
                      }),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.black87,
                  icon: Icons.edit,
                  label: 'Edit plan',
                ),
              ],
            ),

            // The child of the Slidable is what the user sees when the
            // component is not dragged.
            child: Container(
              height: 152,
              width: double.infinity,
              decoration: BoxDecoration(color: categoryColor.withOpacity(0.3), borderRadius: BorderRadius.circular(12), boxShadow:[
                  BoxShadow(
                  color: Colors.grey.withOpacity(0.2), //color of shadow
                  spreadRadius: 3, //spread radius
                  blurRadius: 5, // blur radius
                  offset: Offset(0, 1), // changes position of shadow
                )],
              ),
              child: Column(
                children: [
                  Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        Container(
                          decoration: BoxDecoration(color: categoryColor, borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12))),
                          width: 16,
                        ),
                        Expanded(child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceAround ,children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(todoData[getIndex].lessonName, maxLines: 1, style: TextStyle(decoration: todoData[getIndex].isDone ? TextDecoration.lineThrough : null, fontWeight: FontWeight.bold)),
                                subtitle: EditableText(
                                  controller: descController,
                                  maxLines: 1,
                                  onSubmitted: (value) {ref.read(serviceProvider).changeDesc(todoData[getIndex].docID, value);}, focusNode: FocusNode(), style: TextStyle(decoration: todoData[getIndex].isDone ? TextDecoration.lineThrough : null, fontSize: 14, color: Colors.grey), cursorColor: Colors.blue, backgroundCursorColor: Colors.transparent,
                                ),
                                trailing: Transform.scale(
                                    scale: 1.5,
                                    child: Checkbox(activeColor: Colors.blue.shade800, shape: const CircleBorder(), value: todoData[getIndex].isDone, onChanged: (value) => ref.read(serviceProvider).updateTask(todoData[getIndex].docID, value))
                                ),
                              ),
                              Transform.translate(offset: const Offset(0,-20), child: Container(child: Column(children: [
                                Divider(thickness: 1.5, color: Colors.grey.shade200),
                                Row(children: [
                                  Text(todoData[getIndex].dateLesson),
                                  Gap(20),
                                  Text(todoData[getIndex].timeLesson)
                                ],)])
                              ))])
                        ))
                      ],),
                  ),
                  Container(height: 32, child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(children: [
                        Radio(
                            fillColor: MaterialStateColor.resolveWith((states) => Colors.black87),
                            activeColor: categoryColor,
                            visualDensity: VisualDensity(vertical: -4, horizontal: -4),
                            value: 'Lecture',
                            groupValue: todoData[getIndex].category,
                            onChanged: (value) {ref.read(serviceProvider).changeCat(todoData[getIndex].docID, value);},
                        ),
                        Text('Lecture', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                      ],),
                      Row(children: [
                        Radio(
                          fillColor: MaterialStateColor.resolveWith((states) => Colors.black87),
                          visualDensity: VisualDensity(vertical: -4, horizontal: -4),
                          value: 'Assignment',
                          groupValue: todoData[getIndex].category,
                          onChanged: (value) {ref.read(serviceProvider).changeCat(todoData[getIndex].docID, value);},
                        ),
                        Text('Assignment', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                      ],),
                      Row(children: [
                        Radio(
                          fillColor: MaterialStateColor.resolveWith((states) => Colors.black87),
                          visualDensity: VisualDensity(vertical: -4, horizontal: -4),
                          value: 'Assessment',
                          groupValue: todoData[getIndex].category,
                          onChanged: (value) {ref.read(serviceProvider).changeCat(todoData[getIndex].docID, value);},
                        ),
                        Text('Assessment', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                      ],)
                    ],
                  ))
                ],
              ),
            )
        );},

        error: (error, stackTrace) => Center(child: Text(stackTrace.toString())),
        loading: ()=> Center(child: LinearProgressIndicator(color: Colors.black87))
    );
  }
}