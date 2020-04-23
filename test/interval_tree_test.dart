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
  final Matcher throwsAssertionError = throwsA(isA<AssertionError>());

  test('copy', () {
    final tree = IntervalTree([Interval(0, 10)]);
    final copy = IntervalTree.copy(tree);
    expect(copy.toString(), tree.toString());
    expect(identical(tree, copy), isFalse);
    expect(copy.hashCode == tree.hashCode, isFalse);
  });

  test('empty', () {
    expect(IntervalTree([]).isEmpty, isTrue);
    expect(IntervalTree([]).isNotEmpty, isFalse);
    expect(IntervalTree([Interval(0, 1)]).isEmpty, isFalse);
    expect(IntervalTree([Interval(0, 1)]).isNotEmpty, isTrue);
    expect(() => IntervalTree(null), throwsAssertionError);
  });

  test('findOverlapping', () {
    final expect_findOverlapping = (IntervalTree tree) {
      expect(tree.findOverlapping(0), [Interval(0, 0)]);
      expect(tree.findOverlapping(0, 1), [Interval(0, 0), Interval(1, 2)]);
      expect(tree.findOverlapping(2, 4), [Interval(1, 2), Interval(3, 4), Interval(4, 5)]);
      expect(tree.findOverlapping(5, 6), [Interval(4, 5)]);
      expect(tree.findOverlapping(6), []);
      expect(tree.findOverlapping(7), [Interval(7, 8)]);
      expect(tree.findOverlapping(7, 8), [Interval(7, 8), Interval(8, 9)]);
      expect(tree.findOverlapping(6, 10), [Interval(7, 8), Interval(8, 9)]);
      expect(tree.findOverlapping(10), []);
    };
    final intervals = [Interval(0, 0), Interval(1, 2), Interval(3, 4), Interval(4, 5), Interval(8, 9), Interval(7, 8)];
    expect_findOverlapping(IntervalTree(intervals));
    expect_findOverlapping(IntervalTree(intervals, bucketSize: 2));
  });

  test('findContained', () {
    final expect_findContained = (IntervalTree tree) {
      expect(tree.findContained(0), [Interval(0, 10), Interval(0, 20)]);
      expect(tree.findContained(0, 10), [Interval(0, 10), Interval(0, 20)]);
      expect(tree.findContained(0, 20), [Interval(0, 20)]);
      expect(tree.findContained(5), [Interval(0, 10), Interval(0, 20), Interval(5, 15)]);
      expect(tree.findContained(5, 10), [Interval(0, 10), Interval(0, 20), Interval(5, 15)]);
      expect(tree.findContained(5, 15), [Interval(0, 20), Interval(5, 15)]);
      expect(tree.findContained(10),
          [Interval(0, 10), Interval(0, 20), Interval(5, 15), Interval(10, 15), Interval(10, 20)]);
      expect(tree.findContained(10, 15), [Interval(0, 20), Interval(5, 15), Interval(10, 15), Interval(10, 20)]);
      expect(tree.findContained(10, 20), [Interval(0, 20), Interval(10, 20)]);
      expect(tree.findContained(15),
          [Interval(0, 20), Interval(5, 15), Interval(10, 15), Interval(10, 20), Interval(15, 20)]);
      expect(tree.findContained(20), [Interval(0, 20), Interval(10, 20), Interval(15, 20)]);
      expect(tree.findContained(25), []);
    };
    final intervals = [
      Interval(0, 10),
      Interval(0, 20),
      Interval(5, 15),
      Interval(10, 15),
      Interval(10, 20),
      Interval(15, 20)
    ];
    expect_findContained(IntervalTree(intervals));
    expect_findContained(IntervalTree(intervals, bucketSize: 2));
  });

  test('visitAll', () {
    final intervals = {
      Interval(10, 20),
      Interval(10, 15),
      Interval(5, 10),
      Interval(15, 20),
      Interval(5, 20),
      Interval(5, 15)
    };
    final tree = IntervalTree(intervals, bucketSize: 2);
    tree.visitAll((Interval interval) {
      expect(intervals.remove(interval), isTrue);
    });
    expect(intervals, isEmpty);
  });

  test('minmax', () {
    final expect_minmax = (IntervalTree tree, dynamic min, dynamic max) {
      expect(tree.min(), min);
      expect(tree.max(), max);
    };
    final intervals = [
      Interval(0, 10),
      Interval(0, 20),
      Interval(5, 15),
      Interval(10, 15),
      Interval(10, 20),
      Interval(15, 20)
    ];
    expect_minmax(IntervalTree(intervals), 0, 20);
    expect_minmax(IntervalTree(intervals, bucketSize: 2), 0, 20);
  });

  test('toString', () {
    expect(IntervalTree([Interval(1, 2)]).toString(), 'IntervalTree([Interval(1, 2)])');
  });
}
