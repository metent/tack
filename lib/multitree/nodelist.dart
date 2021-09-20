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

typedef NodeList = List<Node?>;

class CorruptedDataException implements Exception {}

enum TaskStatus {
  Pending,
  Finished,
}

class Node {
  String title;
  final List<int> parentIdList = [];
  final List<int> childIdList;
  TaskStatus status;

  Node(this.title, this.childIdList, this.status);
}

extension Multitree on NodeList {
  void adjust(int id, Node node) {
    if (id + 1 > this.length) {
      for (int i = this.length; i < id; i++) this.add(null);
      this.add(node);
    } else if (this[id] != null) {
      throw CorruptedDataException();
    } else {
      this[id] = node;
    }
  }

  void populateParentIds() {
    for (int id = 0; id < this.length; id++) {
      Node? node = this[id];
      if (node == null) continue;

      for (int childId in node.childIdList) {
        final childNode = this[childId];
        if (childNode == null) throw CorruptedDataException();
        childNode.parentIdList.add(id);
      }
    }
  }

  void addChild(int parentId, String title) {
    final Node childNode = Node(title, [], TaskStatus.Pending);
    childNode.parentIdList.add(parentId);

    final Node? parentNode = this[parentId];
    if (parentNode == null) return;
    parentNode.childIdList.add(this.length);

    this.add(childNode);
  }
}
