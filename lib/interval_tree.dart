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

/// The library provides a non-overlapping interval tree implementation with
/// support for calculating unions, intersections, and differences between
/// individual intervals and entire trees.
///
/// ## Usage
///
/// Import the library:
///
///     import 'package:interval_tree/interval_tree.dart';
///
/// Construct a tree:
///
///     final IntervalTree tree = IntervalTree.from([[1, 3], [5, 8], [10, 15]]);
///
/// Add an interval:
///
///     tree.add([2, 6]);
///     print(tree); // IntervalTree([1, 8], [10, 15])
///
/// Remove an interval:
///
///     tree.remove([12, 16]);
///     print(tree); // IntervalTree([1, 8], [10, 12])
///
/// Calculate union/intersection/difference:
///
///     final IntervalTree other = IntervalTree.from([[0, 2], [5, 7] ]);
///
///     print(tree.union(other)); // IntervalTree([0, 8], [10, 12])
///     print(tree.intersection(other)); // IntervalTree([1, 2], [5, 7])
///     print(tree.difference(other)); // IntervalTree([2, 5], [7, 8], [10, 12])
///
library interval_tree;

import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:quiver/core.dart';
import 'package:quiver/collection.dart';

/// An interval between two points, _start_ and _end_.
///
/// Interval can calculate unions, intersections, and differences between
/// individual intervals:
///
///     final a = Interval(0, 3);
///     final b = Interval(2, 5);
///     print(a.union(b)); // [[0, 5]]
///     print(a.intersection(b)); // [2,3]
///     print(a.difference(b)); // [[0, 2]]
///
/// See [IntervalTree] for calculating more complex unions, intersections, and
/// differences between collections of intervals.
///
/// Notice that the Interval class name unfortunately clashes with the Interval
/// class from the Flutter animation library. However, there are two ways around
/// this problem. Either use the syntax with list literals, or import either
/// library with a name prefix, for example:
///
///     import 'package:interval_tree/interval_tree.dart' as ivt;
///
///     final interval = ivt.Interval(1, 2);
///
@immutable
class Interval extends Comparable<Interval> {
  /// Creates an interval between [start] and [end] points.
  Interval(dynamic start, dynamic end)
      : _start = _min(start, end),
        _end = _max(start, end);

  /// Creates a copy of the [other] interval.
  Interval.copy(Interval other)
      : _start = other.start,
        _end = other.end;

  /// Returns the start point of this interval.
  dynamic get start => _start;

  /// Returns the end point of this interval.
  dynamic get end => _end;

  /// Returns the length of this interval.
  @deprecated
  dynamic get length => _end - _start;

  /// Returns `true` if this interval contains the [other] interval.
  bool contains(Interval other) => other.start >= start && other.end <= end;

  /// Returns `true` if this interval intersects with the [other] interval.
  bool intersects(Interval other) => other.start <= end && other.end >= start;

  /// Returns the union of this interval and the [other] interval.
  ///
  /// In other words, the returned interval contains the points that are in
  /// either interval.
  ///
  ///     final a = Interval(0, 3);
  ///     final b = Interval(2, 5);
  ///     print(a.union(b)); // [[0, 5]]
  ///
  /// Notice that `a.union(b) = b.union(a)`.
  ///
  /// The returned interval is the entire interval from the smaller start to the
  /// larger end, including any gap in between.
  ///
  ///     final a = Interval(0, 2);
  ///     final b = Interval(3, 5);
  ///     print(b.union(a)); // [0, 5]
  ///
  Interval union(Interval other) =>
      Interval(_min(start, other.start), _max(end, other.end));

