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

class TreeNodeWidget extends StatefulWidget {
  final int nodeId;
  List<multitree.Node?> nodeList;
  final void Function() toggleVisibility;
  final void Function() setVisibilityFalse;
  Key? key;

  TreeNodeWidget(this.nodeId, this.nodeList, this.toggleVisibility,
      this.setVisibilityFalse, this.key)
      : super(key: key);

  @override
  State<TreeNodeWidget> createState() => TreeNodeWidgetState();
}

class TreeNodeWidgetState extends State<TreeNodeWidget> {
  int parentId = 0;
  Task textFieldTask = Task.addChild;

  @override
  Widget build(BuildContext context) {
    return Column(children: generateChildWidgetList(0, 0));
  }

  Widget buildWidgetTree(final int rootId, double level) {
    return Dismissible(
      key: Key(rootId.toString()),
      background: Container(color: Colors.red),
      onDismissed: (direction) {
        multitree.deleteNode(rootId, widget.nodeList);
        widget.nodeList = multitree.build();
      },
      child: GestureDetector(
        onLongPress: () {
          parentId = rootId;
          textFieldTask = Task.changeTitle;
          widget.toggleVisibility();
        },
        child: ExpansionTile(
          leading: Padding(
            padding: EdgeInsets.fromLTRB(level * 10, 0, 0, 0),
            child: Checkbox(
              value: widget.nodeList[rootId]!.status ==
                      multitree.TaskStatus.Finished
                  ? true
                  : false,
              onChanged: (bool? value) {
                setState(() {
                  // just toggle taskstatus
                  widget.nodeList[rootId]!.status = value!
                      ? multitree.TaskStatus.Finished
                      : multitree.TaskStatus.Pending;
                  multitree.changeStatus(
                      rootId, widget.nodeList[rootId]!.status);
                });
              },
            ),
          ),
          title: Text(
            widget.nodeList[rootId]!.title,
            style: TextStyle(
              decoration: widget.nodeList[rootId]!.status ==
                      multitree.TaskStatus.Finished
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          children: generateChildWidgetList(rootId, level + 1),
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              textFieldTask = Task.addChild;
              parentId = rootId;
              widget.toggleVisibility();
            },
          ),
          onExpansionChanged: (value) {
            widget.setVisibilityFalse();
          },
        ),
      ),
    );
  }

  List<Widget> generateChildWidgetList(final int rootId, double level) {
    List<Widget> childWidgetList = [];

    widget.nodeList[rootId]!.childIdList.forEach((childId) {
      if (childId == null) return;
      childWidgetList.add(buildWidgetTree(childId, level));
    });

    return childWidgetList;
  }

  void addTask(String newNodeTitle) {
    // add a new child node
    multitree.Node newChild =
        multitree.Node(newNodeTitle, [], multitree.TaskStatus.Pending);
    newChild.parentIdList.add(parentId);

    setState(() {
      widget.nodeList[parentId]!.childIdList.add(widget.nodeList.length);
      widget.nodeList.add(newChild);
    });

    // now create a new directory
    multitree.addNewChildNode(
        parentId, widget.nodeList.length - 1, newNodeTitle);
  }

  void changeTitle(String newTitle) {
    widget.nodeList[parentId]!.title = newTitle;
    multitree.changeTitle(parentId, newTitle);
  }

  Task textfieldTask() {
    if (textFieldTask == Task.changeTitle) {
      return Task.changeTitle;
    } else {
      return Task.addChild;
    }
  }
}
