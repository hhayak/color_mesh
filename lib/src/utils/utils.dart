import 'dart:math';

import 'package:flutter/material.dart';

import 'package:color_mesh/src/mesh_gradient.dart';

extension Shuffle on MeshGradient {
  MeshGradient shuffle() {
    final colors = this.colors.toList()..shuffle();
    return copyWith(colors: colors);
  }
}

class MathUtils {
  static List<List<double>> distanceSquared(
      List<Offset> x, List<Offset> y, bool yIsX) {
    if (yIsX) {
      List<List<double>> gram = [];
      for (int r = 0; r < x.length; r++) {
        List<double> row = [];
        for (int c = 0; c < x.length; c++) {
          row.add(x[r].dx * x[c].dx + x[r].dy * x[c].dy);
        }
        gram.add(row);
      }

      List<List<double>> result = [];
      for (int r = 0; r < x.length; r++) {
        List<double> row = [];
        for (int c = 0; c < x.length; c++) {
          row.add(gram[r][r] + gram[c][c] - 2 * gram[r][c]);
        }
        result.add(row);
      }
      return result;
    } else {
      List<List<double>> gram = [];
      for (int r = 0; r < x.length; r++) {
        List<double> row = [];
        for (int c = 0; c < y.length; c++) {
          row.add(x[r].dx * y[c].dx + x[r].dy * y[c].dy);
        }
        gram.add(row);
      }

      List<double> diagx = [];
      for (int i = 0; i < x.length; i++) {
        diagx.add(x[i].dx * x[i].dx + x[i].dy * x[i].dy);
      }

      List<double> diagy = [];
      for (int i = 0; i < y.length; i++) {
        diagy.add(y[i].dx * y[i].dx + y[i].dy * y[i].dy);
      }

      List<List<double>> result = [];
      for (int r = 0; r < x.length; r++) {
        List<double> row = [];
        for (int c = 0; c < y.length; c++) {
          row.add(diagx[r] + diagy[c] - 2 * gram[r][c]);
        }
        result.add(row);
      }
      return result;
    }
  }

  static (List<List<double>>, List<double>) rbf(
      List<Offset> x, List<Offset> y, bool yIsX) {
    var dists2 = distanceSquared(x, y, yIsX);
    final s2 = List.generate(x.length, (index) => 0.0);

    if (yIsX) {
      var d2max = dists2[0][0];
      for (var r = 0; r < dists2.length; r++) {
        for (var c = 0; c < dists2[r].length; c++) {
          if (d2max < dists2[r][c]) {
            d2max = dists2[r][c];
          }
        }
      }
      var dtmp = <List<double>>[];
      for (var r = 0; r < dists2.length; r++) {
        var row = <double>[];
        for (var c = 0; c < dists2[r].length; c++) {
          row.add((r == c) ? d2max : dists2[r][c]);
        }
        dtmp.add(row);
      }

      for (var c = 0; c < dtmp[0].length; c++) {
        var min = dtmp[0][c];
        for (var r = 1; r < dtmp.length; r++) {
          if (min > dtmp[r][c]) {
            min = dtmp[r][c];
          }
        }
        s2[c] = min;
      }
    }

    var result = <List<double>>[];
    for (var r = 0; r < dists2.length; r++) {
      var row = <double>[];
      for (var c = 0; c < dists2[r].length; c++) {
        row.add(sqrt(dists2[r][c] + s2[c]));
      }
      result.add(row);
    }

    return (result, s2);
  }

  static List<List<double>> linsolve(
      List<List<double>> A, List<List<double>> b) {
    var rows = A.length;
    var cols = A[0].length;
    var bcols = b[0].length;

    for (var c = 0; c < cols - 1; c++) {
      // make column c of all rows > c equal to zero
      //  by subtracting the appropriate multiple of row c
      var r0 = c;
      var r1 = r0 + 1;

      // find row with largest value in column c (pivot row)
      var max = (A[r0][c]).abs();
      var maxR = r0;
      for (var r = r0 + 1; r < rows; r++) {
        var x = (A[r][c]).abs();
        if (max < x) {
          max = x;
          maxR = r;
        }
      }

      // move pivot row to top
      if (maxR != r0) {
        var tA = A[r0];
        A[r0] = A[maxR];
        A[maxR] = tA;
        var tb = b[r0];
        b[r0] = b[maxR];
        b[maxR] = tb;
      }

      for (var r = r1; r < rows; r++) {
        var k0 = A[r0][c];
        var k1 = A[r][c];
        for (var i = c; i < cols; i++) {
          A[r][i] = k0 * A[r][i] - k1 * A[r0][i];
        }
        for (var i = 0; i < bcols; i++) {
          b[r][i] = k0 * b[r][i] - k1 * b[r0][i];
        }
      }
    }

    for (var r = rows - 1; r >= 0; r--) {
      for (var c = rows - 1; c > r; c--) {
        var k = A[r][c];
        A[r][c] = 0;
        for (var i = 0; i < bcols; i++) {
          b[r][i] -= k * b[c][i];
        }
      }
      for (var i = 0; i < bcols; i++) {
        b[r][i] /= A[r][r];
      }
      A[r][r] = 1;
    }

    return b;
  }
}