  /// Returns the intersection between this interval and the [other] interval,
  /// or `null` if the intervals do not intersect.
  ///
  /// In other words, the returned interval contains the points that are also
  /// in the [other] interval.
  ///
  ///     final a = Interval(0, 3);
  ///     final b = Interval(2, 5);
  ///     print(a.intersection(b)); // [[2, 3]]
  ///
  /// Notice that `a.intersection(b) = b.intersection(a)`.
  ///
  /// The returned interval may be `null` if the intervals do not intersect.
  ///
  ///     final a = Interval(0, 2);
  ///     final b = Interval(3, 5);
  ///     print(b.intersection(a)); // null
  ///
  Interval? intersection(Interval other) {
    if (!intersects(other)) return null;
    return Interval(_max(start, other.start), _min(end, other.end));
  }

  /// Returns the difference between this interval and the [other] interval,
  /// or `null` if the [other] interval contains this interval.
  ///
  /// In other words, the returned iterable contains the interval(s) that are
  /// not in the [other] interval.
  ///
  ///     final a = Interval(0, 3);
  ///     final b = Interval(2, 5);
  ///     print(a.difference(b)); // [[0, 2]]
  ///     print(b.difference(a)); // [[3, 5]]
  ///
  /// Notice that `a.difference(b) != b.difference(a)`.
  ///
  /// The returned iterable may contain multiple intervals if removing the
  /// [other] interval splits the remaining interval, or `null` if there is no
  /// interval left after removing the [other] interval.
  ///
  ///     final a = Interval(1, 5);
  ///     final b = Interval(2, 4);
  ///     print(a.difference(b)); // [[1, 2], [4, 5]]
  ///     print(b.difference(a)); // null
  ///
  Iterable<Interval>? difference(Interval other) {
    if (other.contains(this)) return null;
    if (!other.intersects(this)) return [this];
    if (other.start > start && other.end >= end) {
      return [Interval(start, other.start)];
    }
    if (other.start <= start && other.end < end) {
      return [Interval(other.end, end)];
    }
    return [Interval(start, other.start), Interval(other.end, end)];
  }

  /// Compares this interval to the [other] interval.
  ///
  /// Two intervals are considered _equal_ when their [start] and [end] points
  /// are equal. Otherwise, the one that starts first comes first, or if the
  /// start points are equal, the one that ends first.
  ///
  /// Similarly to [Comparator], returns:
  /// - a negative integer if this interval is _less than_ the [other] interval,
  /// - a positive integer if this interval is _greater than_ the [other]
  ///   interval,
  /// - zero if this interval is _equal to_ the [other] interval.
  @override
  int compareTo(Interval other) {
    return start == other.start
        ? _cmp(end, other.end)
        : _cmp(start, other.start);
  }

  /// Returns `true` if this interval start or ends before the [other] interval.
  ///
  /// See [compareTo] for detailed interval comparison rules.
  bool operator <(Interval other) => compareTo(other) < 0;

  /// Returns `true` if this interval starts or ends before or same as the
  /// [other] interval.
  ///
  /// See [compareTo] for detailed interval comparison rules.
  bool operator <=(Interval other) => compareTo(other) <= 0;

  /// Returns `true` if this interval starts or ends after the [other] interval.
  ///
  /// See [compareTo] for detailed interval comparison rules.
  bool operator >(Interval other) => compareTo(other) > 0;

  /// Returns `true` if this interval starts or ends after or same as the
  /// [other] interval.
  ///
  /// See [compareTo] for detailed interval comparison rules.
  bool operator >=(Interval other) => compareTo(other) >= 0;

  /// Returns `true` if this interval starts and ends same as the [other]
  /// interval.
  ///
  /// See [compareTo] for detailed interval comparison rules.
  @override
  bool operator ==(Object other) {
    return other is Interval && start == other.start && end == other.end;
  }

  /// Returns the hash code for this interval.
  @override
  int get hashCode => hash2(start, end);

  /// Returns a string representation of this interval.
  @override
  String toString() => '[$start, $end]';

  static int _cmp(dynamic a, dynamic b) => Comparable.compare(a, b);
  static dynamic _min(dynamic a, dynamic b) => _cmp(a, b) < 0 ? a : b;
  static dynamic _max(dynamic a, dynamic b) => _cmp(a, b) > 0 ? a : b;

