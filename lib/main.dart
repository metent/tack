// This file is part of tack, a hierarchial task management application.
//
// Copyright 2021 Tack Developers
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:tack/multitree.dart' as multitree;
import 'package:tack/widgets/textfield.dart';
import 'package:tack/widgets/tasktree.dart';

const appBarTitle = "Task Tree";

class Home extends StatefulWidget {
  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  static TextEditingController textController = TextEditingController();
  static final taskTree = GlobalKey<TreeNodeWidgetState>();

  bool isVisible = false;
  String newNodeTitle = "";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap and onTap cancel dismisses the textField
      onTap: () {
        setVisiblityFalse();
      },
      onTapCancel: () {
        setVisiblityFalse();
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            actions: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  taskTree.currentState!.parentId = 0;
                  toggleVisibility();
                },
              )
            ],
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SingleChildScrollView(
                  child: TreeNodeWidget(0, multitree.build(), toggleVisibility,
                      setVisiblityFalse, taskTree)),
              CustomTextField(isVisible, setVisiblityFalse)
            ],
          )),
    );
  }

  void toggleVisibility() {
    isVisible = !isVisible;
    textController.text = "";
    setState(() {});
  }

  void setVisiblityFalse() {
    isVisible = false;
    textController.text = "";
    setState(() {});
  }
}

void main() {
  runApp(MaterialApp(home: Home()));
}
