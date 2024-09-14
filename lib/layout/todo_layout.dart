import 'dart:core';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../shared/components/components.dart';

class HomeLayoutScreen extends StatelessWidget {
  HomeLayoutScreen({super.key});

  var fabKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var textController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(listener: (context, state) {
        if (state is InsertToDatabaseState) {
          Navigator.pop(context);
        }
      }, builder: (context, state) {
        AppCubit cubit = AppCubit.get(context);
        return Scaffold(
          key: fabKey,
          appBar: AppBar(
            backgroundColor: Colors.cyan,
            title: Text(
              cubit.titles[cubit.currentIndex],
              //style: TextStyle(fontSize: 20.0, color: Colors.white),
            ),
          ),
          body: ConditionalBuilder(
            condition: state is! GetLoadingState,
            builder: (context) => cubit.items[cubit.currentIndex],
            fallback: (context) => const Center(
                child: CircularProgressIndicator(
              color: Colors.cyan,
            )),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.cyan,
            onPressed: () {
              if (cubit.bottomSheetShown) {
                if (formKey.currentState!.validate()) {
                  cubit.insertToDatabase(
                      name: textController.text,
                      time: timeController.text,
                      date: dateController.text);
                }
              } else {
                fabKey.currentState!
                    .showBottomSheet(
                      (context) => Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              formField(
                                  controller: textController,
                                  label: 'the task',
                                  prefix: Icons.title,
                                  type: TextInputType.text,
                                  function: (value) {
                                    if (value!.isEmpty) {
                                      return ('the task can not be empty');
                                    }
                                    return null;
                                  }),
                              const SizedBox(
                                height: 10.0,
                              ),
                              formField(
                                  controller: timeController,
                                  label: 'Task time',
                                  prefix: Icons.watch_later_outlined,
                                  type: TextInputType.datetime,
                                  function: (value) {
                                    if (value!.isEmpty) {
                                      return ('task time can not be empty');
                                    }
                                    return null;
                                  },
                                  onTap: () {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then((value) {
                                      timeController.text =
                                          value!.format(context);
                                    });
                                  }),
                              const SizedBox(
                                height: 10.0,
                              ),
                              formField(
                                  controller: dateController,
                                  label: 'Task date',
                                  prefix: Icons.calendar_today,
                                  type: TextInputType.datetime,
                                  function: (value) {
                                    if (value!.isEmpty) {
                                      return ('task date can not be empty');
                                    }
                                    return null;
                                  },
                                  onTap: () {
                                    showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.parse('2027-10-04'),
                                    ).then((value) {
                                      dateController.text =
                                          DateFormat.yMMMd().format(value!);
                                    });
                                  }),
                            ],
                          ),
                        ),
                      ),
                      elevation: 20.0,
                    )
                    .closed
                    .then((value) {
                  cubit.changeBottomSheet(
                    isShow: false,
                    icon: Icons.edit,
                  );
                });
                cubit.changeBottomSheet(
                  isShow: true,
                  icon: Icons.add,
                );
              }
            },
            child: Icon(
              cubit.fabIcon,
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
              selectedItemColor: Colors.cyan,
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeState(index);
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.menu,
                    ),
                    label: 'Tasks'),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.check_circle_outline,
                    ),
                    label: 'Done'),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.archive_outlined,
                    ),
                    label: 'Archived'),
              ]),
        );
      }),
    );
  }

  Future<String> getName() async {
    return 'MONA SAID ELSAYED';
  }
}
