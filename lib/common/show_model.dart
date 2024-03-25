// Built-in Libraries
import 'package:flutter/material.dart';

//External Libraries
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

// Classes
import '../constants/app_style.dart';
import 'package:edu_plan/model/plan_model.dart';
import 'package:edu_plan/provider/category_provider.dart';
import 'package:edu_plan/provider/service_provider.dart';

String description ='';

class EditPlanModel extends ConsumerWidget {
  const EditPlanModel({super.key, required this.todoModel});

  final PlanModel todoModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Container(
      padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
      height: MediaQuery.of(context).size.height * 0.62,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            child: Text(
              todoModel.lessonName,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          Divider(
            thickness: 1.2,
            color: Colors.grey.shade200,
          ),
          const Text('Description', style: AppStyle.headingOne),
          const Gap(6),
          MyTextFieldWidget2(maxLine: 5, hintText: todoModel.description),
          const Gap(10),
          const Text('Category', style: AppStyle.headingOne),
          const Gap(6),
          Container(
            height: 40,
            width: double.infinity,
            padding: EdgeInsets.only(left: 20, right: 10),
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                value: ref.watch(categoryProvider) == '' ? todoModel.category : ref.watch(categoryProvider),
                onChanged: (newValue) {
                  // Update the selected category in the StateProvider
                  if (newValue != null) {
                    ref.read(categoryProvider.notifier).update((value) => newValue);
                  }
                },
                items: [' ','Lecture', 'Assignment', 'Assessment']
                    .map<DropdownMenuItem<String>>(
                      (String category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(category, style: TextStyle(color: Colors.black87)),
                  ),
                ).toList(),
              ),
            ),
          ),
          // Date and time section
          const Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Date', style: AppStyle.headingOne),
                    Container(
                      width: double.infinity,
                      height: 40,
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                      child:Center(
                        child: Text(
                          todoModel.dateLesson,
                          style: AppStyle.headingOne,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(30),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Time', style: AppStyle.headingOne),
                    Container(
                      width: double.infinity,
                      height :40,
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                      child:Center(
                        child: Text(
                          todoModel.timeLesson,
                          style: AppStyle.headingOne,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Button Section
          const Gap(20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                // Update Firestore document with necessary changes
                if (ref.read(categoryProvider) != '') {ref.read(serviceProvider).changeCat(todoModel.docID, ref.read(categoryProvider));};
                ref.read(serviceProvider).changeDesc(todoModel.docID, description=='' ? todoModel.description : description);
                ref.read(categoryProvider.notifier).update((value) => '');
                Navigator.pop(context);
              },
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}


//TEXTFIELD WIDGET
class MyTextFieldWidget2 extends StatefulWidget {
  final String hintText;
  final int maxLine;

  // Constructor to accept the variable
  MyTextFieldWidget2({Key? key, required this.hintText, required this.maxLine}) : super(key: key);

  @override
  _MyTextFieldWidgetState2 createState() => _MyTextFieldWidgetState2();
}

class _MyTextFieldWidgetState2 extends State<MyTextFieldWidget2> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    // Initialize the TextEditingController with the initial value
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    // Dispose of the TextEditingController when the widget is disposed
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: _textController,
          decoration: InputDecoration(
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: widget.hintText),
          maxLines: widget.maxLine,
          onChanged: (val){description=val; print(description);},
        )
    );
  }
}