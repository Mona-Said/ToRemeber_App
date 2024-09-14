import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_remember/cubit/states.dart';

import '../modules/archived_tasks/archived.dart';
import '../modules/done_tasks/done.dart';
import '../modules/new_tasks/tasks.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  Database? database;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];
  IconData fabIcon = Icons.edit;
  bool bottomSheetShown = false;

  List<Widget> items = [
    const NewTasks(),
    const DoneTasks(),
    const ArchivedTasks(),
  ];
  List<String> titles = [
    'NEW TASKS',
    'DONE TASKS',
    'ARCHIVED TASKS',
  ];

  void changeState(int index) {
    currentIndex = index;
    emit(ChangeBottomNavBarState());
  }

  void createDatabase() {
    openDatabase('todo.db', version: 1, onCreate: (database, version) {
      print('database created');
      database
          .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY,name TEXT, date TEXT,status TEXT,time TEXT)')
          .then((result) {
        print('table created');
      }).catchError((error) {
        print('this is an error ${error.toString()}');
      });
    }, onOpen: (database) {
      print('database opened');

      getFromDatabase(database);
    }).then((value) {
      database = value;
      emit(CreateDatabaseState());
    });
  }

  insertToDatabase({
    required String name,
    required String time,
    required String date,
  }) async {
    await database?.transaction((txn) {
      return txn
          .rawInsert(
              'INSERT INTO tasks (name,time,date,status) VALUES ("$name","$time","$date","new")')
          .then((value) {
        print('$value inserted successfully');
        emit(InsertToDatabaseState());

        getFromDatabase(database);
      }).catchError((error) {
        print('this is an error ${error.toString()}');
      });
    });
  }

  void getFromDatabase(database) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

    emit(GetLoadingState());
    database!.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new') {
          newTasks.add(element);
        } else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      });

      emit(GetDatabaseState());
    });
  }

  void updateDatabase({
    required String status,
    required int id,
  }) {
    database!.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?', [status, id]).then((value) {
      getFromDatabase(database);
      emit(UpdateDatabaseState());
    });
  }

  void deleteDatabase({
    required int id,
  }) {
    database!.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getFromDatabase(database);
      emit(DeleteDatabaseState());
    });
  }

  void changeBottomSheet({
    required bool isShow,
    required IconData icon,
  }) {
    bottomSheetShown = isShow;
    fabIcon = icon;

    emit(ChangeBottomSheetState());
  }
}
