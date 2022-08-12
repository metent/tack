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
import 'package:flutter/material.dart';
import 'package:tack/widgets/multitree.dart';
import 'package:tack/widgets/flattree.dart';

void main() => runApp(Application());

class Application extends StatefulWidget {
  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  Widget build(BuildContext context) {
    return (MaterialApp(
      title: 'Tack',
      // theme: ThemeData(
      //     // primaryColor: Color(0xff0A0E21),
      //     accentColor: Colors.teal,
      //     scaffoldBackgroundColor: Color(0XFF18181B),
      //     textTheme: TextTheme(bodyText1: TextStyle(color: Colors.white))),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Tasks"),
          elevation: 0,
          backgroundColor: Color(0x00000000),
        ),
        body: MultitreeWidget(
          child: Flattree(),
        ),
        backgroundColor: const Color(0XFF18181B),
      ),
      debugShowCheckedModeBanner: false,
    ));
  }
}
