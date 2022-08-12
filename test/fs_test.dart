import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:tack/multitree/fs.dart';

void main() {
  test('Add Node Data', () {
    const dir = 'testcase1';
    ensureRootNodeDir(dir);

    addNodeData(dir, 1, 0, "One");
    expect(File('$dir/0/1').existsSync(), true);
    expect(Directory('$dir/1').existsSync(), true);
    expect(File('$dir/1/title').readAsStringSync(), 'One');
    expect(File('$dir/1/status').readAsStringSync(), '0');

    Directory(dir).delete(recursive: true);
  });

  // test('Delete Node from parent having one child', () {
  //   const dir = 'testcase2';
  //   ensureRootNodeDir(dir);
  //
  //   addNodeData(dir, 1, 0, "One");
  //   deleteNode(dir,1,)
  //   // addNodeData(dir, 1, 0, "One");
  //   expect(File('$dir/0/1').existsSync(), true);
  //   expect(Directory('$dir/1').existsSync(), true);
  //   expect(File('$dir/1/title').readAsStringSync(), 'One');
  //   expect(File('$dir/1/status').readAsStringSync(), '0');
  //
  //   Directory(dir).delete(recursive: true);
  // });
  test('Delete child of a grandpapa having one child', () {
    const dir = 'testcase3';
    ensureRootNodeDir(dir);

    addNodeData(dir, 1, 0, "One");
    addNodeData(dir, 2, 1, "Two");
    deleteNode(dir, 1, 0);
    expect(Directory('$dir/0').existsSync(), true);
    expect(Directory('$dir/1').existsSync(), false);
    expect(Directory('$dir/2').existsSync(), false);

    expect(File('$dir/0/1').existsSync(), false);

    Directory(dir).delete(recursive: true);
  });
  test('bada sa test case', () {
    const dir = 'testcasenumberpatanahi';
    ensureRootNodeDir(dir);

    addNodeData(dir, 1, 0, "One");
    addNodeData(dir, 2, 0, "Two");
    addNodeData(dir, 3, 1, "Three");
    addNodeData(dir, 4, 1, "Four");
    addNodeData(dir, 5, 2, "Five");
    addNodeData(dir, 6, 2, "Six");
    addNodeData(dir, 7, 5, "Seven");

    deleteNode(dir, 2, 0);
    expect(Directory('$dir/0').existsSync(), true);
    expect(Directory('$dir/1').existsSync(), true);
    expect(Directory('$dir/2').existsSync(), false);
    expect(Directory('$dir/3').existsSync(), true);
    expect(Directory('$dir/4').existsSync(), true);
    expect(Directory('$dir/5').existsSync(), false);
    expect(Directory('$dir/6').existsSync(), false);
    expect(Directory('$dir/7').existsSync(), false);

    expect(File('$dir/0/1').existsSync(), true);
    expect(File('$dir/0/2').existsSync(), false);
    expect(File('$dir/1/3').existsSync(), true);
    expect(File('$dir/1/4').existsSync(), true);

    Directory(dir).delete(recursive: true);
  });
}
