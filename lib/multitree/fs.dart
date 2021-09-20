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

import 'package:path/path.dart' as path;

import 'nodelist.dart';

NodeList multitreeFromFs(String dataDirName) {
  final NodeList mtree = [];
  for (var entity in Directory(dataDirName).listSync()) {
    if (!(entity is Directory)) throw CorruptedDataException();

    final id = int.parse(path.basename(entity.path));
    final title = File(path.join(entity.path, 'title')).readAsStringSync();
    final status = TaskStatus.values[int.parse(
        File(path.join(entity.path, 'status')).readAsStringSync()
    )];
    final List<int> childIdList = _childIdListFromFs(entity.path);

    final node = Node(title, childIdList, status);

    mtree.adjust(id, node);
  }

  mtree.populateParentIds();

  return mtree;
}

void addNodeData(String dataDirName, int id, int parentId, String title) {
  Directory(path.join(dataDirName, '$id')).createSync();
  File(path.join(dataDirName, '$id', 'title')).writeAsStringSync(title);
  File(path.join(dataDirName, '$id', 'status')).writeAsStringSync('0');
  File(path.join(dataDirName, '$parentId', '$id')).createSync();
}

List<int> _childIdListFromFs(String nodeDirName) {
  List<int> childIdList = [];
  for (var entity in Directory(nodeDirName).listSync()) {
    final childId = int.tryParse(path.basename(entity.path));
    if (childId == null) continue;
    childIdList.add(childId);
  }

  return childIdList;
}
