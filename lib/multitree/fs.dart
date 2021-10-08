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

  String toString() => "FsException: " + cause;
}

void ensureRootNodeDir(String dataDirName) {
  Directory(path.join(dataDirName, '0')).createSync(recursive: true);

  File rootTitleFile = File(path.join(dataDirName, '0', 'title'));
  if (!rootTitleFile.existsSync()) rootTitleFile.writeAsStringSync(rootTitleName);

  File rootStatusFile = File(path.join(dataDirName, '0', 'status'));
  if (!rootStatusFile.existsSync()) rootStatusFile.writeAsStringSync('0');
}

NodeList multitreeFromFs(final String dataDirName) {
  final NodeList nodeList = [];

  for (var entity in Directory(dataDirName).listSync()) {
    if (!(entity is Directory)) throw FsException(
      "${entity.path} is not a valid directory."
    );

    final id = _idFromDir(entity.path);
    final title = _titleFromFile(entity.path);
    final status = _statusFromFile(entity.path);
    final childIdList = _childIdListFromFs(entity.path);

    final node = Node(title, childIdList, status);

    nodeList.adjust(id, node);
  }

  nodeList.populateParentIds();

  return nodeList;
}

void addNodeData(
  final String dataDirName,
  final int id,
  final int parentId,
  final String title
) {
  Directory(path.join(dataDirName, '$id')).createSync();
  File(path.join(dataDirName, '$id', 'title')).writeAsStringSync(title);
  File(path.join(dataDirName, '$id', 'status')).writeAsStringSync('0');
  File(path.join(dataDirName, '$parentId', '$id')).createSync();
}

int _idFromDir(final String nodeDirName) {
  final id = _tryParseUint(path.basename(nodeDirName));
  if (id == null) throw FsException('$nodeDirName is not a valid node directory');

  return id;
}

String _titleFromFile(final String nodeDirName) {
  final titleFile = File(path.join(nodeDirName, 'title'));
  if (!titleFile.existsSync()) throw FsException(
    '$nodeDirName does not contain a title file'
  );

  return titleFile.readAsStringSync();
}

TaskStatus _statusFromFile(final String nodeDirName) {
  final statusFile = File(path.join(nodeDirName, 'status'));
  if (!statusFile.existsSync()) throw FsException(
    '$nodeDirName does not contain a status file'
  );

  final statusStr = statusFile.readAsStringSync();

  final statusNum = _tryParseUint(statusStr);
  if (statusNum == null) throw FsException(
    '$nodeDirName contains invalid status: $statusNum'
  );

  return TaskStatus.values[statusNum];
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
  };
  return number;
}

bool _startsWithDigit(final String str) => (str.codeUnitAt(0) ^ 0x30) <= 9;
bool _endsWithDigit(final String str) => (str.codeUnitAt(str.length - 1) ^ 0x30) <= 9;
