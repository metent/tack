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

import 'package:flutter/widgets.dart';

import 'package:tack/multitree/nodelist.dart';
import 'package:tack/multitree/fs.dart' as fs;

class MultitreeWidget extends InheritedWidget {
  static const dataDirName = 'test-tree';

  late final NodeList nodeList;

  static MultitreeWidget of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MultitreeWidget>()!;
  }

  MultitreeWidget({Key? key, required Widget child}) : super(key: key, child: child) {
    fs.ensureRootNodeDir(dataDirName);
    nodeList = fs.multitreeFromFs(dataDirName);
  }

  @override
  bool updateShouldNotify(MultitreeWidget oldMtree) => true;
}
