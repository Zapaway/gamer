import 'package:flutter/material.dart';

class DragBar extends StatelessWidget {
  const DragBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        height: 7.5,
        width: 200,
      ),
    );
  }
}

class AppBarWithOnlyDragBar extends AppBar {
  AppBarWithOnlyDragBar({Key? key}) : super(
    key: key,
    title: const DragBar(),
    automaticallyImplyLeading: false,
    backgroundColor: Colors.transparent,
    elevation: 0,
    toolbarHeight: 30,
  );
}