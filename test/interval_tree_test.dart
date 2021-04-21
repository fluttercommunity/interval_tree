/*
 * Copyright (c) 2020 J-P Nurmi <jpnurmi@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import 'package:test/test.dart';

import 'package:interval_tree/interval_tree.dart';

void main() {
  final Matcher throwsStateError = throwsA(isA<StateError>());
  final Matcher throwsArgumentError = throwsA(isA<ArgumentError>());

  test('copy', () {
    final tree = IntervalTree([0, 10]);
    final of = IntervalTree.of(tree);
    final from = IntervalTree.from(tree);
    expect(of.toString(), tree.toString());
    expect(from.toString(), tree.toString());
    expect(identical(of, tree), isFalse);
    expect(identical(from, tree), isFalse);
    expect(of.hashCode == tree.hashCode, isFalse);
    expect(from.hashCode == tree.hashCode, isFalse);
  });

  test('add', () {
    final IntervalTree tree = IntervalTree();
    expect(tree, []);

    tree.add([0, 0]);
    expect(tree.toList(), [Interval(0, 0)]);

    tree.add([0, 0]);
    expect(tree.toList(), [Interval(0, 0)]);

    tree.add([1, 2]);
    expect(tree.toList(), [Interval(0, 0), Interval(1, 2)]);

    tree.addAll([
      [4, 5],
      [6, 7]
    ]);
    expect(tree.toList(),
        [Interval(0, 0), Interval(1, 2), Interval(4, 5), Interval(6, 7)]);

    tree.add([3, 4]);
    expect(tree.toList(),
        [Interval(0, 0), Interval(1, 2), Interval(3, 5), Interval(6, 7)]);

    tree.addAll([
      [3, 4],
      [3, 5]
    ]);
    expect(tree.toList(),
        [Interval(0, 0), Interval(1, 2), Interval(3, 5), Interval(6, 7)]);

    tree.add([1, 6]);
    expect(tree.toList(), [Interval(0, 0), Interval(1, 7)]);

    expect(
        () => tree.add([
              [0, 1],
              [2, 3],
            ]),
        throwsArgumentError);
  });

  test('remove', () {
    IntervalTree tree = IntervalTree.from([
      [0, 0],
      [1, 2],
      [3, 5],
      [7, 9],
      [11, 15]
    ]);

    tree.remove([3, 4]);
    expect(tree.toList(), [
      Interval(0, 0),
      Interval(1, 2),
      Interval(4, 5),
      Interval(7, 9),
      Interval(11, 15)
    ]);

    tree.remove([0, 2]);
    expect(tree.toList(), [Interval(4, 5), Interval(7, 9), Interval(11, 15)]);

    tree.remove([5, 12]);
    expect(tree.toList(), [Interval(4, 5), Interval(12, 15)]);

    expect(
        () => tree.remove([
              [0, 1],
              [2, 3],
            ]),
        throwsArgumentError);
  });

  test('clear', () {
    IntervalTree tree = IntervalTree([0, 0]);
    expect(tree, isNotEmpty);
    tree.clear();
    expect(tree, isEmpty);
  });

  test('intervals', () {
    expect(IntervalTree().toList(), []);
    expect(IntervalTree([0, 0]).toList(), [Interval(0, 0)]);
    expect(
        IntervalTree.from([
          [0, 0],
          [1, 2]
        ]).toList(),
        [Interval(0, 0), Interval(1, 2)]);
    expect(
        IntervalTree.from([
          [0, 0],
          [1, 2],
          [3, 4],
          [4, 5],
          [8, 9],
          [7, 8]
        ]),
        [Interval(0, 0), Interval(1, 2), Interval(3, 5), Interval(7, 9)]);
    expect(
        IntervalTree.from([
          [0, 0],
          [1, 2],
          [3, 4],
          [-5, 5]
        ]),
        [Interval(-5, 5)]);
  });

  final pt = IntervalTree.from([
    [0, 2],
    [4, 6],
    [8, 10],
    [12, 14]
  ]);

  final tt = IntervalTree.from([
    [1, 3],
    [6, 9],
    [12, 15]
  ]);

  final qt = IntervalTree.from([
    [2, 6],
    [8, 12],
    [14, 18]
  ]);

  test('union', () {
    expect(pt.union(pt), pt);
    expect(pt.union(tt).toList(),
        [Interval(0, 3), Interval(4, 10), Interval(12, 15)]);
    expect(pt.union(qt).toList(), [Interval(0, 6), Interval(8, 18)]);

    expect(tt.union(tt), tt);
    expect(tt.union(pt).toList(),
        [Interval(0, 3), Interval(4, 10), Interval(12, 15)]);
    expect(tt.union(qt).toList(), [Interval(1, 18)]);

    expect(qt.union(qt), qt);
    expect(qt.union(pt).toList(), [Interval(0, 6), Interval(8, 18)]);
    expect(qt.union(tt).toList(), [Interval(1, 18)]);
  });

  test('intersection', () {
    expect(pt.intersection(pt), pt);
    expect(pt.intersection(tt).toList(),
        [Interval(1, 2), Interval(6, 6), Interval(8, 9), Interval(12, 14)]);
    expect(pt.intersection(qt).toList(), [
      Interval(2, 2),
      Interval(4, 6),
      Interval(8, 10),
      Interval(12, 12),
      Interval(14, 14)
    ]);

    expect(tt.intersection(tt), tt);
    expect(tt.intersection(pt).toList(),
        [Interval(1, 2), Interval(6, 6), Interval(8, 9), Interval(12, 14)]);
    expect(tt.intersection(qt).toList(), [
      Interval(2, 3),
      Interval(6, 6),
      Interval(8, 9),
      Interval(12, 12),
      Interval(14, 15)
    ]);

    expect(qt.intersection(qt), qt);
    expect(qt.intersection(pt).toList(), [
      Interval(2, 2),
      Interval(4, 6),
      Interval(8, 10),
      Interval(12, 12),
      Interval(14, 14)
    ]);
    expect(qt.intersection(tt).toList(), [
      Interval(2, 3),
      Interval(6, 6),
      Interval(8, 9),
      Interval(12, 12),
      Interval(14, 15)
    ]);
  });

  test('difference', () {
    expect(pt.difference(pt), isEmpty);
    expect(pt.difference(tt).toList(),
        [Interval(0, 1), Interval(4, 6), Interval(9, 10)]);
    expect(pt.difference(qt).toList(), [Interval(0, 2), Interval(12, 14)]);

    expect(tt.difference(tt), isEmpty);
    expect(tt.difference(pt).toList(),
        [Interval(2, 3), Interval(6, 8), Interval(14, 15)]);
    expect(tt.difference(qt).toList(),
        [Interval(1, 2), Interval(6, 8), Interval(12, 14)]);

    expect(qt.difference(qt), isEmpty);
    expect(qt.difference(pt).toList(),
        [Interval(2, 4), Interval(10, 12), Interval(14, 18)]);
    expect(qt.difference(tt).toList(),
        [Interval(3, 6), Interval(9, 12), Interval(15, 18)]);
  });

  test('iterable', () {
    IntervalTree empty = IntervalTree();
    expect(empty.isEmpty, isTrue);
    expect(empty.isNotEmpty, isFalse);
    expect(empty.first, isNull);
    expect(empty.last, isNull);
    expect(empty.length, 0);
    expect(() => empty.single, throwsStateError);

    IntervalTree single = IntervalTree(Interval(0, 0));
    expect(single.isEmpty, isFalse);
    expect(single.isNotEmpty, isTrue);
    expect(single.first, isNotNull);
    expect(single.last, isNotNull);
    expect(single.length, 1);
    expect(single.single, Interval(0, 0));

    final intervals = [
      Interval(10, 15),
      Interval(20, 25),
      Interval(0, 5),
    ];
    final sorted = List.of(intervals);
    sorted.sort();

    IntervalTree tree = IntervalTree.from(intervals);
    expect(tree.toList(), [Interval(0, 5), Interval(10, 15), Interval(20, 25)]);
    expect(tree.isEmpty, isFalse);
    expect(tree.isNotEmpty, isTrue);
    expect(tree.first, Interval(0, 5));
    expect(tree.last, Interval(20, 25));
    expect(tree.length, 3);
    expect(() => tree.single, throwsStateError);

    expect(() => IntervalTree(intervals), throwsArgumentError);
  });

  test('contains', () {
    expect(pt.contains([0, 0]), isTrue);
    expect(pt.contains([0, 1]), isTrue);
    expect(pt.contains([0, 2]), isTrue);
    expect(pt.contains([0, 3]), isFalse);
    expect(pt.contains([0, 4]), isFalse);

    expect(pt.contains([1, 1]), isTrue);
    expect(pt.contains([1, 2]), isTrue);
    expect(pt.contains([1, 3]), isFalse);
    expect(pt.contains([1, 4]), isFalse);
    expect(pt.contains([1, 5]), isFalse);

    expect(pt.contains([2, 2]), isTrue);
    expect(pt.contains([2, 3]), isFalse);
    expect(pt.contains([2, 4]), isFalse);
    expect(pt.contains([2, 5]), isFalse);
    expect(pt.contains([2, 6]), isFalse);

    expect(pt.contains([3, 3]), isFalse);
    expect(pt.contains([3, 4]), isFalse);
    expect(pt.contains([3, 5]), isFalse);
    expect(pt.contains([3, 6]), isFalse);
    expect(pt.contains([3, 7]), isFalse);

    expect(pt.contains([4, 4]), isTrue);
    expect(pt.contains([4, 5]), isTrue);
    expect(pt.contains([4, 6]), isTrue);
    expect(pt.contains([4, 7]), isFalse);
    expect(pt.contains([4, 8]), isFalse);

    expect(pt.contains([5, 5]), isTrue);
    expect(pt.contains([5, 6]), isTrue);
    expect(pt.contains([5, 7]), isFalse);
    expect(pt.contains([5, 8]), isFalse);
    expect(pt.contains([5, 9]), isFalse);

    expect(pt.contains([6, 6]), isTrue);
    expect(pt.contains([6, 7]), isFalse);
    expect(pt.contains([6, 8]), isFalse);
    expect(pt.contains([6, 9]), isFalse);
    expect(pt.contains([6, 10]), isFalse);

    expect(pt.contains([7, 7]), isFalse);
    expect(pt.contains([7, 8]), isFalse);
    expect(pt.contains([7, 9]), isFalse);
    expect(pt.contains([7, 10]), isFalse);
    expect(pt.contains([7, 11]), isFalse);

    expect(pt.contains([8, 8]), isTrue);
    expect(pt.contains([8, 9]), isTrue);
    expect(pt.contains([8, 10]), isTrue);
    expect(pt.contains([8, 11]), isFalse);
    expect(pt.contains([8, 12]), isFalse);
  });

  test('toString', () {
    expect(IntervalTree(Interval(1, 2)).toString(), 'IntervalTree([1, 2])');
  });
}
