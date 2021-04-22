## [0.3.0] - 2021-04-22

* Migrated to null-safety (thanks @scarnett!)

## [0.2.2] - 2020-05-02

* Bumped down the quiver dependency version to 2.0.5 to be compatible
  with the current stable channel of the Flutter SDK

## [0.2.1] - 2020-04-29

* Fixed IntervalTree.contains()
* Fixed comparison for intervals with other comparables, such as DateTime
* Made IntervalTree default constructor, add(), and remove() throw an
  ArgumentError when passing an invalid interval iterable
* Deprecated Interval.length that would only work with nums

## [0.2.0+2] - 2020-04-27

* Fixed double comparison

## [0.2.0+1] - 2020-04-27

* Cosmetic fixes only to make the Dart Analyzer and Linter happy

## [0.2.0] - 2020-04-27

* Re-wrote IntervalTree based on AvlTreeSet from quiver.collection
* Made IntervalTree automatically join and split appropriate intervals at
  insertion and removal, respectively
* Added IntervalTree.of() and from() factory and named constructors
* Added IntervalTree.add(), addAll(), remove(), removeAll(), and clear()
  methods for managing intervals in the tree
* Added IntervalTree.union(), intersection() and difference() methods
* Made IntervalTree accept array literals like `[a,b]` in place of Interval
  objects
* Made IntervalTree inherit IterableMixin<Interval> to offer all standard
  iterable operations
* Made Interval immutable
* Renamed Interval.stop to end
* Added Interval.length property
* Added Interval.union(), intersection() and difference() methods

## [0.1.0] - 2020-04-23

* Initial Dart port of a minimal C++ interval tree implementation
  by Erik Garrison: https://github.com/ekg/intervaltree
