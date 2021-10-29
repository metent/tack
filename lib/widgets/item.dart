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

import 'package:tack/widgets/multitree.dart';

class Item extends StatefulWidget {
  static const indentWidth = 20.0;
  static const padding = 5.0;

  final List<int> pathbuf;
  int unlisted = 0;

  Item(this.pathbuf);

  @override State<Item> createState() => ItemState();

  int get id => pathbuf[pathbuf.length - 1];
  int get depth => pathbuf.length - 1;
}

class ItemState extends State<Item> {
  bool isChecked = false;

  @override Widget build(BuildContext context) {
    final nodeList = MultitreeWidget.of(context).nodeList;
    final text = widget.unlisted <= 1 ? nodeList[widget.id]!.title : "${widget.unlisted} unlisted";

    return Container(
      margin: EdgeInsets.only(left: Item.indentWidth * widget.depth),
      padding: EdgeInsets.all(Item.padding),
      child: Row(
        children: [
          Checkbox(value: isChecked, onChanged: (newIsChecked) {
            this.isChecked = newIsChecked!;
            setState(() {});
          }),
          Text(text),
        ]
      )
    );
  }
}
