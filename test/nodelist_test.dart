import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tack/multitree/nodelist.dart';

void main() {
  test('Populate Parent Ids', () {
    final NodeList nodelist = [
      Node('Zero', [1], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
      Node('One', [], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
    ];

    nodelist.populateParentIds();

    expect(listEquals(nodelist[0]!.parentIdList, []), true);
    expect(listEquals(nodelist[1]!.parentIdList, [0]), true);
  });

  test('Add Child', () {
    final NodeList nodelist = [
      Node('Zero', [1], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
      Node('One', [], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
    ];
    nodelist.populateParentIds();

    nodelist.addChild(0, 'Two');

    expect(nodelist[0]!.childIdList.contains(2), true);
    expect(nodelist[2]!.parentIdList.contains(0), true);
  });

  test('Delete Child 1', () {
    final NodeList nodelist = [
      Node('Zero', [1], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
      Node('One', [], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
    ];
    nodelist.populateParentIds();

    nodelist.deleteChild(1);

    expect(nodelist[0]!.childIdList.contains(1), false);
    expect(nodelist[1], null);
  });

  test('Delete Child of child of root', () {
    final NodeList nodelist = [
      Node('Zero', [1], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
      Node('One', [2], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
      Node('Two', [], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
    ];
    nodelist.populateParentIds();

    nodelist.deleteChild(2);

    expect(nodelist[1]!.childIdList.contains(2), false);
    expect(nodelist[0]!.childIdList.contains(1), true);
    expect(nodelist[2], null);
  });
  test('Delete Child ', () {
    final NodeList nodelist = [
      Node('Zero', [1], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
      Node('One', [2, 3], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
      Node('Two', [4], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
      Node('Three', [], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
      Node('Four', [], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
    ];
    nodelist.populateParentIds();

    nodelist.deleteChild(2);

    expect(nodelist[0]!.childIdList.contains(1), true);
    expect(nodelist[1]!.childIdList.contains(2), false);
    expect(nodelist[1]!.childIdList.contains(3), true);
    expect(nodelist[0]!.childIdList, [1]);
    expect(nodelist[1]!.childIdList, [3]);
    expect(nodelist[3]!.childIdList, []);
    expect(nodelist[2], null);
    expect(nodelist[4], null);
  });

  test('Delete direct Child of grandPapa', () {
    final NodeList nodelist = [
      Node('Zero', [1], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
      Node('One', [2], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
      Node('Two', [], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
    ];
    nodelist.populateParentIds();

    nodelist.deleteChild(1);
    expect(nodelist[0]!.childIdList, []);
    expect(nodelist[1], null);
    expect(nodelist[2], null);
  });
  test('Delete one child of parent that have 2 children', () {
    final NodeList nodelist = [
      Node('Zero', [1, 2], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
      Node('One', [], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
      Node('Two', [], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
    ];
    nodelist.populateParentIds();

    nodelist.deleteChild(1);
    expect(nodelist[0]!.childIdList, [2]);
    expect(nodelist[1], null);
    expect(nodelist[2]!.childIdList, []);
  });
  test('Delete one child of parent that have 2 children one of which is parent',
      () {
    final NodeList nodelist = [
      Node('Zero', [1, 2], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
      Node('One', [3], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
      Node('Two', [], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
      Node('Three', [], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
    ];
    nodelist.populateParentIds();

    nodelist.deleteChild(1);
    expect(nodelist[0]!.childIdList, [2]);
    expect(nodelist[1], null);
    expect(nodelist[3], null);
    expect(nodelist[2]!.childIdList, []);
  });
  test('Tagda test', () {
    final NodeList nodelist = [
      Node('Zero', [1, 2, 3], TaskStatus.Pending, DateTime.now(),
          DateTime.now(), Priority.Low),
      Node('One', [4, 5], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
      Node('Two', [6, 7], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
      Node('Three', [], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
      Node('Four', [], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
      Node('Five', [], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
      Node('Six', [], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
      Node('Seven', [], TaskStatus.Pending, DateTime.now(), DateTime.now(),
          Priority.Low),
    ];
    nodelist.populateParentIds();

    nodelist.deleteChild(2);
    expect(nodelist[0]!.childIdList, [1, 3]);
    expect(nodelist[1]!.childIdList, [4, 5]);
    expect(nodelist[3]!.childIdList, []);
    expect(nodelist[4]!.childIdList, []);
    expect(nodelist[5]!.childIdList, []);
    expect(nodelist[2], null);
    expect(nodelist[6], null);
    expect(nodelist[7], null);
  });
}
