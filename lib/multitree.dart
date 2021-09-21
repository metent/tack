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

import 'package:path/path.dart' as path;

import 'package:tack/multitree/fs.dart';
import 'package:tack/multitree/nodelist.dart';

import 'dart:io';

export 'package:tack/multitree/nodelist.dart' show Node, TaskStatus, InvalidDataException;

const dataDirName = "test-tree";

List<Node?> build() {
  return multitreeFromFs(dataDirName);
}

void changeStatus(int nodeId, TaskStatus status) {
  int nodeStatusNum = status == TaskStatus.Finished ? 1 : 0;
  File(path.join(dataDirName, "$nodeId", "status"))
      .writeAsStringSync(nodeStatusNum.toString());
}

void addNewChildNode(var parentId, int id, String titleText) {
  addNodeData(dataDirName, id, parentId, titleText);
}

void deleteNode(var nodeID, List<Node?> nodeList) {
  // delete all its children
  for (var childDir in nodeList[nodeID]!.childIdList) {
    deleteNode(childDir, nodeList);
    // Directory(dataDirName + "/$childDir").deleteSync(recursive: true);
  }

  // delete the task itself
  Directory(path.join(dataDirName, "$nodeID")).deleteSync(recursive: true);

  // delete its folder in parents
  for (var parentDir in nodeList[nodeID]!.parentIdList) {
    File(path.join(dataDirName, "$parentDir", "$nodeID")).deleteSync();
  }
}

void changeTitle(int nodeID, String newTitle) {
  File(path.join(dataDirName, "$nodeID", "title")).writeAsStringSync(newTitle);
}
