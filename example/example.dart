import 'package:interval_tree/interval_tree.dart' as iv;

void main() {
  // Construct a tree:
  final iv.IntervalTree tree = iv.IntervalTree.from([
    [1, 3],
    [5, 8],
    [10, 15]
  ]);

  // Add an interval:
  tree.add([2, 6]);
  print(tree); // IntervalTree([1, 8], [10, 15])

  // Remove an interval:
  tree.remove([12, 16]);
  print(tree); // IntervalTree([1, 8], [10, 12])

  // Calculate union/intersection/difference:
  final iv.IntervalTree other = iv.IntervalTree.from([
    [0, 2],
    [5, 7]
  ]);
  print(tree.union(other)); // IntervalTree([0, 8], [10, 12])
  print(tree.intersection(other)); // IntervalTree([1, 2], [5, 7])
  print(tree.difference(other)); // IntervalTree([2, 5], [7, 8], [10, 12])

  {
    final a = iv.Interval(0, 3);
    final b = iv.Interval(2, 5);
    print(a.union(b)); // [[0, 5]]
    print(a.intersection(b)); // [2,3]
    print(a.difference(b)); // [[0, 2]]
  }

  {
    final iv.IntervalTree tree = iv.IntervalTree.from([
      [1, 3],
      [5, 8],
      [10, 15]
    ]);
    print(tree); // IntervalTree([1, 3], [5, 8], [10, 15])
    tree.add([2, 6]);
    print(tree); // IntervalTree([1, 8], [10, 15])
    tree.remove([12, 16]);
    print(tree); // IntervalTree([1, 8], [10, 12])

    final iv.IntervalTree other = iv.IntervalTree.from([
      [0, 2],
      [5, 7]
    ]);
    print(tree.union(other)); // IntervalTree([0, 8], [10, 12])
    print(tree.intersection(other)); // IntervalTree([1, 2], [5, 7])
    print(tree.difference(other)); // IntervalTree([2, 5], [7, 8], [10, 12])

    for (final interval in tree) {
      print(interval); // [1, 8] \n [10, 12]
    }
    print(tree.first); // [1, 8]
    print(tree.last); // [10, 12]
  }
}
