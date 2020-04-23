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

import 'package:interval_tree/interval_tree.dart';

void main() {
  // Construct a tree:
  IntervalTree tree = IntervalTree([Interval(1, 5), Interval(5, 10), Interval(10, 15)]);

  // Find intervals contained within given points or intervals:
  print(tree.findContained(5)); // [Interval(1, 5), Interval(5, 10)]
  print(tree.findContained(5, 10)); // [Interval(5, 10)]

  // Find intervals overlapping with given points or intervals:
  print(tree.findOverlapping(5)); // [Interval(1, 5), Interval(5, 10)]
  print(tree.findOverlapping(5, 10)); // [Interval(1, 5), Interval(5, 10), Interval(10, 15)]
}