  final dynamic _start;
  final dynamic _end;
}

/// A non-overlapping collection of intervals organized into a tree.
///
/// IntervalTree has support for adding and removing intervals, or entire
/// iterable collections of intervals, such as other interval trees.
///
///     final IntervalTree tree = IntervalTree.from([[1, 3], [5, 8], [10, 15]]);
///     print(tree); // IntervalTree([1, 3], [5, 8], [10, 15])
///
///     tree.add([2, 6]);
///     print(tree); // IntervalTree([1, 8], [10, 15])
///
///     tree.remove([12, 16]);
///     print(tree); // IntervalTree([1, 8], [10, 12])
///
/// As illustrated  by the above example, IntervalTree automatically joins and
/// splits appropriate intervals at insertions and removals, respectively,
/// whilst maintaining a collection of non-overlapping intervals.
///
/// IntervalTree can also calculate unions, intersections, and differences
/// between collections of intervals:
///
///     final IntervalTree tree = IntervalTree.from([[1, 8], [10, 12]]);
///     final IntervalTree other = IntervalTree.from([[0, 2], [5, 7]]);
///
///     print(tree.union(other)); // IntervalTree([0, 8], [10, 12])
///     print(tree.intersection(other)); // IntervalTree([1, 2], [5, 7])
///     print(tree.difference(other)); // IntervalTree([2, 5], [7, 8], [10, 12])
///
/// IntervalTree is an [Iterable] collection offering all standard iterable
/// operations, such as easily iterating the entire tree, or accessing the first
/// and last intervals.
///
///     for (final interval in tree) {
///       print(interval); // [1, 8] \n [10, 12]
///     }
///
///     print(tree.first); // [1, 8]
///     print(tree.last); // [10, 12]
///
/// Notice that all methods that take interval arguments accept either
/// [Interval] objects or literal lists with two items. The latter is a natural
/// syntax for specifying intervals:
///
///     tree.add([0, 5]); // vs. tree.add(Interval(0, 5));
///
/// Notice that the Interval class name unfortunately clashes with the Interval
/// class from the Flutter animation library. However, there are two ways around
/// this problem. Either use the syntax with list literals, or import either
/// library with a name prefix, for example:
///
///     import 'package:interval_tree/interval_tree.dart' as ivt;
///
///     final interval = ivt.Interval(1, 2);
///
class IntervalTree with IterableMixin<Interval> {
  /// Creates a tree, optionally with an [interval].
  IntervalTree([dynamic interval]) {
    if (interval != null) add(interval);
  }

  /// Creates a tree from given iterable of [intervals].
  factory IntervalTree.from(Iterable intervals) {
    final tree = IntervalTree();
    for (final interval in intervals) {
      tree.add(interval);
    }
    return tree;
  }

  /// Creates a tree from [intervals].
  factory IntervalTree.of(Iterable<Interval?> intervals) =>
      IntervalTree()..addAll(intervals);

  /// Adds an [interval] into this tree.
  void add(dynamic interval) {
    Interval iv = _asInterval(interval);
    bool joined = false;
    BidirectionalIterator<Interval?> it = _tree.fromIterator(iv);
    while (it.movePrevious()) {
      final union = _tryJoin(it.current, iv);
      if (union == null) break;
      it = _tree.fromIterator(iv = union, inclusive: false);
      joined = true;
    }

    it = _tree.fromIterator(iv, inclusive: false);
    while (it.moveNext()) {
      final union = _tryJoin(it.current, iv);
      if (union == null) break;
      it = _tree.fromIterator(iv = union, inclusive: false);
      joined = true;
    }

    if (!joined) {
      _tree.add(iv);
    }
  }

  /// Adds all [intervals] into this tree.
  void addAll(Iterable intervals) {
    for (final interval in intervals) {
      add(interval);
    }
  }

