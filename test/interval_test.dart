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
  test('startstop', () {
    final expect_startStop = (interval, start, stop) {
      expect(interval.start, start);
      expect(interval.stop, stop);
    };
    expect_startStop(Interval(0, 1), 0, 1);
    expect_startStop(Interval(5, 10), 5, 10);
    expect_startStop(Interval(0, -10), -10, 0);
  });

  test('copy', () {
    final interval = Interval(0, 10);
    final copy = Interval.copy(interval);
    expect(copy.start, interval.start);
    expect(copy.stop, interval.stop);
    expect(interval == copy, isTrue);
    expect(copy.toString(), interval.toString());
    expect(identical(interval, copy), isFalse);
    expect(copy.hashCode == interval.hashCode, isTrue);
  });

  test('compare', () {
    expect(Interval(0, 0) == Interval(0, 0), isTrue);
    expect(Interval(1, 2) == Interval(1, 2), isTrue);
    expect(Interval(3, 4) == Interval(4, 5), isFalse);
    expect(Interval(7, 8) == Interval(6, 7), isFalse);

    expect(Interval(0, 0) < Interval(0, 0), isFalse);
    expect(Interval(1, 2) < Interval(1, 2), isFalse);
    expect(Interval(3, 4) < Interval(4, 5), isTrue);
    expect(Interval(7, 8) < Interval(6, 7), isFalse);

    expect(Interval(0, 0) <= Interval(0, 0), isTrue);
    expect(Interval(1, 2) <= Interval(1, 2), isTrue);
    expect(Interval(3, 4) <= Interval(4, 5), isTrue);
    expect(Interval(7, 8) <= Interval(6, 7), isFalse);

    expect(Interval(0, 0) > Interval(0, 0), isFalse);
    expect(Interval(1, 2) > Interval(1, 2), isFalse);
    expect(Interval(3, 4) > Interval(4, 5), isFalse);
    expect(Interval(7, 8) > Interval(6, 7), isTrue);

    expect(Interval(0, 0) >= Interval(0, 0), isTrue);
    expect(Interval(1, 2) >= Interval(1, 2), isTrue);
    expect(Interval(3, 4) >= Interval(4, 5), isFalse);
    expect(Interval(7, 8) >= Interval(6, 7), isTrue);
  });

  test('toString', () {
    expect(Interval(1, 2).toString(), 'Interval(1, 2)');
  });
}
