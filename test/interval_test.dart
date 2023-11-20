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
  test('start', () {
    expect(Interval(0, 0).start, 0);
    expect(Interval(-1, 1).start, -1);
    expect(Interval(1, 10).start, 1);
    expect(Interval(1, -10).start, -10);
  });

  test('end', () {
    expect(Interval(0, 0).end, 0);
    expect(Interval(-1, 1).end, 1);
    expect(Interval(1, 10).end, 10);
    expect(Interval(1, -10).end, 1);
  });

  test('copy', () {
    final interval = Interval(0, 10);
    final copy = Interval.copy(interval);
    expect(copy.start, interval.start);
    expect(copy.end, interval.end);
    expect(interval == copy, isTrue);
    expect(copy.toString(), interval.toString());
    expect(identical(interval, copy), isFalse);
    expect(copy.hashCode == interval.hashCode, isTrue);
  });

  test('compare', () {
    final jan = DateTime(2020, 01, 01);
    final feb = DateTime(2020, 02, 14);
    final dec = DateTime(2020, 12, 24);

    expect(Interval(0, 0) == Interval(0, 0), isTrue);
    expect(Interval(1, 2) == Interval(1, 2), isTrue);
    expect(Interval(3, 4) == Interval(4, 5), isFalse);
    expect(Interval(7, 8) == Interval(6, 7), isFalse);
    expect(Interval(0.5, 1.5) == Interval(0.5, 1.5), isTrue);
    expect(Interval(0.5, 1.5) == Interval(1.5, 2.5), isFalse);
    expect(Interval(jan, feb) == Interval(jan, feb), isTrue);
    expect(Interval(jan, feb) == Interval(jan, dec), isFalse);

    expect(Interval(0, 0) < Interval(0, 0), isFalse);
    expect(Interval(1, 2) < Interval(1, 2), isFalse);
    expect(Interval(3, 4) < Interval(4, 5), isTrue);
    expect(Interval(7, 8) < Interval(6, 7), isFalse);
    expect(Interval(0.5, 1.5) < Interval(0.5, 1.5), isFalse);
    expect(Interval(0.5, 1.5) < Interval(1.5, 2.5), isTrue);
    expect(Interval(jan, feb) < Interval(jan, feb), isFalse);
    expect(Interval(jan, feb) < Interval(jan, dec), isTrue);

    expect(Interval(0, 0) <= Interval(0, 0), isTrue);
    expect(Interval(1, 2) <= Interval(1, 2), isTrue);
    expect(Interval(3, 4) <= Interval(4, 5), isTrue);
    expect(Interval(7, 8) <= Interval(6, 7), isFalse);
    expect(Interval(0.5, 1.5) <= Interval(0.5, 1.5), isTrue);
    expect(Interval(0.5, 1.5) <= Interval(1.5, 2.5), isTrue);
    expect(Interval(jan, feb) <= Interval(jan, feb), isTrue);
    expect(Interval(jan, feb) <= Interval(jan, dec), isTrue);

    expect(Interval(0, 0) > Interval(0, 0), isFalse);
    expect(Interval(1, 2) > Interval(1, 2), isFalse);
    expect(Interval(3, 4) > Interval(4, 5), isFalse);
    expect(Interval(7, 8) > Interval(6, 7), isTrue);
    expect(Interval(0.5, 1.5) > Interval(0.5, 1.5), isFalse);
    expect(Interval(0.5, 1.5) > Interval(1.5, 2.5), isFalse);
    expect(Interval(jan, feb) > Interval(jan, feb), isFalse);
    expect(Interval(jan, feb) > Interval(jan, dec), isFalse);

    expect(Interval(0, 0) >= Interval(0, 0), isTrue);
    expect(Interval(1, 2) >= Interval(1, 2), isTrue);
    expect(Interval(3, 4) >= Interval(4, 5), isFalse);
    expect(Interval(7, 8) >= Interval(6, 7), isTrue);
    expect(Interval(0.5, 1.5) >= Interval(0.5, 1.5), isTrue);
    expect(Interval(0.5, 1.5) >= Interval(1.5, 2.5), isFalse);
    expect(Interval(jan, feb) >= Interval(jan, feb), isTrue);
    expect(Interval(jan, feb) >= Interval(jan, dec), isFalse);
  });

  // 1 2 3 4_5_6 7 8 9
  //  ___ _|_A_|_ ___
  // |_D_|_B_|_C_|_E_|
  //   |_F_|___|_G_|
  //     |___H___|
  final a = Interval(4, 6);
  final b = Interval(3, 5);
  final c = Interval(5, 7);
  final d = Interval(1, 3);
  final e = Interval(7, 9);
  final f = Interval(2, 4);
  final g = Interval(6, 8);
  final h = Interval(3, 7);

  test('intersection', () {
    expect(a.intersection(a), a); // itself
    expect(a.intersection(b), Interval(a.start, b.end)); // intersect
    expect(a.intersection(c), Interval(c.start, a.end)); // intersect
    expect(a.intersection(d), isNull); // no intersection
    expect(a.intersection(e), isNull); // no intersection
    expect(a.intersection(f), Interval(f.end, a.start)); // adjacent
    expect(a.intersection(g), Interval(a.end, g.start)); // adjacent
    expect(a.intersection(h), a); // contains
  });

  test('difference', () {
    expect(a.difference(a), isNull); // itself
    expect(a.difference(b), [Interval(b.end, a.end)]); // intersect
    expect(a.difference(c), [Interval(a.start, c.start)]); // intersect
    expect(a.difference(d), [a]); // no intersection
    expect(a.difference(e), [a]); // no intersection
    expect(a.difference(f), [a]); // adjacent
    expect(a.difference(g), [a]); // adjacent
    expect(a.difference(h), isNull); // contains

    expect(h.difference(a), [Interval(3, 4), Interval(6, 7)]); // split
    expect(h.difference(b), [Interval(b.end, h.end)]); // h > b
    expect(h.difference(c), [Interval(h.start, c.start)]); // h < c
    expect(h.difference(d), [h]); // adjacent
    expect(h.difference(e), [h]); // adjacent
    expect(h.difference(f), [Interval(f.end, h.end)]); // h > f
    expect(h.difference(g), [Interval(h.start, g.start)]); // h < f
  });

  test('union', () {
    expect(a.union(a), a); // itself
    expect(a.union(b), Interval(b.start, a.end)); // intersect
    expect(a.union(c), Interval(a.start, c.end)); // intersect
    expect(a.union(d), Interval(d.start, a.end)); // no intersection
    expect(a.union(e), Interval(a.start, e.end)); // no intersection
    expect(a.union(f), Interval(f.start, a.end)); // adjacent
    expect(a.union(g), Interval(a.start, g.end)); // adjacent
    expect(a.union(h), h); // contains
  });

  test('toString', () {
    expect(Interval(1, 2).toString(), '[1, 2]');
  });
}
