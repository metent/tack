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
import 'package:tack/main.dart';

enum Task {
  addChild,
  changeTitle,
}

class CustomTextField extends StatefulWidget {
  bool isVisible;
  final void Function() setVisiblityFalse;

  CustomTextField(this.isVisible, this.setVisiblityFalse);
  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  String nodeTitle = "";

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isVisible,
      child: TextField(
        controller: HomeState.textController,
        autofocus: true,
        decoration: InputDecoration(
            hintText:
                HomeState.taskTree.currentState!.textFieldTask == Task.addChild
                    ? "Enter new Task Title"
                    : "Enter new Title",
            contentPadding: EdgeInsets.all(10),
            suffixIcon: IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                if (HomeState.textController.text != "") {
                  nodeTitle = HomeState.textController.text;
                  if (HomeState.taskTree.currentState!.textFieldTask ==
                      Task.addChild) {
                    HomeState.taskTree.currentState!.addTask(nodeTitle);
                  } else if (HomeState.taskTree.currentState!.textFieldTask ==
                      Task.changeTitle) {
                    HomeState.taskTree.currentState!.changeTitle(nodeTitle);
                  }
                  HomeState.textController.text = "";
                }
                widget.setVisiblityFalse();
              },
            )),
      ),
    );
  }
}
