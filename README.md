[![pub](https://img.shields.io/pub/v/interval_tree.svg)](https://pub.dev/packages/interval_tree)
[![license: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![build](https://github.com/jpnurmi/interval_tree/workflows/build/badge.svg)
[![codecov](https://codecov.io/gh/jpnurmi/interval_tree/branch/master/graph/badge.svg)](https://codecov.io/gh/jpnurmi/interval_tree)

# interval_tree

A [Dart][1] implementation of an [interval tree][2], with support for
calculating unions, intersections, and differences between individual
intervals, or entire iterable collections of intervals, such as other
interval trees.

## Mutable

IntervalTree has support for adding and removing intervals, or entire
iterable collections of intervals, such as other interval trees.

## Non-overlapping

IntervalTree automatically joins and splits appropriate intervals at
insertions and removals, respectively, whilst maintaining a collection
of non-overlapping intervals.

## Iterable

IntervalTree is an [iterable collection][3] offering all standard
iterable operations, such as easily accessing the first and last
interval.

## History

IntervalTree started off as a quick and dirty Dart port of Erik
Garrison's [simple C++ interval tree implementation][4], but was soon
re-written and based on [quiver.collection's][6] AVL implementation of
a self-balancing binary tree [AvlTreeSet][7].

[1]: https://dart.dev
[2]: https://en.wikipedia.org/wiki/Interval_tree
[3]: https://dart.dev/codelabs/iterables
[4]: https://github.com/ekg/intervaltree
[5]: https://opensource.org/licenses/MIT
[6]: https://pub.dev/packages/quiver
[7]: https://pub.dev/documentation/quiver/latest/quiver.collection/AvlTreeSet-class.html
