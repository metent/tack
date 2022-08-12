import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:tack/multitree/nodelist.dart';
import 'package:tack/multitree/fs.dart';
import 'package:tack/widgets/multitree.dart';

import 'flattree.dart';

const textStyle1 = TextStyle(
  fontSize: 15.0,
  // fontWeight: FontWeight.bold,
  color: Colors.black,
// backgroundColor: activeColor,
);

class TaskOptionActivity extends StatefulWidget {
  Node _node;
  int _id;

  TaskOptionActivity(this._node, this._id, {Key? key}) : super(key: key);

  @override
  _TaskOptionActivityState createState() => _TaskOptionActivityState();
}

class _TaskOptionActivityState extends State<TaskOptionActivity> {
  late TextEditingController _controller1;
  late TextEditingController _controller2;
  late TextEditingController _controller3;
  Priority _pri = Priority.None;

  String _valueChanged1 = '';

  String _valueToValidate1 = '';

  String _valueSaved1 = '';
  String _valueChanged2 = '';

  String _valueToValidate2 = '';

  String _valueSaved2 = '';

  @override
  void initState() {
    super.initState();
    _controller1 =
        TextEditingController(text: widget._node.startDate.toString());
    _controller2 = TextEditingController(text: widget._node.dueDate.toString());
    _controller3 = TextEditingController(text: widget._node.title);
    _pri = widget._node.pri;
    String lsHour = TimeOfDay.now().hour.toString().padLeft(2, '0');
    String lsMinute = TimeOfDay.now().minute.toString().padLeft(2, '0');

    // _getValue();
  }

  /// This implementation is just to simulate a load data behavior
  /// from a data base sqlite or from a API
  Future<void> _getValue() async {
    await Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _controller1.text = '2000-09-20 14:30';
        _controller2.text = '2000-09-20 14:30';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0XFF232329),
        title: Text(
          widget._node.title,
          // style: txtstyle1,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              widget._node.title = _controller3.text;
              modifyTitle(
                  MultitreeWidget.dataDirName, widget._id, widget._node.title);

              widget._node.startDate = DateTime.parse(_controller1.text);
              modifyDate(MultitreeWidget.dataDirName, widget._id,
                  widget._node.startDate, 'startdate');

              widget._node.dueDate = DateTime.parse(_controller2.text);
              modifyDate(MultitreeWidget.dataDirName, widget._id,
                  widget._node.startDate, 'duedate');

              widget._node.pri = _pri;
              modifyPriority(
                  MultitreeWidget.dataDirName, widget._id, widget._node.pri);

              setState(() {});
            },
          )
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(30),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelStyle: textStyle1,
                border: UnderlineInputBorder(),
                labelText: 'Title',
                hintText: 'Task Title',
              ),
              controller: _controller3,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const Text(
                  'Priority: ',
                  style: textStyle1,
                ),
                Radio<Priority>(
                    value: Priority.None,
                    activeColor: Colors.white,
                    groupValue: _pri,
                    fillColor:
                        MaterialStateColor.resolveWith((states) => Colors.grey),
                    onChanged: (Priority? value) {
                      _pri = value!;
                      setState(() {});
                    }),
                Radio<Priority>(
                    value: Priority.Low,
                    activeColor: Colors.white,
                    groupValue: _pri,
                    fillColor: MaterialStateColor.resolveWith(
                        (states) => Colors.lightBlue),
                    onChanged: (Priority? value) {
                      _pri = value!;
                      setState(() {});
                    }),
                Radio<Priority>(
                    value: Priority.Medium,
                    activeColor: Colors.white,
                    groupValue: _pri,
                    fillColor: MaterialStateColor.resolveWith(
                        (states) => Colors.yellow),
                    onChanged: (Priority? value) {
                      _pri = value!;
                      setState(() {});
                    }),
                Radio<Priority>(
                    value: Priority.High,
                    activeColor: Colors.white,
                    groupValue: _pri,
                    fillColor:
                        MaterialStateColor.resolveWith((states) => Colors.red),
                    onChanged: (Priority? value) {
                      _pri = value!;
                      setState(() {});
                    }),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            DateTimePicker(
              type: DateTimePickerType.dateTimeSeparate,
              dateMask: 'd MMM, yyyy',
              cursorColor: Colors.white,
              controller: _controller1,
              // initialValue: widget._node.startDate.toString(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              icon: const Icon(Icons.event),
              dateLabelText: 'Date',
              timeLabelText: "Hour",
              fieldHintText: 'Start Date',
              //use24HourFormat: false,
              //locale: Locale('pt', 'BR'),
              selectableDayPredicate: (date) {
                return true;
              },
              // onChanged: (val) {
              //
              //   // print(widget._node.startDate.toString());
              // }
              // validator: (val) {
              //   setState(() => _valueToValidate1 = val ?? '');
              //   return null;
              // },
              // onSaved: (val) => setState(() => _valueSaved1 = val ?? ''),
            ),
            const SizedBox(
              height: 20,
            ),
            DateTimePicker(
              type: DateTimePickerType.dateTimeSeparate,
              dateMask: 'd MMM, yyyy',
              controller: _controller2,
              cursorColor: Colors.white,
              // initialValue: ,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              fieldHintText: 'Due Date',
              icon: const Icon(Icons.event),
              dateLabelText: 'Date',
              timeLabelText: "Hour",
              //use24HourFormat: false,
              //locale: Locale('pt', 'BR'),
              selectableDayPredicate: (date) {
                return true;
              },
              // onChanged: (val) {
              //   setState(() => widget._node.dueDate = DateTime.parse(val));
              //   modifyDate(MultitreeWidget.dataDirName, widget._id,
              //       widget._node.dueDate, 'duedate');
              //   // print(widget._node.dueDate.toString());
              // }
              // validator: (val) {
              //   setState(() => _valueToValidate2 = val ?? '');
              //   return null;
              // },
              // onSaved: (val) => setState(() => _valueSaved2 = val ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}
