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

const rootTitleName = 'Default List';

class FsException implements Exception {
  final String cause;

  FsException(this.cause);

  @override
  String toString() => "FsException: " + cause;
}

void ensureRootNodeDir(String dataDirName) {
  Directory(path.join(dataDirName, '0')).createSync(recursive: true);

  File rootTitleFile = File(path.join(dataDirName, '0', 'title'));
  if (!rootTitleFile.existsSync()) {
    rootTitleFile.writeAsStringSync(rootTitleName);
  }

  File rootStatusFile = File(path.join(dataDirName, '0', 'status'));
  if (!rootStatusFile.existsSync()) rootStatusFile.writeAsStringSync('0');

  File rootStartDateFile = File(path.join(dataDirName, '0', 'startdate'));
  if (!rootStartDateFile.existsSync()) {
    rootStartDateFile.writeAsStringSync(DateTime.now().toString());
  }

  File rootDueDateFile = File(path.join(dataDirName, '0', 'duedate'));
  if (!rootDueDateFile.existsSync()) {
    rootDueDateFile.writeAsStringSync(DateTime.now().toString());
  }

  File rootPriorityFile = File(path.join(dataDirName, '0', 'priority'));
  if (!rootPriorityFile.existsSync()) rootPriorityFile.writeAsStringSync('0');
}

NodeList multiTreeFromFs(final String dataDirName) {
  final NodeList nodeList = [];

  for (var entity in Directory(dataDirName).listSync()) {
    if (entity is! Directory) {
      throw FsException("${entity.path} is not a valid directory.");
    }

    final id = _idFromDir(entity.path);
    final title = _titleFromFile(entity.path);
    final status = _statusFromFile(entity.path);
    final startDate = _dateFromFile(entity.path, "startdate");
    final dueDate = _dateFromFile(entity.path, "duedate");
    final priority = _priorityFromFile(entity.path);
    final childIdList = _childIdListFromFs(entity.path);

    final node = Node(title, childIdList, status, startDate, dueDate, priority);

    nodeList.adjust(id, node);
  }

  nodeList.populateParentIds();

  return nodeList;
}

void addNodeData(final String dataDirName, final int id, final int parentId,
    final String title) {
  Directory(path.join(dataDirName, '$id')).createSync();
  File(path.join(dataDirName, '$id', 'title')).writeAsStringSync(title);
  File(path.join(dataDirName, '$id', 'status')).writeAsStringSync('0');
  File(path.join(dataDirName, '$id', 'priority')).writeAsStringSync('0');
  File(path.join(dataDirName, '$id', 'startdate'))
      .writeAsStringSync(DateTime.now().toString());
  File(path.join(dataDirName, '$id', 'duedate'))
      .writeAsStringSync(DateTime.now().toString());
  File(path.join(dataDirName, '$parentId', '$id')).createSync();
}

void modifyTitle(final String dataDirName, final int id, final String title) {
  File(path.join(dataDirName, '$id', 'title')).writeAsStringSync(title);
}

void modifyStatus(
    final String dataDirName, final int id, final TaskStatus status) {
  File(path.join(dataDirName, '$id', 'status'))
      .writeAsStringSync('${status.index}');
}

void modifyDate(final String dataDirName, final int id, final DateTime date,
    final String type) {
  File(path.join(dataDirName, '$id', type)).writeAsStringSync(date.toString());
}

void modifyPriority(
    final String dataDirName, final int id, final Priority pri) {
  File(path.join(dataDirName, '$id', 'priority'))
      .writeAsStringSync('${pri.index}');
}

int _idFromDir(final String nodeDirName) {
  final id = _tryParseUint(path.basename(nodeDirName));
  if (id == null)
    throw FsException('$nodeDirName is not a valid node directory');

  return id;
}

String _titleFromFile(final String nodeDirName) {
  final titleFile = File(path.join(nodeDirName, 'title'));
  if (!titleFile.existsSync())
    throw FsException('$nodeDirName does not contain a title file');

  return titleFile.readAsStringSync();
}

TaskStatus _statusFromFile(final String nodeDirName) {
  final statusFile = File(path.join(nodeDirName, 'status'));
  if (!statusFile.existsSync())
    throw FsException('$nodeDirName does not contain a status file');

  final statusStr = statusFile.readAsStringSync();

  final statusNum = _tryParseUint(statusStr);
  if (statusNum == null)
    throw FsException('$nodeDirName contains invalid status: $statusNum');

  return TaskStatus.values[statusNum];
}

DateTime _dateFromFile(final String nodeDirName, final String fileName) {
  final dateFile = File(path.join(nodeDirName, fileName));
  if (!dateFile.existsSync())
    throw FsException('$nodeDirName does not contain a $fileName file');

  final dateStr = dateFile.readAsStringSync();

  final date = DateTime.tryParse(dateStr);
  if (date == null)
    throw FsException('$nodeDirName contains invalid date: $dateStr');

  return date;
}

Priority _priorityFromFile(final String nodeDirName) {
  final priorityFile = File(path.join(nodeDirName, 'priority'));
  if (!priorityFile.existsSync()) {
    throw FsException('$nodeDirName does not contain a priority file');
  }

  final priorityStr = priorityFile.readAsStringSync();

  final priorityNum = _tryParseUint(priorityStr);
  if (priorityNum == null) {
    throw FsException('$nodeDirName contains invalid priority: $priorityNum');
  }

  return Priority.values[priorityNum];
}

List<int> _childIdListFromFs(final String nodeDirName) {
  final List<int> childIdList = [];
  for (var entity in Directory(nodeDirName).listSync()) {
    final childId = _tryParseUint(path.basename(entity.path));
    if (childId == null) continue;
    childIdList.add(childId);
  }

  return childIdList;
}

int? _tryParseUint(final String str) {
  final number = int.tryParse(str);
  if (!_startsWithDigit(str) || !_endsWithDigit(str) || number == null) {
    return null;
  }
  return number;
}

bool _startsWithDigit(final String str) => (str.codeUnitAt(0) ^ 0x30) <= 9;
bool _endsWithDigit(final String str) =>
    (str.codeUnitAt(str.length - 1) ^ 0x30) <= 9;

void deleteNodeHelper(String dataDirName, int nodeId) {
  List<int> childrenFoldersName = _childIdListFromFs(dataDirName + "/$nodeId");
  if (childrenFoldersName.isEmpty) {
    Directory(dataDirName + "/$nodeId").deleteSync(recursive: true);
  } else {
    for (var x in childrenFoldersName) {
      deleteNodeHelper(dataDirName, x);
    }
    Directory(dataDirName + "/$nodeId").deleteSync(recursive: true);
  }
}

void deleteNode(String dataDirName, int nodeId, int parentId) {
  deleteNodeHelper(dataDirName, nodeId);
  File(dataDirName + "/$parentId" + "/$nodeId").deleteSync();
}
