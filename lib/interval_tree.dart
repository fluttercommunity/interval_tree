/*
 * Copyright (c) 2020 J-P Nurmi <jpnurmi@gmail.com>
 *
 * Based on a minimal C++ interval tree implementation:
 * https://github.com/ekg/intervaltree
 *
 * Copyright (c) 2011 Erik Garrison <erik.garrison@gmail.com>
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

/// A tree data structure to hold intervals.
///
/// ## Overview
///
/// An interval tree can be used to efficiently find a set of numeric intervals overlapping or containing another interval.
///
/// This library provides a basic implementation of an interval tree, allowing the insertion of arbitrary types into the tree.
///
/// ## Usage
///
/// Import the library:
///
///     import 'package:interval_tree/interval_tree.dart';
///
///
/// Construct a tree:
///
///     IntervalTree tree = IntervalTree([Interval(1, 5), Interval(5, 10), Interval(10, 15)]);
///
/// Find intervals contained within given points or intervals:
///
///     print(tree.findContained(5)); // [Interval(1, 5), Interval(5, 10)]
///     print(tree.findContained(5, 10)); // [Interval(5, 10)]
///
/// Find intervals overlapping with given points or intervals:
///
///     print(tree.findOverlapping(5)); // [Interval(1, 5), Interval(5, 10)]
///     print(tree.findOverlapping(5, 10)); // [Interval(1, 5), Interval(5, 10), Interval(10, 15)]
///
library interval_tree;

import 'package:quiver/core.dart';

/// A visitor callback function for intervals.
typedef IntervalVisitor = void Function(Interval interval);

/// An interval between _start_ and _stop_ points.
class Interval extends Comparable<Interval> {
  /// Constructs an interval between [start] and [stop] points.
  Interval(dynamic start, dynamic stop)
      : _start = start < stop ? start : stop,
        _stop = stop > start ? stop : start;

  /// Constructs a copy of the [other] interval.
  Interval.copy(Interval other)
      : _start = other.start,
        _stop = other.stop;

  /// Returns the start of the interval.
  dynamic get start => _start;

  /// Returns the stop of the interval.
  dynamic get stop => _stop;

  /// Compares the interval to [other] interval.
  @override
  int compareTo(Interval other) {
    if (start == other.start) {
      return stop - other.stop;
    }
    return start - other.start;
  }

  /// Returns `true` if the interval starts or stops before [other] interval.
  bool operator <(Interval other) => compareTo(other) < 0;

  /// Returns `true` if the interval starts or stops before or same as [other] interval.
  bool operator <=(Interval other) => compareTo(other) <= 0;

  /// Returns `true` if the interval starts or stops after [other] interval.
  bool operator >(Interval other) => compareTo(other) > 0;

  /// Returns `true` if the interval starts or stops after or same as [other] interval.
  bool operator >=(Interval other) => compareTo(other) >= 0;

  /// Returns `true` if the interval starts and stops same as [other] interval.
  @override
  bool operator ==(Object other) => other is Interval && start == other.start && stop == other.stop;

  /// Returns the hash code for the interval.
  @override
  int get hashCode => hash2(start, stop);

  /// Returns a string representation of the interval.
  @override
  String toString() => 'Interval($start, $stop)';

  dynamic _start;
  dynamic _stop;
}

/// A tree of intervals.
class IntervalTree {
  /// Constructs an interval tree filled with [intervals].
  IntervalTree(Iterable<Interval> intervals,
      {int depth = 0, int bucketSize = 512, dynamic leftExtent, dynamic rightExtent})
      : assert(intervals != null) {
    --depth;
    if (intervals.isNotEmpty) {
      final min = intervals.reduce((a, b) => a.start < b.start ? a : b);
      final max = intervals.reduce((a, b) => a.stop > b.stop ? a : b);
      _center = (min.start + max.stop) ~/ 2;

      if (leftExtent == null && rightExtent == null) {
        // sort intervals by start
        List<Interval> list = List.of(intervals);
        list.sort();
        intervals = list;
      }

      if (depth == 0 || intervals.length < bucketSize) {
        _intervals = List.of(intervals);
      } else {
        List<Interval> lefts = [];
        List<Interval> rights = [];
        for (final Interval interval in intervals) {
          if (interval.stop < _center) {
            lefts.add(interval);
          } else if (interval.start > _center) {
            rights.add(interval);
          } else {
            assert(interval.start <= _center);
            assert(_center <= interval.stop);
            _intervals.add(interval);
          }
        }

        if (lefts.isNotEmpty) {
          _left = IntervalTree(lefts,
              depth: depth, bucketSize: bucketSize, leftExtent: leftExtent ?? min, rightExtent: _center);
        }
        if (rights.isNotEmpty) {
          _right = IntervalTree(rights,
              depth: depth, bucketSize: bucketSize, leftExtent: _center, rightExtent: rightExtent ?? max);
        }
      }
    }
  }

  /// Constructs an empty interval tree.
  IntervalTree._();

  /// Constructs a copy of the [other] interval tree.
  factory IntervalTree.copy(IntervalTree other) {
    if (other == null) {
      return null;
    }

    IntervalTree tree = IntervalTree._();
    tree._center = other._center;
    tree._intervals = other._intervals;
    tree._left = IntervalTree.copy(other._left);
    tree._right = IntervalTree.copy(other._right);
    return tree;
  }

  /// Calls [visitor] on all intervals near [start] and [stop] points.
  void visitNear(dynamic start, dynamic stop, IntervalVisitor visitor) {
    if (_left != null && start <= _center) {
      _left.visitNear(start, stop, visitor);
    }
    if (_intervals.isNotEmpty && !(stop < _intervals.first.start)) {
      for (final interval in _intervals) {
        visitor(interval);
      }
    }
    if (_right != null && stop >= _center) {
      _right.visitNear(start, stop, visitor);
    }
  }

  /// Calls [visitor] on all intervals overlapping the interval between [start] and [stop] points.
  void visitOverlapping(dynamic start, dynamic stop, IntervalVisitor visitor) {
    IntervalVisitor filter = (final interval) {
      if (start <= interval.stop && stop >= interval.start) {
        visitor(interval);
      }
    };
    visitNear(start, stop, filter);
  }

  /// Calls [visitor] on all intervals contained within the interval between [start] and [stop] points.
  void visitContained(dynamic start, dynamic stop, IntervalVisitor visitor) {
    IntervalVisitor filter = (final interval) {
      if (start >= interval.start && stop <= interval.stop) {
        visitor(interval);
      }
    };
    visitNear(start, stop, filter);
  }

  /// Calls [visitor] on all intervals in the tree.
  void visitAll(IntervalVisitor visitor) {
    _left?.visitAll(visitor);
    _intervals.forEach(visitor);
    _right?.visitAll(visitor);
  }

  /// Returns all intervals overlapping the interval between [start] and [stop] points.
  List<Interval> findOverlapping(dynamic start, [dynamic stop]) {
    List<Interval> result = [];
    visitOverlapping(start, stop ?? start, (final interval) {
      result.add(interval);
    });
    return result;
  }

  /// Returns all intervals contained within the interval between [start] and [stop] points.
  List<Interval> findContained(dynamic start, [dynamic stop]) {
    List<Interval> result = [];
    visitContained(start, stop ?? start, (final interval) {
      result.add(interval);
    });
    return result;
  }

  /// Returns `true` if there are no intervals in the tree.
  bool get isEmpty => _intervals.isEmpty && (_left?.isEmpty ?? true) && (_right?.isEmpty ?? true);

  /// Returns `true` if there is at least one interval in the tree.
  bool get isNotEmpty => !isEmpty;

  /// Returns the minimum interval start point.
  dynamic min() => _left?.min() ?? (_intervals.isEmpty ? null : _intervals.first.start);

  /// Returns the maximum interval stop point.
  dynamic max() => _right?.max() ?? (_intervals.isEmpty ? null : _intervals.last.stop);

  /// Returns a string representation of the interval tree.
  @override
  String toString() => 'IntervalTree($_intervals)';

  dynamic _center;
  IntervalTree _left;
  IntervalTree _right;
  List<Interval> _intervals = [];
}