  /// Removes an [interval] from this tree.
  void remove(dynamic interval) {
    final iv = _asInterval(interval);

    BidirectionalIterator<Interval> it = _tree.fromIterator(iv);
    while (it.movePrevious()) {
      final current = it.current;
      if (!_trySplit(it.current, iv)) break;
      it = _tree.fromIterator(current, inclusive: false);
    }

    it = _tree.fromIterator(iv, inclusive: false);
    while (it.moveNext()) {
      final current = it.current;
      if (!_trySplit(it.current, iv)) break;
      it = _tree.fromIterator(current, inclusive: false);
    }
  }

  /// Removes all [intervals] from this tree.
  void removeAll(Iterable intervals) {
    for (final interval in intervals) {
      remove(interval);
    }
  }

  /// Clears this tree.
  void clear() {
    _tree.clear();
  }

  // Returns the union of this tree and the [other] tree.
  IntervalTree union(IntervalTree other) =>
      IntervalTree.of(this)..addAll(other);

  // Returns the difference between this tree and the [other] tree.
  IntervalTree difference(IntervalTree other) =>
      IntervalTree.of(this)..removeAll(other);

  // Returns the intersection of this tree and the [other] tree.
  IntervalTree intersection(IntervalTree other) {
    final result = IntervalTree();
    if (isEmpty || other.isEmpty) result;
    for (final iv in other) {
      BidirectionalIterator<Interval> it = _tree.fromIterator(iv);
      while (it.movePrevious() && iv.intersects(it.current)) {
        result.add(iv.intersection(it.current));
      }
      it = _tree.fromIterator(iv, inclusive: false);
      while (it.moveNext() && iv.intersects(it.current)) {
        result.add(iv.intersection(it.current));
      }
    }
    return result;
  }

  @override
  bool contains(dynamic interval) {
    final iv = _asInterval(interval);
    BidirectionalIterator<Interval?> it = _tree.fromIterator(iv);
    while (it.movePrevious() && iv.intersects(it.current!)) {
      if (it.current!.contains(iv)) return true;
    }
    it = _tree.fromIterator(iv, inclusive: false);
    while (it.moveNext() && it.current!.intersects(iv)) {
      if (it.current!.contains(iv)) return true;
    }
    return false;
  }

  /// Returns the number of intervals in this tree.
  @override
  int get length => _tree.length;

  /// Returns `true` if there are no intervals in this tree.
  @override
  bool get isEmpty => _tree.isEmpty;

  /// Returns `true` if there is at least one interval in this tree.
  @override
  bool get isNotEmpty => _tree.isNotEmpty;

  /// Returns the first interval in tree, or `null` if this tree is empty.
  @override
  Interval get first => _tree.first;

  /// Returns the first interval in tree, or `null` if this tree is empty.
  @override
  Interval get last => _tree.last;

  /// Checks that this tree has only one interval, and returns that interval.
  @override
  Interval get single => _tree.single;

  /// Returns a bidirectional iterator that allows iterating the intervals.
  @override
  BidirectionalIterator<Interval> get iterator => _tree.iterator;

  /// Returns a string representation of the tree.
  @override
  String toString() => 'IntervalTree' + super.toString();

  Interval _asInterval(dynamic interval) {
    if (interval is Iterable) {
      if (interval.length != 2 || interval.first is Iterable) {
        throw ArgumentError('$interval is not an interval');
      }
      return Interval(interval.first, interval.last);
    }
    return interval;
  }

  Interval? _tryJoin(Interval? a, Interval? b) {
    if (a == null || b == null) return null;
    if (a.contains(b)) return a;
    if (!a.intersects(b)) return null;
    final union = a.union(b);
    _tree.remove(a);
    _tree.remove(b);
    _tree.add(union);
    return union;
  }

  bool _trySplit(Interval a, Interval b) {
    if (!a.intersects(b)) return false;
    _tree.remove(a);
    _tree.addAll([...?a.difference(b)]);
    return true;
  }

  final AvlTreeSet<Interval> _tree =
      AvlTreeSet<Interval>(comparator: Comparable.compare);
}
