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

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

import 'package:boxy/boxy.dart';

import 'package:tack/widgets/multitree.dart';
import 'package:tack/widgets/item.dart';
import 'package:tack/multitree/nodelist.dart';

class Flattree extends StatefulWidget {
  const Flattree({Key? key}) : super(key: key);

  @override
  State<Flattree> createState() => FlattreeState();
}

class FlattreeState extends State<Flattree> {
  List<int> pathbuf = [0];

  @override
  Widget build(BuildContext context) => FlattreeContext(
      child: GestureDetector(
        onHorizontalDragEnd: (_) {
          back();
        },
        child: Container(
          margin: EdgeInsets.fromLTRB(25, 15, 25, 15),
          child: CustomBoxy(
            delegate: FlattreeBoxyDelegate(pathbuf),
            children: [],
          ),
        ),
      ),
      update: update,
      updateRoot: updateRoot);

  void updateRoot(List<int> newPathBuf) {
    pathbuf = newPathBuf;
    setState(() {});
  }

  void update() {
    setState(() {});
  }

  void back() {
    if (pathbuf.length != 1) {
      pathbuf = pathbuf.sublist(0, pathbuf.length - 1);
      setState(() {});
    }
  }
}

typedef VoidCallbackInt = void Function(List<int>);
typedef VoidCallback = void Function();

class FlattreeContext extends InheritedWidget {
  VoidCallback update;
  VoidCallbackInt updateRoot;

  static FlattreeContext of(BuildContext context) {
    if (context.dependOnInheritedWidgetOfExactType<FlattreeContext>() == null) {
      print("noooo");
    }
    return context.dependOnInheritedWidgetOfExactType<FlattreeContext>()!;
  }

  FlattreeContext(
      {Key? key,
      required Widget child,
      required VoidCallback update,
      required VoidCallbackInt updateRoot})
      : update = update,
        updateRoot = updateRoot,
        super(key: key, child: child);

  @override
  bool updateShouldNotify(FlattreeContext oldContext) => true;
}

class FlattreeBoxyDelegate extends BoxyDelegate {
  final List<int> rootPathBuf;

  FlattreeBoxyDelegate(this.rootPathBuf);

  @override
  bool shouldRelayout(FlattreeBoxyDelegate old) => true;

  @override
  Size layout() {
    final context = LayoutContext(MultitreeWidget.of(buildContext).nodeList);

    addItem(Item.root([...rootPathBuf]), context);

    var currentDepth = 0;
    var maxDepth = 0;
    OUTER:
    while (context.filledHeight < constraints.maxHeight) {
      var hasChildren = false;
      final length = context.itemBoxyList.length;
      for (var i = 0; i < length; i++) {
        final item = context.itemBoxyList[i].parentData;
        if (item.depth != currentDepth) continue;

        final childId = context.ciList[item.id]!.next();
        if (childId == null) continue;

        hasChildren = true;
        maxDepth = currentDepth + 1;

        if (!addItem(Item([...item.pathbuf, childId], item.depth + 1), context)) break OUTER;
      }

      if (!hasChildren) {
        if (maxDepth > currentDepth) {
          currentDepth += 1;
        } else
          break;
      }
    }

    populatedUnlisted(context);

    sortItemList(context);

    positionItems(context);

    return Size(constraints.maxWidth, context.filledHeight);
  }

  bool addItem(final Item item, LayoutContext context) {
    final itemBoxy = inflate(item);
    itemBoxy.parentData = item;
    itemBoxy.layout(constraints);

    if (context.filledHeight + itemBoxy.size.height + 10 >
        constraints.maxHeight) {
      itemBoxy.ignore();
      return false;
    }
    context.filledHeight += itemBoxy.size.height + 10;

    context.itemBoxyList.add(itemBoxy);
    context.lastChildIndexList[item.id] = context.itemBoxyList.length - 1;

    return true;
  }

  void populatedUnlisted(LayoutContext context) {
    for (var i = 0; i < context.ciList.length; i++) {
      final ci = context.ciList[i];
      if (ci == null) continue;

      final id = context.lastChildIndexList[i];
      final unlisted = ci._childIdList.length - ci._childIndex;

      if (id == 0 || unlisted == 0) continue;

      context.itemBoxyList[id].parentData.unlisted = unlisted + 1;
    }
  }

  void sortItemList(LayoutContext context) =>
      context.itemBoxyList.sort((lItemBoxy, rItemBoxy) {
        final lItem = lItemBoxy.parentData;
        final rItem = rItemBoxy.parentData;
        var l = 0;
        var r = 0;
        for (; l < lItem.pathbuf.length && r < rItem.pathbuf.length; l++, r++) {
          final lNode = context.nodeList[lItem.pathbuf[l]]!;
          final rNode = context.nodeList[rItem.pathbuf[r]]!;

          final priComp = lNode.pri.compareTo(rNode.pri);
          if (priComp != 0) return -priComp;

          final dateComp = lNode.dueDate.compareTo(rNode.dueDate);
          if (dateComp != 0) return dateComp;

          final comp = lNode.title.compareTo(rNode.title);
          if (comp != 0) return comp;
        }

        if (l == lItem.pathbuf.length) return -1;
        return 1;
      });

  void positionItems(LayoutContext context) {
    double height = 0;
    for (var itemBoxy in context.itemBoxyList) {
      itemBoxy.position(Offset(0, height));
      height += itemBoxy.size.height + 10;
    }
  }
}

class LayoutContext {
  final itemBoxyList = <BoxyChild>[];
  final NodeList nodeList;
  final List<int> lastChildIndexList;
  final List<ChildIterator?> ciList;
  double filledHeight = 0;

  LayoutContext(this.nodeList)
      : lastChildIndexList = List.filled(nodeList.length, 0, growable: false),
        ciList = List.generate(nodeList.length, (id) {
          return nodeList[id] != null ? ChildIterator(nodeList, id) : null;
        });
}

class ChildIterator {
  late final _childIdList;
  int _childIndex = 0;

  ChildIterator(final NodeList nodeList, final int parentId) {
    _childIdList = [...nodeList[parentId]!.childIdList];
    _childIdList
        .sort((l, r) => nodeList[l]!.title.compareTo(nodeList[r]!.title));
  }

  int? next() {
    if (_childIndex >= _childIdList.length) return null;
    _childIndex += 1;
    return _childIdList[_childIndex - 1];
  }
}
