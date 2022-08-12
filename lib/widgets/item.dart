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

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:tack/widgets/multitree.dart';
import 'package:tack/widgets/flattree.dart';
import 'package:tack/multitree/nodelist.dart';
import 'package:tack/multitree/fs.dart';
import 'package:tack/util/timutil.dart';
import 'package:tack/widgets/taskoptions.dart';

extension Color1 on Priority {
  MaterialColor getColor() {
    switch (this) {
      case Priority.Low:
        return Colors.blue;
      case Priority.Medium:
        return Colors.yellow;
      case Priority.High:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class Item extends StatefulWidget {
  static const indentWidth = 20.0;
  static const padding = 5.0;

  final List<int> pathbuf;
  int depth = 0;
  int unlisted = 0;

  Item(this.pathbuf, this.depth);
  Item.root(this.pathbuf);

  @override
  State<Item> createState() => ItemState();

  int get id => pathbuf[pathbuf.length - 1];
}

class ItemState extends State<Item> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    final nodeList = MultitreeWidget.of(context).nodeList;
    final text = widget.unlisted <= 1
        ? nodeList[widget.id]!.title
        : "${widget.unlisted} unlisted";

    return Container(
      margin: EdgeInsets.only(left: Item.indentWidth * widget.depth),
      child: ListTile(
        tileColor: const Color(0xff232329),
        // dense: true,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        leading: Checkbox(
            side: BorderSide(
              color: nodeList[widget.id]!.pri.getColor(),
            ),
            value: isChecked,
            onChanged: (newIsChecked) {
              isChecked = newIsChecked!;
              setState(() {});
            }),
        title: GestureDetector(
          onLongPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      TaskOptionActivity(nodeList[widget.id]!, widget.id)),
            );
          },
          onTap: () {
            FlattreeContext.of(context).updateRoot(widget.pathbuf);
          },
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        subtitle: Text(
          exactDate(nodeList[widget.id]!.dueDate),
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        trailing: Wrap(children: [
          //delete button
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
            onPressed: () {
              // file system
              deleteNode(MultitreeWidget.dataDirName, widget.id,
                  nodeList[widget.id]!.parentIdList[0]);

              // data structure
              nodeList.deleteChild(widget.id);

              MultitreeWidget.of(context).buildMultitree();

              // UI update
              FlattreeContext.of(context).update();
            },
          ),
          // add button
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              // data structure
              nodeList.addChild(widget.id, "New Task");
              // file system
              addNodeData(MultitreeWidget.dataDirName, nodeList.length - 1,
                  widget.id, "New Task");
              // UI update
              FlattreeContext.of(context).update();
              MultitreeWidget.of(context).buildMultitree();

              // print(nodeList[widget.id]!.parentIdList);
            },
          ),
        ]),
      ),
    );
  }
}
