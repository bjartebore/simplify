import 'dart:math';

num _getSqDist<T extends Point>(
  T p1,
  T p2,
) {
  final num dx = p1.x - p2.x, dy = p1.y - p2.y;

  return dx * dx + dy * dy;
}

// square distance from a point to a segment
num _getSqSegDist<T extends Point>(
  T p,
  T p1,
  T p2,
) {
  num x = p1.x, y = p1.y, dx = p2.x - x, dy = p2.y - y;

  if (dx != 0 || dy != 0) {
    final double t = ((p.x - x) * dx + (p.y - y) * dy) / (dx * dx + dy * dy);

    if (t > 1) {
      x = p2.x;
      y = p2.y;
    } else if (t > 0) {
      x += dx * t;
      y += dy * t;
    }
  }

  dx = p.x - x;
  dy = p.y - y;

  return dx * dx + dy * dy;
}

List<T> _simplifyRadialDist<T extends Point>(
  List<T> points,
  double sqTolerance,
) {
  T prevPoint = points[0];
  final List<T> newPoints = [prevPoint];
  late T point;

  // ignore: prefer_final_locals
  for (var i = 1, len = points.length; i < len; i++) {
    point = points[i];

    if (_getSqDist(point, prevPoint) > sqTolerance) {
      newPoints.add(point);
      prevPoint = point;
    }
  }

  if (prevPoint != point) {
    newPoints.add(point);
  }

  return newPoints;
}

void _simplifyDPStep<T extends Point>(
  List<T> points,
  int first,
  int last,
  double sqTolerance,
  List<T> simplified,
) {
  num maxSqDist = sqTolerance;
  late int index;

  for (var i = first + 1; i < last; i++) {
    final num sqDist = _getSqSegDist(points[i], points[first], points[last]);

    if (sqDist > maxSqDist) {
      index = i;
      maxSqDist = sqDist;
    }
  }

  if (maxSqDist > sqTolerance) {
    if (index - first > 1) {
      _simplifyDPStep(points, first, index, sqTolerance, simplified);
    }
    simplified.add(points[index]);
    if (last - index > 1) {
      _simplifyDPStep(points, index, last, sqTolerance, simplified);
    }
  }
}

// simplification using Ramer-Douglas-Peucker algorithm
List<T> _simplifyDouglasPeucker<T extends Point>(
  List<T> points,
  double sqTolerance,
) {
  final int last = points.length - 1;

  final List<T> simplified = [points[0]];
  _simplifyDPStep(points, 0, last, sqTolerance, simplified);
  simplified.add(points[last]);

  return simplified;
}

// both algorithms combined for awesome performance
List<T> simplify<T extends Point>(
  List<T> points, {
  double? tolerance,
  bool highestQuality = false,
}) {
  if (points.length <= 2) {
    return points;
  }

  List<T> nextPoints = points;

  final double sqTolerance = tolerance != null ? tolerance * tolerance : 1;

  nextPoints =
      highestQuality ? points : _simplifyRadialDist(nextPoints, sqTolerance);

  nextPoints = _simplifyDouglasPeucker(nextPoints, sqTolerance);

  return nextPoints;
}
