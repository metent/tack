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

import 'dart:io';

const dataDirName = "test-tree";

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

class InvalidDataException implements Exception {}

List<Node?> build() {
  List<Node?> nodeList = [];

  final dataDir = Directory(dataDirName);
  for (var entity in dataDir.listSync()) {
    if (!(entity is Directory)) throw InvalidDataException();

    final nodeDir = Directory(entity.path);
    final nodeId = int.parse(entity.path.split('/').last);
    final nodeTitle = File(entity.path + '/title').readAsStringSync();
    final nodeStatusNum =
        int.parse(File(entity.path + '/status').readAsStringSync());
    final childIdList = childIdListFromFs(nodeDir);

    final node = Node(nodeTitle, childIdList, TaskStatus.values[nodeStatusNum]);

    if (nodeId + 1 > nodeList.length) {
      for (int i = nodeList.length; i < nodeId; i++) nodeList.add(null);
      nodeList.add(node);
    } else if (nodeList[nodeId] != null) {
      throw InvalidDataException();
    } else {
      nodeList[nodeId] = node;
    }
  }

  populateParentIds(nodeList);

  return nodeList;
}

List<int> childIdListFromFs(Directory nodeDir) {
  List<int> childIdList = [];

  for (var entity in nodeDir.listSync()) {
    final childId = int.tryParse(entity.path.split('/').last);
    if (childId == null) continue;
    childIdList.add(childId);
  }

  return childIdList;
}

void populateParentIds(List<Node?> nodeList) {
  for (int id = 0; id < nodeList.length; id++) {
    final parentNode = nodeList[id];
    if (parentNode == null) continue;
    for (int childId in parentNode.childIdList) {
      final childNode = nodeList[childId];
      if (childNode == null) throw InvalidDataException();

      childNode.parentIdList.add(id);
    }
  }
}

void changeStatus(int nodeID, TaskStatus status) {
  int nodeStatusNum = status == TaskStatus.Finished ? 1 : 0;
  File(dataDirName + "/$nodeID" + "/status")
      .writeAsStringSync(nodeStatusNum.toString());
}

void addNewChildNode(var parentID, int id, String titleText) {
  // create its directory and title
  Directory(dataDirName + "/$id").createSync();
  File(dataDirName + "/$id" + "/title").createSync();
  File(dataDirName + "/$id" + "/title").writeAsStringSync(titleText);
  File(dataDirName + "/$id" + "/status").createSync();
  File(dataDirName + "/$id" + "/status").writeAsStringSync("0");

  // add this to child of parent
  File(dataDirName + "/$parentID" + "/$id").createSync();
}

void deleteNode(var nodeID, List<Node?> nodeList) {
  // delete all its children
  for (var childDir in nodeList[nodeID]!.childIdList) {
    deleteNode(childDir, nodeList);
    // Directory(dataDirName + "/$childDir").deleteSync(recursive: true);
  }

  // delete the task itself
  Directory(dataDirName + "/$nodeID").deleteSync(recursive: true);

  // delete its folder in parents
  for (var parentDir in nodeList[nodeID]!.parentIdList) {
    File(dataDirName + "/$parentDir" + "/$nodeID").deleteSync();
  }
}

void changeTitle(int nodeID, String newTitle) {
  File(dataDirName + "/$nodeID" + "/title").writeAsStringSync(newTitle);
}
