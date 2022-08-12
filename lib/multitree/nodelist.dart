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

import 'package:flutter/gestures.dart';

typedef NodeList = List<Node?>;

class MultitreeException {
  final String cause;

  MultitreeException(this.cause);

  String toString() => "MultitreeException: " + cause;
}

enum TaskStatus {
  Pending,
  Finished,
}

enum Priority { None, Low, Medium, High }

extension Compare on Priority {
  int compareTo(Priority other) {
    return this.index.compareTo(other.index);
  }
}

class Node {
  String title;
  final List<int> parentIdList = [];
  final List<int> childIdList;
  TaskStatus status;
  DateTime startDate;
  DateTime dueDate;
  Priority pri;

  Node(this.title, this.childIdList, this.status, this.startDate, this.dueDate,
      this.pri);
}

extension Multitree on NodeList {
  void adjust(final int id, final Node node) {
    if (id + 1 > this.length) {
      for (var i = this.length; i < id; i++) this.add(null);
      this.add(node);
    } else {
      assert(this[id] == null);
      this[id] = node;
    }
  }

  void populateParentIds() {
    for (var id = 0; id < this.length; id++) {
      final node = this[id];
      if (node == null) continue;

      for (var childId in node.childIdList) {
        if (childId >= this.length)
          throw MultitreeException(
              'Node ID $id has non-existent child $childId');
        final childNode = this[childId];
        if (childNode == null)
          throw MultitreeException(
              'Node ID $id has non-existent child $childId');
        childNode.parentIdList.add(id);
      }
    }
  }

  void addChild(final int parentId, final String title) {
    final childNode = Node(title, [], TaskStatus.Pending, DateTime.now(),
        DateTime.now(), Priority.None);

    childNode.parentIdList.add(parentId);

    final parentNode = this[parentId];
    if (parentNode == null) return;
    parentNode.childIdList.add(this.length);

    this.add(childNode);

    // for (int i = 0; i < this.length; i++) {
    //   print("Node no. $i-->");
    //   if (this[i] != null) {
    //     print("Parent Id is: ${this[i]?.parentIdList[0]}");
    //     print("Child Id List is -> ");
    //     if (this[i]?.childIdList != null) {
    //       List<int>? node1 = this[i]?.childIdList;
    //       for (var child in node1!) {
    //         print("$child ,");
    //       }
    //     }
    //   } else {
    //     print("This Node is null;");
    //   }
    // }
  }

  void deleteChild(final int id) {
    final List<int> toDelete = [];

    // node list ke under nodes hai ya null hai
    // har node ke under child id list hai aur parent id list hai

    for (var childId in this[id]!.childIdList) {
      _deleteChild(childId, toDelete);
    }

    for (var x in toDelete) {
      this[x] = null;
    }
    if (id != 0) {
      final parent = this[id]!.parentIdList[0];
      this[parent]!.childIdList.remove(id);
    }
    this[id] = null;

    // for (int i = 0; i < this.length; i++) {
    //   print("Node no. $i-->");
    //   if (this[i] != null) {
    //     print("Parent Id is: ${this[i]?.parentIdList[0]}");
    //     print("Child Id List is -> ");
    //     if (this[i]?.childIdList != null) {
    //       List<int>? node1 = this[i]?.childIdList;
    //       for (var child in node1!) {
    //         print("$child ,");
    //       }
    //     }
    //   } else {
    //     print("This Node is null;");
    //   }
    // }
  }

  void _deleteChild(final int id, List<int> toDelete) {
    for (var childId in this[id]!.childIdList) {
      _deleteChild(childId, toDelete);
    }
    toDelete.add(id);
  }
}
