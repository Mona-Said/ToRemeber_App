import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../cubit/cubit.dart';

Widget defaultButton({
  Color color = Colors.blueAccent,
  double width = double.infinity,
  required String text,
  required VoidCallback function,
}) =>
    SizedBox(
      width: width,
      height: 50.0,
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: MaterialButton(
          color: color,
          onPressed: function,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );

Widget textButton({
  required String text,
  required VoidCallback function,
  Color? color,
  double? fontSize,
  FontWeight? fontWeight,
}) =>
    TextButton(
      onPressed: function,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );

Widget formField({
  required TextEditingController controller,
  required String label,
  required IconData prefix,
  IconData? suffix,
  required TextInputType type,
  required String? Function(String?)? function,
  String? Function(String?)? submit,
  String? Function(String?)? onChanged,
  VoidCallback? pressed,
  VoidCallback? onTap,
  bool isClickable = true,
  bool isPassword = false,
}) =>
    Container(
      width: double.infinity,
      height: 60.0,
      child: TextFormField(
        cursorColor: Colors.cyan,
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(40.0),
            ),
          ),
          labelText: label,
          prefixIcon: Icon(
            prefix,
          ),
          suffixIcon: suffix != null
              ? IconButton(
                  onPressed: pressed,
                  icon: Icon(
                    suffix,
                  ),
                )
              : null,
        ),
        keyboardType: type,
        style: const TextStyle(fontSize: 15.0),
        obscureText: isPassword,
        validator: function,
        onTap: onTap,
        enabled: isClickable,
        onFieldSubmitted: submit,
        onChanged: onChanged,
      ),
    );

Widget databaseList(Map map, context) => Dismissible(
      key: Key(map['id'].toString()),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40.0,
              backgroundColor: Colors.cyan,
              child: Text(
                '${map['time']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${map['name']}',
                    style: const TextStyle(fontSize: 17.0),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    '${map['date']}',
                    style: TextStyle(fontSize: 16.0, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 15.0,
            ),
            IconButton(
              onPressed: () {
                AppCubit.get(context).updateDatabase(
                  status: 'done',
                  id: map['id'],
                );
              },
              icon: const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
            ),
            const SizedBox(
              width: 8.0,
            ),
            IconButton(
              onPressed: () {
                AppCubit.get(context).updateDatabase(
                  status: 'archived',
                  id: map['id'],
                );
              },
              icon: const Icon(
                Icons.archive,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        AppCubit.get(context).deleteDatabase(id: map['id']);
      },
    );

Widget taskBuilder({required List<Map> tasks}) => ConditionalBuilder(
      condition: tasks.isNotEmpty,
      builder: (context) => ListView.separated(
        itemBuilder: (context, index) => databaseList(tasks[index], context),
        separatorBuilder: (context, index) => myDivider(),
        itemCount: tasks.length,
      ),
      fallback: (context) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu,
              color: Colors.grey,
              size: 100.0,
            ),
            Text(
              'No Tasks Here, Please Add a New Task',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 17.0,
              ),
            ),
          ],
        ),
      ),
    );

Widget myDivider() => Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 30.0,
      ),
      child: Container(
        width: double.infinity,
        height: 1.0,
        color: Colors.grey[300],
      ),
    );

void navigateTo(context, widget) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => widget,
    ));

void navigateAndFinish(context, widget) => Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => widget,
    ),
    (route) => false);

void itemToast({
  required String text,
  required ToastStates state,
}) =>
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: chooseColorToast(state),
        textColor: Colors.white,
        fontSize: 16.0);

enum ToastStates { success, warning, error }

Color chooseColorToast(ToastStates state) {
  Color color;
  switch (state) {
    case ToastStates.success:
      color = Colors.green;
      break;
    case ToastStates.warning:
      color = Colors.amber;
      break;
    case ToastStates.error:
      color = Colors.red;
      break;
  }
  return color;
}
